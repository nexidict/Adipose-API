---@class Adipose
local adipose = {}

-- CONFIG
adipose.scaling = true
adipose.verbose = true

-- CONSTANTS
adipose.minWeight = 100
adipose.maxWeight = 1000

adipose.weightRate = 0.01

-- VARIABLES
adipose.currentWeight = config:load("adipose.currentWeight") or adipose.minWeight
adipose.currentWeightStage = config:load("adipose.currentWeightStage") or 1

adipose.syncTimer = 20
local timer = adipose.syncTimer
local oldindex = nil

adipose.pehkui = {
    HITBOX_WIDTH = "pehkui:hitbox_width",
    HITBOX_HEIGHT = "pehkui:hitbox_height",
    MOTION = "pehkui:motion",
    EYE_HEIGHT = "pehkui:eye_height",
}

adipose.pehkui.enabled = {
    [adipose.pehkui.HITBOX_WIDTH] = true,
    [adipose.pehkui.HITBOX_HEIGHT] = true,
    [adipose.pehkui.MOTION] = true,
    [adipose.pehkui.EYE_HEIGHT] = true,
}

---@class Adipose.ScaleOption
adipose.scaleOption = {}
adipose.scaleOption.__index = adipose.scaleOption
adipose.scaleOption.minWeight = nil
adipose.scaleOption.maxWeight = nil

---@param minWeight number Value for static scaling or minimum weight for dynamic scaling
---@param maxWeight number? Optional value at maximum weight for dynamic scaling
function adipose.newScaleOption(minWeight, maxWeight)
    return setmetatable({
        minWeight = minWeight,
        maxWeight = maxWeight
    }, adipose.scaleOption)
end


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

local function getSaturation()
    return adipose.osCheck and
        (player:getNbt()["ForgeCaps"]["overstuffed:properties"]["stuffedbar"] / 9) or
        (player:getSaturation() / 20)
end

