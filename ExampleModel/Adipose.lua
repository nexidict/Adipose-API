---@class Adipose
local adipose = {}

-- CONSTANTS
adipose.minWeight = 100
adipose.maxWeight = 1000

adipose.weightRate = 0.001

-- VARIABLES
adipose.currentWeight = adipose.minWeight
adipose.granularWeight = 0
adipose.currentWeightStage = 1

adipose.syncTimer = 0
adipose.digestTimer = 0

-- FLAGS
adipose.hitbox = true
adipose.motion = true
adipose.eyeHeight = true

-- FUNCTIONS
function pings.SyncWeight()

end

local function checkFood()
    local curWeight = adipose.currentWeight

    if player:getSaturation() > 2 then
        curWeight =
            curWeight + (player:getSaturation() - 2) * adipose.weightRate * adipose.digestTimer
    end

    if player:getFood() < 17 then
		curWeight = 
            adipose.currentWeight - (17 - player:getFood()) * adipose.weightRate * adipose.digestTimer
	end

    return curWeight
end

--- Given the number of stages, calculates and assigns thresholds to each weight stage.
local function assignWeightStages()
    local stageCount = #adipose.weightStages

    for i, stage in ipairs(adipose.weightStages) do
        local normalized = (i - 1) / (stageCount - 1)
        stage.weight = adipose.minWeight + normalized * (adipose.maxWeight - adipose.minWeight)
    end
end

local function calculateIndexFromWeight(weight)
    local normalized = (weight - adipose.minWeight) / (adipose.maxWeight - adipose.minWeight)
    local index = math.floor(normalized * (#adipose.weightStages - 1) + 1)
    return math.clamp(index, 1, #adipose.weightStages)
end

--- Using thersholds, calculate the granular weight.
local function calculateGranularity(weight, index)
    local normalized = (weight - adipose.minWeight)/(adipose.maxWeight - adipose.minWeight)
    local granularity = (normalized * (#adipose.weightStages - 1)) + 1
    return granularity - index
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

local function setGranularity(granularity, index)
    local animation = adipose.weightStages[index].granularAnim
    if animation == '' then return end

    animation:play()
    animation:setSpeed(0)

    local offset = animation:getLength() * granularity
    animation:setOffset(offset)
end

-- EVENTS
function events.tick()
    local timer = adipose.syncTimer

    if timer < 0 then 
        -- syncWeight
        timer = 10
    else timer = timer - 1 end
    
    if timer < 0 then
        timer = 10
        adipose.SetWeight(checkFood())
    else timer = timer - 1 end

    adipose.syncTimer = timer
end

function events.entity_init()
    if #adipose.weightStages == 0 then return end

    adipose.setHitboxWidth(adipose.weightStages[1].hitboxWidth)
    adipose.setHitboxHeight(adipose.weightStages[1].hitboxHeight)
    adipose.setMotion(adipose.weightStages[1].motion)
    adipose.setEyeHeight(adipose.weightStages[1].eyeHeight)

    assignWeightStages()
end

-- WEIGHT MANAGEMENT
function adipose.SetWeight(amount)
    amount = math.clamp(amount, adipose.minWeight, adipose.maxWeight)
    local index = calculateIndexFromWeight(amount)

    adipose.currentWeight = amount
    adipose.currentWeightStage = index

    local granularity = calculateGranularity(amount, index)
    adipose.granularWeight = granularity

    local stage = adipose.weightStages[index]
    adipose.setHitboxWidth(stage.hitboxWidth)
    adipose.setHitboxHeight(stage.hitboxHeight)
    adipose.setEyeHeight(stage.eyeHeight)
    adipose.setMotion(stage.motion)

    setModelPartsVisibility(index)
    setGranularity(granularity, index)

    print('Current Weight', adipose.currentWeight)
    print('Current Weight Stage', adipose.currentWeightStage)
    print('Granular Weight', adipose.granularWeight)
end

function adipose.setCurrentWeightStage(stage)
    stage = math.clamp(math.floor(stage), 1, #adipose.weightStages)
    adipose.SetWeight(adipose.weightStages[stage].weight)
end

function adipose.adjustWeightByAmount(amount)
    amount = math.clamp(
        (adipose.currentWeight + math.floor(amount)),
        adipose.minWeight, adipose.maxWeight
    )
    adipose.SetWeight(amount)
end

function adipose.adjustWeightByStage(amount)
    amount = math.clamp((adipose.currentWeightStage + math.floor(amount)), 1, #adipose.weightStages)
    adipose.SetWeight(adipose.weightStages[amount].weight)
end

-- WEIGHT STAGE
---@class Adipose.WeightStage[]
adipose.weightStages = {}
adipose.weightStage = {}
adipose.weightStage.__index = adipose.weightStage

---@return table
function adipose.weightStage:newStage()
    local self = setmetatable({
        partsList = {},
        granularAnim = '',
        hitboxWidth = 1,
        hitboxHeight = 1,
        eyeHeight = 1,
        motion = 1
    }, adipose.weightStage)

    table.insert(adipose.weightStages, self)
    return self
end


-- WEIGHT STAGE METHODS
---@param parts table<Models|ModelPart>
---@return self
function adipose.weightStage:setParts(parts)
    if type(parts) ~= 'table' then
        if type(parts) ~= 'ModelParts' or type(partsList) ~= 'models' then
            error("partsList must be a table or a ModelPart/Models object")
        end
    end

    -- Validate contents of the table
    for i, p in ipairs(parts) do
        if type(p) == 'ModelParts' or type(p) == 'models' then
            error("The body part at position "..i.." is not a models or a ModelPart")
        end
    end 

    self.partsList = parts
    return self
end

---@param animation animations
---@return self
function adipose.weightStage:setGranularAnimation(animation)
    self.granularAnim = animation
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

-- PEHKUI METHODS
function adipose.setHitboxWidth(width)
    host:sendChatCommand('scale set pehkui:hitbox_width '..width..' @s')
end

function adipose.setHitboxHeight(height)
    host:sendChatCommand('scale set pehkui:hitbox_height '..height..' @s')
end

function adipose.setMotion(motion)
    host:sendChatCommand('scale set pehkui:motion '..motion..' @s')
end

function adipose.setEyeHeight(offset)
    host:sendChatCommand('scale set pehkui:eye_height '..offset..' @s')
end

-- FLAGS METHODS
---@param state boolean
function adipose.setHitboxState(state)
    local previousValue = adipose.hitbox

    if state ~= previousValue then
        adipose.hitbox = state

        if state == true then
            adipose.setHitboxWidth(adipose.weightStages[adipose.currentWeightStage].hitboxWidth)
            adipose.setHitboxHeight(adipose.weightStages[adipose.currentWeightStage].hitboxHeight)
            return
        end

        adipose.setHitboxWidth(1)
        adipose.setHitboxHeight(1)
        return
    end
end

---@param state boolean
function adipose.setMotionState(state)
    local previousValue = adipose.motion

    if state ~= previousValue then
        adipose.motion = state

        if state == true then
            adipose.setMotion(adipose.weightStages[adipose.currentWeightStage].motion)
            return
        end

        adipose.setMotion(1)
        return
    end
end

---@param state boolean
function adipose.setEyeHeightState(state)
    local previousValue = adipose.eyeHeight

    if state ~= previousValue then
        adipose.eyeHeight = state

        if state == true then
            adipose.setEyeHeight(adipose.weightStages[adipose.currentWeightStage].eyeHeight)
            return
        end

        adipose.setEyeHeight(1)
        return
    end
end

return adipose