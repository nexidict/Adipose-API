local adipose = require("Adipose")

-- hide vanilla model
vanilla_model.PLAYER:setVisible(false)

-- hide vanilla armor model
vanilla_model.ARMOR:setVisible(false)

-- hide vanilla cape model
vanilla_model.CAPE:setVisible(false)

-- hide vanilla elytra model
vanilla_model.ELYTRA:setVisible(false)

-- Override verbose flag

adipose.verbose = true

-- Add new scaling option

adipose.pehkui.BASE = "pehkui:base"
adipose.pehkui.enabled[adipose.pehkui.BASE] = true

-- Weight Stages

adipose.newStage()
	:setParts(models.stage1)
	:addScaleOption(adipose.pehkui.HITBOX_WIDTH, 1.00, 1.25)
	:addScaleOption(adipose.pehkui.MOTION, 1.00)
	:addScaleOption(adipose.pehkui.BASE, 1.00)

adipose.newStage()
	:setParts(models.stage2)
	:addScaleOption(adipose.pehkui.HITBOX_WIDTH, 1.25, 1.75)
	:addScaleOption(adipose.pehkui.MOTION, 0.95)
	:addScaleOption(adipose.pehkui.BASE, 1.05)

adipose.newStage()
	:setParts(models.stage3)
	:addScaleOption(adipose.pehkui.HITBOX_WIDTH, 1.75, 2.25)
	:addScaleOption(adipose.pehkui.MOTION, 0.90)
	:addScaleOption(adipose.pehkui.BASE, 1.10)

adipose.newStage()
	:setParts(models.stage4)
	:addScaleOption(adipose.pehkui.HITBOX_WIDTH, 2.25, 2.65)
	:addScaleOption(adipose.pehkui.MOTION, 0.85)
	:addScaleOption(adipose.pehkui.BASE, 1.15)

adipose.newStage()
	:setParts(models.stage5)
	:addScaleOption(adipose.pehkui.HITBOX_WIDTH, 2.65, 3.00)
	:addScaleOption(adipose.pehkui.MOTION, 0.80)
	:addScaleOption(adipose.pehkui.BASE, 1.20)

function events.entity_init()
	models.stage1:setPrimaryTexture("SKIN")
	models.stage2:setPrimaryTexture("SKIN")
	models.stage3:setPrimaryTexture("SKIN")
	models.stage4:setPrimaryTexture("SKIN")
	models.stage5:setPrimaryTexture("SKIN")
end

-- Action Wheel

local mainPage = action_wheel:newPage()
action_wheel:setPage(mainPage)

local function printWeight()
	if adipose.verbose then
		print("Weight:", adipose.currentWeight)
		print("Stage:", adipose.currentWeightStage)
	end
end

mainPage:newAction()
	:title("Cycle Weight")
	:item("minecraft:cake")
	:onScroll(function(dir)
		adipose.adjustWeightByAmount(dir * 25)
		printWeight()
	end)
	:onLeftClick(function()
		adipose.adjustWeightByStage(1)
		printWeight()
	end)
	:onRightClick(function()
		adipose.adjustWeightByStage(-1)
		printWeight()
	end)

print("================")
print("Welcome to Adipose!")
print("Action wheel usage:")
print(" - Left Click: Increase stage.")
print(" - Right Click: Decrease stage.")
print(" - Scroll: Adjust weight.")
print("Press F3+B to show hitboxes.")
print("================")