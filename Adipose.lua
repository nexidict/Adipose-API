---@class Adipose
local adipose = {}

-- CONFIG
adipose.scaling = true
adipose.verbose = true

-- CONSTANTS
adipose.minWeight = 100
adipose.maxWeight = 1000

adipose.weightRate = 0.01

adipose.pehkui = {
    HITBOX_WIDTH  = "pehkui:hitbox_width",
    HITBOX_HEIGHT = "pehkui:hitbox_height",
    MOTION        = "pehkui:motion",
    EYE_HEIGHT    = "pehkui:eye_height",
}

-- VARIABLES
adipose.currentWeight = config:load("adipose.currentWeight") or adipose.minWeight
adipose.currentWeightStage = config:load("adipose.currentWeightStage") or 1

adipose.syncTimer = 20
local timer = adipose.syncTimer
local oldindex = nil


-- FUNCTIONS
local function checkFood()
    -- only runs if OverStuffed isnt installed
    local deltaWeight = 0

    if player:getSaturation() > 2 then
        deltaWeight =
            deltaWeight + (player:getSaturation() - 2) * adipose.weightRate
    end

    if player:getFood() < 17 then
        deltaWeight =
            deltaWeight - (17 - player:getFood()) * adipose.weightRate
    end

    return deltaWeight
end

