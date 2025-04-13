local adipose = require('Adipose')

--hide vanilla model
vanilla_model.PLAYER:setVisible(false)

--hide vanilla armor model
vanilla_model.ARMOR:setVisible(false)

--hide vanilla cape model
vanilla_model.CAPE:setVisible(false)

--hide vanilla elytra model
vanilla_model.ELYTRA:setVisible(false)

--headPositions = {26.325, 35}--NOT IMPORTANT PLEASE FUCKING REMOVE I SWEAR TO CHRIST

-- SCRIPT ACTIONS

-- Action Wheel
local mainPage = action_wheel:newPage()
action_wheel:setPage(mainPage)

local weightTrigger = mainPage:newAction()
:title("Cycle Weight")
:item("minecraft:cake")
:onScroll(function(dir) NudgeWeight(dir) end)



local stage0 = {
	models.model.BodyW0,
	models.model.TailW0,
	models.model.LeftArmW0,
	models.model.RightArmW0,
	models.model.LeftLegW0,
	models.model.RightLegW0
}
adipose.weightStage:new(
	stage0, --modelParts
	animations.model.W0, --Granular anim
	nil, --Head offset
	nil, --Hitbox Width
	nil, --Hitbox Height
	nil
)

stage1 = {
	models.model.BodyW1,
	models.model.TailW1,
	models.model.LeftArmW0,
	models.model.RightArmW0,
	models.model.LeftLegW1,
	models.model.RightLegW1
	}
adipose.weightStage:new(
	stage1, --modelParts
	animations.model.W1, --Granular anim
	nil, --Head offset
	nil, --Hitbox Width
	nil, --Hitbox Height
	nil
)

stage2 = {
	models.model.BodyW2,
	models.model.TailW1,
	models.model.LeftArmW2,
	models.model.RightArmW2,
	models.model.LeftLegW2,
	models.model.RightLegW2
	}
adipose.weightStage:new(
	stage2, --modelParts
	animations.model.W2, --Granular anim
	nil, --Head offset
	nil, --Hitbox Width
	nil, --Hitbox Height
	nil
)

stage3 = {
	models.model.HeadW3,
	models.model.BodyW3,
	models.model.TailW3,
	models.model.LeftArmW3,
	models.model.RightArmW3,
	models.model.LeftLegW3,
	models.model.RightLegW3
	}
adipose.weightStage:new(
	stage3, --modelParts
	animations.model.W3, --Granular anim
	nil, --Head offset
	nil, --Hitbox Width
	nil, --Hitbox Height
	nil
)

stage4 = {
	models.model.HeadW3,
	models.model.BodyW4,
	models.model.TailW4,
	models.model.LeftArmW4,
	models.model.RightArmW4,
	models.model.LeftLegW4,
	models.model.RightLegW4
	}
adipose.weightStage:new(
	stage4, --modelParts
	nil, --Granular anim
	nil, --Head offset
	nil, --Hitbox Width
	nil, --Hitbox Height
	nil
)