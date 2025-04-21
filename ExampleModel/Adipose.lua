---@class Adipose
local adipose = {}

-- FLAGS
adipose.hitbox = true
adipose.motion = true
adipose.eyeHeight = true

-- WEIGHT STAGE
---@class Adipose.WeightStage[]
adipose.weightStages = {}
adipose.weightStage = {}
adipose.weightStage.__index = adipose.weightStage
adipose.currentWeightStage = 1

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
    print('Width', width)
    host:sendChatCommand('scale set pehkui:hitbox_width '..width..' @s')
end

function adipose.setHitboxHeight(height)
    print('Height', height)
    host:sendChatCommand('scale set pehkui:hitbox_height '..height..' @s')
end

function adipose.setMotion(motion)
    print('Motion', motion)
    host:sendChatCommand('scale set pehkui:motion '..motion..' @s')
end

function adipose.setEyeHeight(offset)
    print('Eye height', offset)
    host:sendChatCommand('scale set pehkui:eye_height '..offset..' @s')
end

-- FLAGS METHODS
---@return boolean
function adipose.getHitboxState()
    return adipose.hitbox
end

---@return boolean
function adipose.getMotionState()
    return adipose.motion
end

---@return boolean
function adipose.getEyeHeightState()
    return adipose.eyeHeight
end

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

function events.tick()

    --sync
    for _, w in ipairs(adipose.weightStages) do w:tick() end
end

function events.entity_init()
    repeat
        if #adipose.weightStages ~= 0 then
            adipose.setHitboxWidth(adipose.weightStages[1].hitboxWidth)
            adipose.setHitboxHeight(adipose.weightStages[1].hitboxHeight)
            adipose.setMotion(adipose.weightStages[1].motion)
            adipose.setEyeHeight(adipose.weightStages[1].eyeHeight)
        end

        return
    until (#adipose.weightStages == 0)
end


return adipose