local function calculateWeightFromIndex(index)
    if index == #adipose.weightStages + 1 then return adipose.maxWeight end

    local normalized = (index - 1) / (#adipose.weightStages)
    local weight = adipose.minWeight + normalized * (adipose.maxWeight - adipose.minWeight)

    return weight
end

local function calculateProgressFromWeight(weight)
    local normalized = (weight - adipose.minWeight) / (adipose.maxWeight - adipose.minWeight)
    local exactWeightStage = normalized * #adipose.weightStages + 1

    if exactWeightStage == #adipose.weightStages + 1 then
        return #adipose.weightStages, 1
    end

    local index = math.floor(exactWeightStage)
    local granularity = exactWeightStage - index

    return index, granularity
end

local function setScale(scale, value)
    if not player:isLoaded() or not adipose.pehkuiCheck or not adipose.scaling or not value then return end

    if adipose.opCheck then
        host:sendChatCommand("scale set " .. scale .. " " .. value .. " @s")
    elseif adipose.osCheck then
        local prefixIndex = string.find(scale, ":")
        --this command is ass, returns scale without a prefix because abyssal didnt take my suggestion
        scale = string.sub(scale, prefixIndex + 1, -1)
        host:sendChatCommand("overstuffed setScale " .. scale .. " " .. value)
    elseif adipose.p4aCheck then
        local prefixIndex = string.find(scale, ":")
        --this command is also ass, returns scale without a prefix because god's light doesnt shine here
        scale = string.sub(scale, prefixIndex + 1, -1)
        host:sendChatCommand("lesserscale set " .. value .. " " .. scale)
    end
end

local function setGranularScale(scaleName, scaleMinWeight, scaleMaxWeight, granularity)
    if scaleMinWeight and scaleMinWeight then
        local scaleValue = math.map(
            granularity, 0, 1,
            scaleMinWeight, scaleMaxWeight)
        setScale(scaleName, scaleValue)
    end
end

-- MODEL FUNCTIONS
local function setModelPartsVisibility(index)
    local visibleParts = {}
    for _, p in ipairs(adipose.weightStages[index].partsList) do
        visibleParts[p] = true
    end

    for _, s in ipairs(adipose.weightStages) do
        for _, p in ipairs(s.partsList) do
            p:setVisible(visibleParts[p] == true)
        end
    end
end
pings.setModelPartsVisibility = setModelPartsVisibility

local function setGranularity(index, granularity)
    local animation = adipose.weightStages[index].granularAnim
    if animation == "" then return end

    animation:play()
    animation:setSpeed(0)

    local offset = animation:getLength() * granularity
    animation:setOffset(offset)
end
pings.setGranularity = setGranularity

local function setStuffed(index, stuffed)
    local animation = adipose.weightStages[index].stuffedAnim
    if animation == "" then return end

    animation:play()
    animation:setSpeed(0)

    local offset = animation:getLength() * stuffed
    animation:setOffset(offset)
end
pings.setStuffed = setStuffed

-- EVENTS
function events.tick()
    if #adipose.weightStages == 0 then return end

    if timer < 0 then
        timer = adipose.syncTimer

        if not adipose.osCheck then --Update the weight value
            local deltaWeight = checkFood() --All things that affect weight
            adipose.currentWeight = adipose.currentWeight + deltaWeight
        else
            --ignore everything and just sync with overstuffed
            adipose.currentWeight = player:getNbt()["ForgeCaps"]["overstuffed:weightbar"]["currentweight"]
        end

        local packet = math.floor(adipose.currentWeight * 10) / 10
        --print(packet)
        adipose.setWeight(packet) -- set weight to current value
    else
        timer = timer - 1
    end
end

local function printStartupMessage()
    if not adipose.verbose then
        return
    end
    if not adipose.scaling then
        print("Adipose: scaling disabled (manual)")
        return
    end
    if not adipose.pehkuiCheck then
        print("Adipose: scaling disabled (pehkui not installed)")
        return
    end
    if adipose.opCheck then
        print("Adipose: scaling enabled (operator permissions)")
    elseif adipose.osCheck then
        print("Adipose: scaling enabled (overstuffed detected)")
    elseif adipose.p4aCheck then
        print("Adipose: scaling enabled (pehkui4all detected)")
    else
        print("Adipose: scaling disabled (insufficient permissions)")
    end
end

function events.entity_init()
    if #adipose.weightStages == 0 then return end

    adipose.osCheck = client.isModLoaded("overstuffed")

    if adipose.osCheck then
        local OSWeightBar = player:getNbt()["ForgeCaps"]["overstuffed:weightbar"]

        adipose.maxWeight = OSWeightBar["maxweight"]
        adipose.minWeight = OSWeightBar["minweight"]
        adipose.currentWeight = OSWeightBar["currentweight"]

        --print(adipose.maxWeight)
        --print(adipose.minWeight)
        --print(adipose.currentWeight)
    end

    adipose.pehkuiCheck = client.isModLoaded("pehkui")
    adipose.p4aCheck = client.isModLoaded("pehkui4all")
    adipose.opCheck = player:getPermissionLevel() == 4

    printStartupMessage()

    setScale(adipose.pehkui.HITBOX_WIDTH, adipose.weightStages[1].hitboxWidth)
    setScale(adipose.pehkui.HITBOX_HEIGHT, adipose.weightStages[1].hitboxHeight)
    setScale(adipose.pehkui.MOTION, adipose.weightStages[1].motion)
    setScale(adipose.pehkui.EYE_HEIGHT, adipose.weightStages[1].eyeHeight)

    adipose.setWeight(adipose.currentWeight)
end

-- WEIGHT MANAGEMENT
---Sets weight by amount. From adipose.minWeight (100) to adipose.maxWeight (1000).
---@param amount number
function adipose.setWeight(amount)
    amount = math.clamp(amount, adipose.minWeight, adipose.maxWeight)

    local index, granularity = calculateProgressFromWeight(amount)

    adipose.currentWeight = amount
    adipose.currentWeightStage = index

    if #adipose.weightStages == 1 then 
        local stage = adipose.weightStages[index]
        setGranularScale(
            adipose.pehkui.HITBOX_WIDTH,
            stage.scale.hitboxWidth.minWeight,
            stage.scale.hitboxWidth.maxWeight,
            granularity
        )
        setScale(adipose.pehkui.HITBOX_HEIGHT, stage.hitboxHeight)
        setScale(adipose.pehkui.MOTION, stage.motion)
        setScale(adipose.pehkui.EYE_HEIGHT, stage.eyeHeight)
    else
        if oldindex ~= index then
            oldindex = index
            local stage = adipose.weightStages[index]
            setScale(adipose.pehkui.HITBOX_WIDTH, stage.hitboxWidth)
            setScale(adipose.pehkui.HITBOX_HEIGHT, stage.hitboxHeight)
            setScale(adipose.pehkui.MOTION, stage.motion)
            setScale(adipose.pehkui.EYE_HEIGHT, stage.eyeHeight)
        end
        pings.setModelPartsVisibility(index)
    end

    local stuffed = 0
    if not adipose.osCheck then
        stuffed = player:getSaturation() / 20
    else
        stuffed = player:getNbt()["ForgeCaps"]["overstuffed:properties"]["stuffedbar"] / 9
    end

    pings.setGranularity(index, granularity)
    pings.setStuffed(index, stuffed)

    --print(index , granularity)

    if not adipose.osCheck and host:isHost() then
        config:save("adipose.currentWeight", math.floor(adipose.currentWeight * 10) / 10)
        config:save("adipose.currentWeightStage", adipose.currentWeightStage)
    end
end

---@param stage number
function adipose.setCurrentWeightStage(stage)
    stage = math.clamp(math.floor(stage), 1, #adipose.weightStages + 1)
    adipose.setWeight(calculateWeightFromIndex(stage))
end

function adipose.adjustWeightByAmount(amount)
    amount = math.clamp((adipose.currentWeight + math.floor(amount)), adipose.minWeight,
        adipose.maxWeight)
    adipose.setWeight(amount)
end

function adipose.adjustWeightByStage(amount)
    amount = math.clamp((adipose.currentWeightStage + math.floor(amount)), 1, #adipose.weightStages +
    1)
    adipose.setWeight(calculateWeightFromIndex(amount) + 1) -- +1 is padding for hunger decay
end

-- WEIGHT STAGE
---@class Adipose.WeightStage[]
adipose.weightStages = {}
---@class Adipose.WeightStage
adipose.weightStage = {}
adipose.weightStage.__index = adipose.weightStage
adipose.weightStage.partsList = {}
adipose.weightStage.granularAnim = ""
adipose.weightStage.stuffedAnim = ""
adipose.weightStage.hitboxWidth = nil
adipose.weightStage.hitboxHeight = nil
adipose.weightStage.eyeHeight = nil
adipose.weightStage.motion = nil
adipose.weightStage.scale = {
    hitboxWidth = {
        minWeight = nil,
        maxWeight = nil,
    },
    hitboxHeight = {
        minWeight = nil,
        maxWeight = nil,
    },
    eyeHeight = {
        minWeight = nil,
        maxWeight = nil,
    },
    motion = {
        minWeight = nil,
        maxWeight = nil,
    },
}

---@return Adipose.WeightStage
function adipose.newStage()
    local obj = setmetatable({}, adipose.weightStage)
    table.insert(adipose.weightStages, obj)
    return obj
end

-- WEIGHT STAGE METHODS
---@param parts ModelPart|[ModelPart]
---@return self
function adipose.weightStage:setParts(parts)
    assert(parts, "Invalid parts")
    if type(parts) == "ModelPart" then
        parts = { parts }
    end
    assert(type(parts) == "table", "Invalid type for parts")
    for i, p in ipairs(parts) do
        assert(p, "Invalid part at position " .. i)
        assert(type(p) == "ModelPart", "Invalid type for part at position " .. i)
    end
    self.partsList = parts
    return self
end

---@param animation Animation
---@return self
function adipose.weightStage:setGranularAnimation(animation)
    self.granularAnim = animation
    return self
end

---@param animation Animation
---@return self
function adipose.weightStage:setStuffedAnimation(animation)
    self.stuffedAnim = animation
    return self
end

---@param offset number
---@return self
function adipose.weightStage:setEyeHeight(offset)
    self.eyeHeight = offset
    return self
end

---@param width number
---@return self
function adipose.weightStage:setHitboxWidth(width)
    self.hitboxWidth = width
    return self
end

---@param height number
---@return self
function adipose.weightStage:setHitboxHeight(height)
    self.hitboxHeight = height
    return self
end

---@param motion number
---@return self
function adipose.weightStage:setMotion(motion)
    self.motion = motion
    return self
end

---@param minWeight number
---@param maxWeight number
---@return self
function adipose.weightStage:setHitboxWidthRange(minWeight, maxWeight)
    self.scale.hitboxWidth.minWeight = minWeight
    self.scale.hitboxWidth.maxWeight = maxWeight
    return self
end

end

return adipose
