local adipose = require('Adipose')


--hide vanilla model
vanilla_model.PLAYER:setVisible(false)

--hide vanilla armor model
vanilla_model.ARMOR:setVisible(false)

--hide vanilla cape model
vanilla_model.CAPE:setVisible(false)

--hide vanilla elytra model
vanilla_model.ELYTRA:setVisible(false)

--Weight Stages

--Stage 1

adipose.weightStage:newStage()
	:setParts({models.stage1})

adipose.weightStage:newStage()
	:setParts({models.stage2})
	:setHitboxWidth(1.25)
	
adipose.weightStage:newStage()
	:setParts({models.stage3})
	:setHitboxWidth(1.75)
adipose.weightStage:newStage()
	:setParts({models.stage4})	
	:setHitboxWidth(2.25)

adipose.weightStage:newStage()
	:setParts({models.stage5})
	:setHitboxWidth(2.65)
	
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

local weightTrigger = mainPage:newAction()
	:title("Cycle Weight")
	:item("minecraft:cake")
	:onScroll(function(dir) adipose.adjustWeightByAmount(dir * 25) end)
	:onLeftClick(function() adipose.adjustWeightByStage(1) end )	
	:onRightClick(function() adipose.adjustWeightByStage(-1) end )	




