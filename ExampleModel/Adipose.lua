---@class Adipose
local adipose = {}

-- FLAGS
adipose.hitbox = true
adipose.motion = true
local previousHitboxValue = adipose.hitbox

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

function adipose.weightStage:tick()

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

function events.tick()

    --sync
    for _, w in ipairs(adipose.weightStages) do w:tick() end
end




return adipose
