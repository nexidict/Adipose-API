---@class Adipose
local adipose = {}

-- FLAGS
adipose.hitbox = true
adipose.motion = true
local previousHitboxValue = adipose.hitbox

-- VARIABLES
local maxWeight = 1000 -- The highest weight you can be
local minWeight = 100 -- The lowest weight you can be
local currentWeight = minWeight --how much you weigh currently

local syncTimerReset = 10
local syncTimer = 0


local weightStage = 1 --what stage you are at (default 1)


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
        headOffset = 1,
        hitboxWidth = 1,
        hitboxHeight = 1,
        motion = 1
    }, adipose.weightStage)

    table.insert(adipose.weightStages, self)
    return self
end

local function updateWeightStage()
    --get current weight stage
    --clamp to bounds
    --is the value actually different?
    if local oldWeightStage ~= weightStage then
        
        --change visual 

        oldWeightStage = weightStage
    end


function adipose.weightStage:tick()
    if not player:isLoaded() then return end --ensure model is loaded

    updateWeightStage()


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
function adipose.weightStage:setHeadOffset(offset)
    self.headOffset = offset
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

-- WEIGHT DRIVER

local function updateALL()
    if not player:isLoaded() then return end
	pings.syncWeight(currentWeight)
	calculateProgress() --update underlying variables
	--for _, w in ipairs(adipose.weightStages) do w:tick() end -- update the visiblity of all modelparts within weightstages
	--updateGranularWG() --
	--updateHitbox()
	--updateHeadOffset()
end

local function calculateProgress() -- determine progress value
    currentWeight = math.clamp(currentWeight, minWeight,  maxWeight)
    local absWeight = (currentWeight-minWeight)/(maxWeight-minWeight) -- on a scale of 0 to 1, how fat are you?
  
    local progress = (absWeight * (#weightStages-1)) + 1 --"weightStage + granularWeight"
  
    weightStage = math.floor(progress)
    --granularWeight = progress - weightStage
end

local function syncWeight (val) -- synchronize currentWeight
	currentWeight = val
	--print(currentWeight)
end
pings.syncWeight = syncWeight

-- PEHKUI METHODS


-- FLAGS METHODS
---@return boolean
function adipose.getHitboxState()
    return adipose.hitbox
end

---@return boolean
function adipose.getMotionState()
    return adipose.motion
end

---@param state boolean
function adipose.setHitboxState(state)
    adipose.hitbox = state
end

---@param state boolean
function adipose.setMotionState(state)
    adipose.motion = state
end

-- EVENTS
function events.entity_init()
    
    --pull weight from a config
end

function events.tick()
    
    -- sync
    if syncTimer < 0 then
        updateALL() 
        syncTimer = syncTimerReset
    else
        syncTimer = syncTimer - 1
    end
    
      
end




return adipose
