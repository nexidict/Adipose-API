---@class Adipose
local adipose = {}

-- CONSTANTS
adipose.minWeight = 100
adipose.maxWeight = 1000

adipose.weightRate = 0.1

adipose.pehkui = {
    HITBOX_WIDTH =  'pehkui:hitbox_width',
    HITBOX_HEIGHT = 'pehkui:hitbox_height',
    MOTION =        'pehkui:motion',
    EYE_HEIGHT =    'pehkui:eye_height',
}

-- VARIABLES
adipose.currentWeight = config:load("adipose.currentWeight") or adipose.minWeight
adipose.granularWeight = 0
adipose.currentWeightStage = config:load("adipose.currentWeightStage") or 1
adipose.stuffed = 0 
adipose.syncTimer = 100
local timer = adipose.syncTimer
local oldindex = nil

adipose.scaling = true

-- FLAGS
adipose.hitbox = true
adipose.motion = true
adipose.eyeHeight = true

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

function adipose.setScale(scale, value)
    if not player:isLoaded() or not adipose.pehkuiCheck or not adipose.scaling then return end
	
	if adipose.opCheck then 
		host:sendChatCommand('scale set '..scale..' '..value..' @s')
	elseif adipose.p4aCheck then 
		local prefixIndex = string.find(scale, ":")
		scale = string.sub(scale, prefixIndex+1,-1) --this command is also ass, returns scale without a prefix because god's light doesnt shine here
		host:sendChatCommand('lesserscale set '..value..' '..scale)		
	elseif adipose.ggCheck then
		local prefixIndex = string.find(scale, ":")
		scale = string.sub(scale, prefixIndex+1,-1) --this command is ass, returns scale without a prefix because abyssal didnt take my suggestion
		host:sendChatCommand('ggconfig adipose.setScale '..scale..' '..value)
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
pings.setModelPartsVisibility=setModelPartsVisibility

local function setGranularity(index, granularity)
	for i, weightStage in ipairs(adipose.weightStages) do 
	    local animation = adipose.weightStages[i].granularAnim
		
		if animation ~= '' then
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
pings.setGranularity=setGranularity

local stuffedOverride = nil
local function setStuffed(index, stuffed)
	for i, weightStage in ipairs(adipose.weightStages) do 
	    local animation = adipose.weightStages[i].stuffedAnim
		
		if animation ~= '' then
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
pings.setStuffed = setStuffed

function adipose.setStuffedOverride(stuffed)
    stuffedOverride = stuffed
end

-- EVENTS
function events.tick()
    if timer < 0 then 
        timer = adipose.syncTimer
        
		if not adipose.ggCheck then --Update the weight value
			local deltaWeight = checkFood() --All things that affect weight 
			adipose.currentWeight = adipose.currentWeight + deltaWeight 
		else
			adipose.currentWeight = player:getNbt()["ForgeCaps"]["gluttonousgrowth:weightbar"]["currentweight"] --ignore everything and just sync with overstuffed 
		end
		
		local packet = math.floor(adipose.currentWeight*10)/10
		--print(packet)
		adipose.setWeight(packet) -- set weight to current value
    else 
		timer = timer - 1
	end
end