local function calculateWeightFromIndex(index)
    if index == #adipose.weightStages + 1 then return adipose.maxWeight end

    local normalized = (index - 1) / (#adipose.weightStages)
    local weight = adipose.minWeight + normalized * (adipose.maxWeight - adipose.minWeight)

    return weight
end

local function calculateProgressFromWeight(weight)
    local normalized = (weight - adipose.minWeight) / (adipose.maxWeight - adipose.minWeight)
    local exactWeightStage = (normalized * #adipose.weightStages) + 1

    if exactWeightStage == (#adipose.weightStages + 1) then
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
        -- this command is ass, returns scale without a prefix because abyssal didnt take my suggestion
        scale = string.sub(scale, prefixIndex + 1, -1)
        host:sendChatCommand("overstuffed setScale " .. scale .. " " .. value)
    elseif adipose.p4aCheck then
        local prefixIndex = string.find(scale, ":")
        -- this command is also ass, returns scale without a prefix because god's light doesnt shine here
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

local function setStageScale(index, granularity)
    local stage = adipose.getStage(index)
    local indexChanged = (oldindex ~= index)
    if indexChanged then oldindex = index end
    for scale, value in pairs(stage:getScaleOptions()) do
        if adipose.pehkui.enabled[scale] then
            if value.maxWeight then
                -- Dynamic Scaling
                setGranularScale(
                    scale, 
                    value.minWeight,
                    value.maxWeight,
                    granularity)
            elseif indexChanged then
                -- Static Scaling
                setScale(scale, value.minWeight)
            end
        end
    end
end

-- MODEL FUNCTIONS
local function setModelPartsVisibility(index)
    local stage = adipose.getStage(index)

    local visibleParts = {}
    for _, p in ipairs(stage.partsList) do
        visibleParts[p] = true
    end

    for _, s in pairs(adipose.getStages()) do
        for _, p in pairs(s.partsList) do
            p:setVisible(visibleParts[p] == true)
        end
    end
end
pings.setModelPartsVisibility = setModelPartsVisibility

---@class Adipose.GranularAnimation
adipose.granularAnimation = {}
adipose.granularAnimation.__index = adipose.granularAnimation
adipose.granularAnimation.animation = nil

function adipose.granularAnimation.new(animation)
    animation:setSpeed(0)
    animation:play()
    return setmetatable({
        animation = animation,
    }, adipose.granularAnimation)
end

function adipose.granularAnimation:setOffset(value)
    self.animation:setOffset(self.animation:getLength() * value)
end

local function setGranularity(index, granularity)
    local anim = adipose.getStage(index).granularAnim
    if not anim then return end
    anim:setOffset(granularity)
end
pings.setGranularity = setGranularity

local function setStuffed(index, stuffed)
    local anim = adipose.getStage(index).stuffedAnim
    if not anim then return end
    anim:setOffset(stuffed)
end
pings.setStuffed = setStuffed

-- EVENTS
function events.tick()
    if #adipose.weightStages == 0 then return end

    if timer < 0 then
        timer = adipose.syncTimer

        adipose.setWeight(adipose.osCheck and
            player:getNbt()["ForgeCaps"]["overstuffed:weightbar"]["currentweight"] or
            (adipose.currentWeight + checkFood()))
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
    adipose.pehkuiCheck = client.isModLoaded("pehkui")
    adipose.p4aCheck = client.isModLoaded("pehkui4all")
    adipose.osCheck = client.isModLoaded("overstuffed")
    adipose.opCheck = player:getPermissionLevel() == 4

    if adipose.osCheck then
        local OSWeightBar = player:getNbt()["ForgeCaps"]["overstuffed:weightbar"]

        adipose.maxWeight = OSWeightBar["maxweight"]
        adipose.minWeight = OSWeightBar["minweight"]
        adipose.currentWeight = OSWeightBar["currentweight"]

        --print(adipose.maxWeight)
        --print(adipose.minWeight)
        --print(adipose.currentWeight)
    end

    printStartupMessage()

    adipose.setWeight(adipose.currentWeight)
end

-- WEIGHT MANAGEMENT
---Sets weight by amount. From adipose.minWeight (100) to adipose.maxWeight (1000).
---@param amount number
function adipose.setWeight(amount)
    if #adipose.weightStages == 0 then return end

    adipose.currentWeight = math.clamp(
        math.floor(amount * 10) / 10,
        adipose.minWeight,
        adipose.maxWeight)

    local index, granularity = calculateProgressFromWeight(adipose.currentWeight)

    adipose.currentWeightStage = index

    setStageScale(index, granularity)

    pings.setModelPartsVisibility(index)
    pings.setGranularity(index, granularity)
    pings.setStuffed(index, getSaturation())

    --print(index , granularity)

    if not adipose.osCheck and host:isHost() then
        config:save("adipose.currentWeight", adipose.currentWeight)
        config:save("adipose.currentWeightStage", adipose.currentWeightStage)
    end
end

---@param stage number
function adipose.setCurrentWeightStage(stage)
    stage = math.clamp(math.floor(stage), 1, #adipose.weightStages + 1)
    adipose.setWeight(calculateWeightFromIndex(stage))
end

function adipose.adjustWeightByAmount(amount)
    amount = math.clamp((adipose.currentWeight + math.floor(amount)), adipose.minWeight, adipose.maxWeight)
    adipose.setWeight(amount)
end

function adipose.adjustWeightByStage(amount)
    amount = math.clamp((adipose.currentWeightStage + math.floor(amount)), 1, #adipose.weightStages + 1)
    adipose.setWeight(calculateWeightFromIndex(amount) + 1) -- +1 is padding for hunger decay
end

-- WEIGHT STAGE
---@class Adipose.WeightStage[]
adipose.weightStages = {}

---@class Adipose.WeightStage
adipose.weightStage = {}
adipose.weightStage.__index = adipose.weightStage
adipose.weightStage.partsList = nil
adipose.weightStage.granularAnim = nil
adipose.weightStage.stuffedAnim = nil
adipose.weightStage.scaleOptions = nil

---@return Adipose.WeightStage
function adipose.newStage()
    local obj = setmetatable({
        partsList = {},
        scaleOptions = {},
    }, adipose.weightStage)
    table.insert(adipose.weightStages, obj)
    return obj
end

---@param index number
---@return Adipose.WeightStage
function adipose.getStage(index)
    return adipose.weightStages[index]
end

---@return [Adipose.WeightStage]
function adipose.getStages()
    return adipose.weightStages
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
    self.granularAnim = adipose.granularAnimation.new(animation)
    return self
end

---@param animation Animation
---@return self
function adipose.weightStage:setStuffedAnimation(animation)
    self.stuffedAnim = adipose.granularAnimation.new(animation)
    return self
end

---@param scale string Name of scaling option, must be one of adipose.pehkui
---@param minWeight number Value for static scaling or value at minimum weight of this stage for dynamic scaling.
---@param maxWeight? number Optional value at maximum weight of this stage for dynamic scaling.
---@return self
function adipose.weightStage:addScaleOption(scale, minWeight, maxWeight)
    assert(adipose.pehkui.enabled[scale] ~= nil, "Unsupported scaling option")
    self.scaleOptions[scale] = adipose.newScaleOption(minWeight, maxWeight)
    return self
end

---@return [Adipose.ScaleOption]
function adipose.weightStage:getScaleOptions()
    return self.scaleOptions
end

return adipose
