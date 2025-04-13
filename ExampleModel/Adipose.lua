---Local variables
local maxWeight = 1000
local minWeight = 100
local currentWeight = minWeight
local absWeight = 0
local timer = 0 --timer for sync
local digestTimer = 0 --how often the model adds weight, affects weight gain and loss rate
local granularWeight = 0 -- how close are you to the next weight stage?
local weightStage = 1 --what stage you are at (default 1)
local weightRate = 0.001 --affects the speed of weight gain and loss

---@class Adipose
local adipose = {}

-- VARIABLES
adipose.hitbox = true
adipose.motion = true

---@class Adipose.WeightStage[]
adipose.weightStages = {}
adipose.weightStage = {}
adipose.weightStage.__index = adipose.weightStage

---@param partsList table<Models|ModelPart> The list of each model part that involves weight gain
---@param granularAnim any Animation used for granular elements
---@param headOffset any Pehkui headOffset value
---@param hitboxWidth number Pehkui hitboxWidth
---@param hitBoxHeight number Pehkui hitboxHeight
---@param motion any Pehkui motion
---@param name string Debugging
---@return Adipose.WeightStage
function adipose.weightStage:new(partsList, granularAnim, headOffset, hitboxWidth, hitBoxHeight, motion)
    local self = setmetatable({}, adipose.weightStage)

    -- Handle single model inputs
    if type(partsList) ~= 'table' then
        if type(partsList) == 'ModelParts' or type(partsList) == 'models' then
            partsList = {partsList}
        else
            error("partsList must be a table or a ModelPart/Models object")
        end
    end

    -- Validate contents of the table
    for i, part in ipairs(partsList) do
        if type(part) == 'ModelParts' or type(part) == 'models' then
            error("The body part at position "..i.." is not a models or a ModelPart")
        end
    end
    self.partsList = partsList

    self.granularAnim = granularAnim or ''
    self.headOffset = headOffset or 0
    self.hitboxWidth = hitboxWidth or 1
    self.hitboxHeight = hitBoxHeight or 1
    self.motion = motion or 1

    function self:tick()
        
    end

    table.insert(adipose.weightStages, self)
    return self
end

---@class Adipose.SetHitboxState
---@param state boolean
function adipose.setHitboxState(state)
    adipose.hitbox = state
end

---@class Adipose.GetHitboxState
---@return state boolean
function adipose.getHitboxState()
    return aidpose.hitbox
end

---@class Adipose.SetMotionState
---@param state boolean
function adipose.setMotionState(state)
    adipose.motion = state
end

---@class Adipose.GetMotionState
---@return state boolean
function adipose.getMotionState()
    return aidpose.motion
end

function events.tick()
    for _, w in ipairs(adipose.weightStages) do w:tick() end
end

return adipose