function events.entity_init()
	if #adipose.weightStages == 0 then return end
	
	adipose.ggCheck = client.isModLoaded("gluttonousgrowth")
	
	if adipose.ggCheck then 
		local GGWeightBar = player:getNbt()["ForgeCaps"]["gluttonousgrowth:weightbar"]
		
		adipose.maxWeight = GGWeightBar["maxweight"]
		adipose.minWeight = GGWeightBar["minweight"]
		adipose.currentWeight = GGWeightBar["currentweight"]
		
		--print(adipose.maxWeight)
		--print(adipose.minWeight)
		--print(adipose.currentWeight)
	end
	
	adipose.pehkuiCheck = client.isModLoaded("pehkui")
	adipose.p4aCheck = client.isModLoaded("pehkui4all")
	adipose.essentialCheck = client.isModLoaded("essential")
	
	if not adipose.essentialCheck then 
	adipose.opCheck = player:getPermissionLevel() == 4
	else
	adipose.opCheck = false
	end
	
	--IF YOU HATE THE STARTUP MESSAGE THIS IS THE THING TO DELETE! \/
	
	--Scaling Startup Message
	if adipose.scaling then
		if adipose.pehkuiCheck then
			if adipose.opCheck then
				print("OP Detected, Using /scale for Scaling")
			elseif adipose.p4aCheck then
				print("Pehkui 4 All Detected, Using /lesserscale for Scaling")
			elseif adipose.ggCheck then
				print("Gluttonous Growth Detected, Using /ggconfig setScale for Scaling")
			else
				print("Insufficient Permissions for Scaling, Scaling Disabled")
			end	
		else
			print("Pehkui not Installed, Scaling Disabled")
		end
	else 
	
	print("Scaling Manually Disabled")		
	end
	--IF YOU HATE THE STARTUP MESSAGE THIS IS THE THING TO DELETE! /\

    adipose.setScale(adipose.pehkui.HITBOX_WIDTH, adipose.weightStages[1].hitboxWidth)
    adipose.setScale(adipose.pehkui.HITBOX_HEIGHT, adipose.weightStages[1].hitboxHeight)
    adipose.setScale(adipose.pehkui.MOTION, adipose.weightStages[1].motion)
    adipose.setScale(adipose.pehkui.EYE_HEIGHT, adipose.weightStages[1].eyeHeight)
	
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


	if oldindex ~= index then
		oldindex = index
		local stage = adipose.weightStages[index]
		adipose.setScale(adipose.pehkui.HITBOX_WIDTH, stage.hitboxWidth)
		adipose.setScale(adipose.pehkui.HITBOX_HEIGHT, stage.hitboxHeight)
		adipose.setScale(adipose.pehkui.MOTION, stage.motion)
		adipose.setScale(adipose.pehkui.EYE_HEIGHT, stage.eyeHeight)
    end
	
	pings.setModelPartsVisibility(index)
  
	local stuffed = 0
	if not adipose.ggCheck then
		stuffed = player:getSaturation()/20
	else
		local curCalories = player:getNbt()["ForgeCaps"]["gluttonousgrowth:calmeter"]["curcalories"] or 0
		stuffed = curCalories/player:getNbt()["ForgeCaps"]["gluttonousgrowth:calmeter"]["maxcalories"]
	end
	
	
	adipose.granularWeight = granularity
	adipose.stuffed = stuffed
	
	
	pings.setGranularity(index, granularity)
	pings.setStuffed(index, stuffed)
	
	--print(index , granularity)

    if not adipose.ggCheck and host:isHost() then 
        config:save("adipose.currentWeight", math.floor(adipose.currentWeight*10)/10)
        config:save("adipose.currentWeightStage", adipose.currentWeightStage)
    end
end

---@param stage number
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
        hitboxWidth = 1,
        hitboxHeight = 1,
        eyeHeight = 1,
        motion = 1
    }, adipose.weightStage)

    table.insert(adipose.weightStages, obj)
    return obj
end


-- WEIGHT STAGE METHODS
---@param parts ModelPart|[ModelPart]
---@return self
function adipose.weightStage:setParts(parts)
    assert(type(parts) == 'ModelPart' or type(parts) == 'table', "Invalid parts")

    -- Validate contents of the table
    if type(parts) == 'table' then
        for i, p in ipairs(parts) do
            assert(type(p) == 'ModelPart', "Invalid part "..tostring(i))
        end 
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

-- FLAGS METHODS
---@param state boolean
function adipose.setHitboxState(state)
    local previousValue = adipose.hitbox

    if state ~= previousValue then
        adipose.hitbox = state

        if state == true then
            adipose.setScale(adipose.pehkui.HITBOX_WIDTH, adipose.weightStages[adipose.currentWeightStage].hitboxWidth)
            adipose.setScale(adipose.pehkui.HITBOX_HEIGHT, adipose.weightStages[adipose.currentWeightStage].hitboxHeight)
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