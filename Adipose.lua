---@class Adipose
local adipose = {}

-- CONSTANTS
adipose.minWeight = 100
adipose.maxWeight = 1000

-- VARIABLES
adipose.currentWeight = config:load("adipose.currentWeight") or adipose.minWeight
adipose.currentWeightStage = config:load("adipose.currentWeightStage") or 1
adipose.granularWeight = 0
adipose.stuffed = 0

local oldindex = nil
local isDead = false
local knownReceivers = {}
local timerDuration = 40
local timer = timerDuration

adipose.scaling = true

-- FUNCTIONS
adipose.onWeightChange = function(_, _, _, _) end

--- Sets function that will be called when weight stage changes
--- @param callback fun(weight: number, index: number, granularity: number, stuffed: number)
function adipose.setOnWeightChange(callback)
    adipose.onWeightChange = callback
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

local function doTimer()
    if timer > 0 then
        timer = timer - 1
        return false
    else
        timer = timerDuration
        return true
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

local function setGranularity(index, granularity)
    for i, stage in ipairs(adipose.weightStages) do 
	    local animation = stage.granularAnim

		if animation then
			if index == i then
				animation:play()
				animation:setSpeed(0)

				local offset = animation:getLength() * granularity
				animation:setOffset(offset)
			else
				animation:stop()
			end
		end
	end
end

local stuffedOverride = nil
local function setStuffed(index, stuffed)
    for i, stage in ipairs(adipose.weightStages) do 
	    local animation = stage.stuffedAnim

		if animation then
			if index == i then
				if stuffedOverride then stuffed = stuffedOverride end    
			    animation:play()
				animation:setSpeed(0)

				local offset = animation:getLength() * stuffed
				animation:setOffset(offset)	
			else
				animation:stop()
			end
		end
	end
end

-- EVENTS
function events.tick()
    if player:getHealth() <= 0 then 
        -- When the entity just died and the death screen appears
        if not isDead then isDead = true end
    else
        if isDead then
            pings.AdiposeSetWeight(adipose.currentWeight, true)
            isDead = false
        end
    end
end

function events.tick()
    if not doTimer() then return end

    local doPing = false
    local newReceivers = {}

    for _, v in pairs(world:getPlayers()) do
        local uuid = v:getUUID()

        if uuid ~= avatar:getUUID() then
            newReceivers[uuid] = true

            if not knownReceivers[uuid] then doPing = true end
        end
    end

    knownReceivers = newReceivers
    if doPing then pings.AdiposeSetWeight(adipose.currentWeight, true) end
end

if host:isHost() then
    local initTimer = 25

    events.TICK:register(function ()
        if initTimer > 0 then
            initTimer = initTimer - 1
            return
        end

        pings.AdiposeSetWeight(adipose.currentWeight)
        events.TICK:remove("InitAdiposeModel")
    end, "InitAdiposeModel")
end

-- WEIGHT MANAGEMENT
function adipose.setWeight(amount, forceUpdate)    
    if #adipose.weightStages == 0 then return end	

    amount = math.clamp(amount, adipose.minWeight, adipose.maxWeight)
		
    local index, granularity = calculateProgressFromWeight(amount)
    local stuffed = player:isLoaded() and player:getSaturation()/20 or 0

    adipose.currentWeight = amount
    adipose.currentWeightStage = index
    adipose.granularWeight = granularity
    adipose.stuffed = stuffed

    if oldindex ~= index or forceUpdate then
        oldindex = index
        adipose.onWeightChange(amount, index, granularity, stuffed)
        setModelPartsVisibility(index)
    end
	
	setGranularity(index, granularity)
	setStuffed(index, stuffed)

    config:save("adipose.currentWeight", math.floor(adipose.currentWeight*10)/10)
    config:save("adipose.currentWeightStage", adipose.currentWeightStage)
end
pings.AdiposeSetWeight = adipose.setWeight

function adipose.setCurrentWeightStage(stage)
    stage = math.clamp(math.floor(stage), 1, #adipose.weightStages+1)
    pings.AdiposeSetWeight(calculateWeightFromIndex(stage))
end

function adipose.adjustWeightByAmount(amount)
    amount = math.clamp((adipose.currentWeight + math.floor(amount)), adipose.minWeight, adipose.maxWeight)
    pings.AdiposeSetWeight(amount)
end

function adipose.adjustWeightByStage(amount)
    amount = math.clamp((adipose.currentWeightStage + math.floor(amount)), 1, #adipose.weightStages+1)
    pings.AdiposeSetWeight(calculateWeightFromIndex(amount))
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
        granularAnim = nil,
		stuffedAnim = nil,
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

---@param scaling table<string, number>
---@return self
function adipose.weightStage:setScaling(scaling)
    self.scalingList = scaling
    return self
end

return adipose