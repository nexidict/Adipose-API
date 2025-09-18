---@class Adipose
local adipose = {}

-- CONSTANTS
adipose.minWeight = 100
adipose.maxWeight = 1000

adipose.weightRate = 0.01

-- VARIABLES
adipose.currentWeight = config:load("adipose.currentWeight") or adipose.minWeight
adipose.granularWeight = 0
adipose.currentWeightStage = config:load("adipose.currentWeightStage") or 1

adipose.foodTimer = 20

local foodTimer = adipose.foodTimer
local oldindex = nil
local isDead = false

adipose.scaling = true

-- FUNCTIONS
adipose.onWeightChange = function(_, _) end

function adipose.setOnWeightChange(callback)
    adipose.onWeightChange = callback
end

local function checkFood()
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
    if index == #adipose.weightStages+1 then return adipose.maxWeight end

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
pings.setModelPartsVisibility=setModelPartsVisibility

local function setGranularity(index, granularity)
    local animation = adipose.weightStages[index].granularAnim
    if animation == '' then return end

    animation:play()
    animation:setSpeed(0)

    local offset = animation:getLength() * granularity
    animation:setOffset(offset)
end

local function setStuffed(index, stuffed)
    local animation = adipose.weightStages[index].stuffedAnim
    if animation == '' then return end	
	
    animation:play()
    animation:setSpeed(0)
	
    local offset = animation:getLength() * stuffed
    animation:setOffset(offset)
end

-- EVENTS
function events.tick()
    if player:getHealth() <= 0 then 
        -- When the entity just died and the death screen appears
        if not isDead then isDead = true end
    else
        if isDead then
            adipose.setWeight(adipose.currentWeight, true)
            isDead = false
        end
    end

    if foodTimer < 0 then
        foodTimer = adipose.foodTimer

        local deltaWeight = checkFood()
        adipose.currentWeight = adipose.currentWeight + deltaWeight 	
    else
        foodTimer = foodTimer - 1
    end
end

if not host:isHost() then
    -- last seen by this client
    local weightStageIndex = nil

    function events.tick()
        local vars = world.avatarVars()[avatar:getUUID()]
        if not vars then return end

        local index = vars["adipose.weightStageIndex"]
        if not index then return end
        
        if weightStageIndex ~= index then
            pings.setModelPartsVisibility(index)
            weightStageIndex = index
        end
    end
end

function events.entity_init()
	if #adipose.weightStages == 0 then return end	
	adipose.opCheck = player:getPermissionLevel() == 4
end

-- WEIGHT MANAGEMENT
function adipose.setWeight(amount, forceUpdate)
    amount = math.clamp(amount, adipose.minWeight, adipose.maxWeight)
		
    local index, granularity = calculateProgressFromWeight(amount)

    adipose.currentWeight = amount
    adipose.currentWeightStage = index

    adipose.granularWeight = granularity

    if oldindex ~= index or forceUpdate then
        oldindex = index
        adipose.onWeightChange(index, granularity)
        pings.setModelPartsVisibility(index)
        if host:isHost() then
            avatar:store("adipose.weightStageIndex", index)
        end
    end
	
	local stuffed = player:getSaturation()/20
	
	setGranularity(index, granularity)
	setStuffed(index, stuffed)

    if host:isHost() then 
        config:save("adipose.currentWeight", math.floor(adipose.currentWeight*10)/10)
        config:save("adipose.currentWeightStage", adipose.currentWeightStage)
    end
end

function adipose.setCurrentWeightStage(stage)
    stage = math.clamp(math.floor(stage), 1, #adipose.weightStages+1)
    adipose.setWeight(calculateWeightFromIndex(stage))
end

function adipose.adjustWeightByAmount(amount)
    amount = math.clamp((adipose.currentWeight + math.floor(amount)), adipose.minWeight, adipose.maxWeight)
    adipose.setWeight(amount)
end

function adipose.adjustWeightByStage(amount)
    amount = math.clamp((adipose.currentWeightStage + math.floor(amount)), 1, #adipose.weightStages+1)
    adipose.setWeight(calculateWeightFromIndex(amount) + 1)-- +1 is padding for hunger decay
end

-- WEIGHT STAGE
---@class Adipose.WeightStage[]
adipose.weightStages = {}
adipose.weightStage = {}
adipose.weightStage.__index = adipose.weightStage

---@return table
function adipose.weightStage:newStage()
    local obj = setmetatable({
        partsList = {},
        granularAnim = '',
		stuffedAnim = '',
        scalingList = {}
    }, self)

    table.insert(adipose.weightStages, obj)
    return obj
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

---@param animation animations
---@return self
function adipose.weightStage:setStuffedAnimation(animation)
    self.stuffedAnim = animation
    return self
end

---@param scaling table<string, boolean>
---@return self
function adipose.weightStage:setScaling(scaling)
    self.scalingList = scaling
    return self
end

return adipose
