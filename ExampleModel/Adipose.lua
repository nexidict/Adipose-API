---@class Adipose
local adipose = {}

-- CONFIG
config:setName("Adipose.Config")

-- CONSTANTS
adipose.minWeight = 100
adipose.maxWeight = 1000

adipose.weightRate = 0.01
adipose.updateDelay = 10 --Ticks until next update is parsed

adipose.pehkui = {
    HITBOX_WIDTH =  'pehkui:hitbox_width',
    HITBOX_HEIGHT = 'pehkui:hitbox_height',
    MOTION =        'pehkui:motion',
    EYE_HEIGHT =    'pehkui:eye_height',
}

-- VARIABLES
adipose.currentWeight = config:load("adipose.currentWeight") or adipose.minWeight
adipose.granularWeight = 0
adipose.currentWeightStage = 1

adipose.syncTimer = 10
adipose.digestTimer = 0

-- FLAGS
adipose.hitbox = true
adipose.motion = true
adipose.eyeHeight = true

-- FUNCTIONS
function SyncWeight(amount)
	adipose.SetWeight(amount)
end
pings.SyncWeight = SyncWeight

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

local function setGranularity(index, granularity)
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
        timer = adipose.updateDelay
        
		adipose.SetWeight(checkFood())
		pings.SyncWeight(adipose.currentWeight)
		
    else timer = timer - 1 end
    
    adipose.syncTimer = timer 
end

function events.entity_init()
    if #adipose.weightStages == 0 then return end
	
	adipose.pehkuiCheck = client:isModLoaded("pehkui")
	adipose.p4aCheck = client:isModLoaded("pehkui4all")
	adipose.opCheck = player:getPermissionLevel() == 4   
	
	--IF YOU HATE THE STARTUP MESSAGE THIS IS THE THING TO DELETE! \/
	
	--Scaling Startup Message
	if adipose.pehkuiCheck then
		if adipose.opCheck then
			print("OP Detected, Using /scale for Scaling")
		elseif adipose.p4aCheck then
			print("Pehkui 4 All Detected Using /lesserscale for Scaling")
		else
			print("Insufficient Permissions for Scaling, Scaling Disabled")
		end	
	else
		print("Pehkui not Installed, Scaling Disabled")
	end
	
	--IF YOU HATE THE STARTUP MESSAGE THIS IS THE THING TO DELETE! /\

    adipose.setScale(adipose.pehkui.HITBOX_WIDTH, adipose.weightStages[1].hitboxWidth)
    adipose.setScale(adipose.pehkui.HITBOX_HEIGHT, adipose.weightStages[1].hitboxHeight)
    adipose.setScale(adipose.pehkui.MOTION, adipose.weightStages[1].motion)
    adipose.setScale(adipose.pehkui.EYE_HEIGHT, adipose.weightStages[1].eyeHeight)
end

-- WEIGHT MANAGEMENT
function adipose.SetWeight(amount)
    amount = math.clamp(amount, adipose.minWeight, adipose.maxWeight)
    local index, granularity = calculateProgressFromWeight(amount)

    adipose.currentWeight = amount
    adipose.currentWeightStage = index

    adipose.granularWeight = granularity

    local stage = adipose.weightStages[index]
    adipose.setScale(adipose.pehkui.HITBOX_WIDTH, stage.hitboxWidth)
    adipose.setScale(adipose.pehkui.HITBOX_HEIGHT, stage.hitboxHeight)
    adipose.setScale(adipose.pehkui.MOTION, stage.motion)
    adipose.setScale(adipose.pehkui.EYE_HEIGHT, stage.eyeHeight)

    setModelPartsVisibility(index)
    setGranularity(index, granularity)
	
	--print(index , granularity)

    config:save("adipose.currentWeight", adipose.currentWeight)
end

function adipose.setCurrentWeightStage(stage)
    stage = math.clamp(math.floor(stage), 1, #adipose.weightStages+1)
    adipose.SetWeight(calculateWeightFromIndex(stage))
end

function adipose.adjustWeightByAmount(amount)
    amount = math.clamp((adipose.currentWeight + math.floor(amount)), adipose.minWeight, adipose.maxWeight)
    adipose.SetWeight(amount)
end

function adipose.adjustWeightByStage(amount)
    amount = math.clamp((adipose.currentWeightStage + math.floor(amount)), 1, #adipose.weightStages+1)
    adipose.SetWeight(calculateWeightFromIndex(amount))
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
function adipose.setScale(scale, value)
    if not player:isLoaded() or not adipose.pehkuiCheck then return end

	if adipose.opCheck then 
		host:sendChatCommand('scale set '..scale..' '..value..' @s')
	elseif adipose.p4aCheck then 
		local prefixIndex = string.find(scale, ":")
		scale = string.sub(scale, prefixIndex+1,-1) --this command is ass, returns scale without a prefix because god's light doesnt shine here
		host:sendChatCommand('lesserscale set '..value..' '..scale)
	end
end

-- FLAGS METHODS
---@param state boolean
function adipose.setHitboxState(state)
    local previousValue = adipose.hitbox

    if state ~= previousValue then
        adipose.hitbox = state

        if state == true then
            adipose.setScale(adipose.pehkui.HITBOX_WIDTH, adipose.weightStages[adipose.currentWeightStage].hitboxWidth)
            adipose.setScale(adipose.pehkui.HITBOX_HEIGHT, adipose.weightStages[adipose.currentWeightStage].hitboxWidth)
            return
        end

        adipose.setScale(adipose.pehkui.HITBOX_WIDTH, 1)
        adipose.setScale(adipose.pehkui.HITBOX_HEIGHT, 1)
        return
    end
end

---@param state boolean
function adipose.setMotionState(state)
    local previousValue = adipose.motion

    if state ~= previousValue then
        adipose.motion = state

        if state == true then
            adipose.setScale(adipose.pehkui.MOTION, adipose.weightStages[adipose.currentWeightStage].motion)
            return
        end

        adipose.setScale(adipose.pehkui.MOTION, 1)
        return
    end
end

---@param state boolean
function adipose.setEyeHeightState(state)
    local previousValue = adipose.eyeHeight

    if state ~= previousValue then
        adipose.eyeHeight = state

        if state == true then
            adipose.setScale(adipose.pehkui.EYE_HEIGHT, adipose.weightStages[adipose.currentWeightStage].eyeHeight)
            return
        end

        adipose.setScale(adipose.pehkui.EYE_HEIGHT, 1)
        return
    end
end

return adipose