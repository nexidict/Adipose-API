--wgAPI (Name Pending I Hope) V0.01 PRERELEASE Build

--Current list of shit i need to finish
--(X)Change visible model parts for StagedWG
--(X)Anim indexing for GranularWG
--( )Weight gain and loss from food .w.

--( )New Stage metatables
--( )Head offset adjustment
--( )Hitbox adjustment


local maxWeight = 1000 -- The highest weight you can be
local minWeight = 100 -- The lowest weight you can be
local currentWeight = minWeight --how much you weigh currently

local absWeight = 0

local timer = 0 --timer for sync
local digestTimer = 0 --how often the model adds weight, affects weight gain and loss rate


local weightAnims = {} -- each granular anim related to each weight stage
local granularWeight = 0 -- how close are you to the next weight stage?

local weightStages = {} -- list of lists of model parts associated with each stage
local weightStage = 1 --what stage you are at (default 1)

local headPos = {} -- the desired head position for each weight stage

local weightRate = 0.001 --affects the speed of weight gain and loss



local function updateWeightStage() --Update current weight stage

  weightStage = math.clamp(weightStage,1,#weightStages) --clamp weight to valid values

  for stage in ipairs(weightStages) do --iterate through weightStages and every "size" in weightStages to ensure only the modelparts in the index equal to the current weightStage are visible
    local size = weightStages[stage]

    for part in ipairs(weightStages[stage]) do
      size[part]:setVisible(weightStage == stage)
    end
  end

  for part in ipairs(weightStages[weightStage]) do --to ensure duplicate parts can be used in weight stages, double check the current stage to reenable anything mistakenly disabled by the last step .w.
    weightStages[weightStage][part]:setVisible(true)
  end

	--an optimization can definitely be made here
end

local function updateGranularWG()

	local currentGranularAnim = weightAnims[weightStage]
	if currentGranularAnim == "" then return end

	currentGranularAnim:play()
	currentGranularAnim:setSpeed(0)

	local granularAnimOffset = currentGranularAnim:getLength() * granularWeight
	currentGranularAnim:setOffset(granularAnimOffset)
end


local function updateHitbox()

  --check if pehkui is installed
  --check if player has operator
  --check if pehcompi is installed

  --deal with this shit later

end

local function foodCheck()

	if player:getSaturation() > 2 then
		currentWeight = currentWeight + (player:getSaturation() - 2)*weightRate*digestTimer
	end

	if player:getFood() < 17 then
		currentWeight = currentWeight - (17 - player:getFood())*weightRate*digestTimer
	end

end

local function calculateProgress() -- determine progress value
  currentWeight = math.clamp(currentWeight, minWeight,  maxWeight)
  absWeight = (currentWeight-minWeight)/(maxWeight-minWeight) -- on a scale of 0 to 1, how fat are you?

  local progress = (absWeight * (#weightStages-1)) + 1 --"weightStage + granularWeight"

  weightStage = math.floor(progress)
  granularWeight = progress - weightStage

end

local function updateAll()
	if not player:isLoaded() then return end
	pings.syncWeight()
	calculateProgress()
	updateWeightStage()
	updateGranularWG()
	--updateHitbox()
	--updateHeadOffset()
end

function NewWeightStage(parts,granularAnim,headOffset,hitboxWidth,hitBoxHeight) --makes a new weight stage

	if type(parts)~="table" then return end --verify "parts" is a table so everything doesnt fucking EXPLODE
	table.insert(weightStages,parts) --shove parts at the end of the list

	if granularAnim == nil then granularAnim = "" end
	table.insert(weightAnims,granularAnim) --shove an animation in the granular list
	--insert head offset relevant code here

	--insert hitbox relevant code here
end

function SetWeightStage(val) --forces the weight to a value --marked for change
	weightStage = val
end

function GetWeightStage() --return current weight stage
	return weightStage
end

function GetWeightStages() --return weight stage array
  return weightStages
end

function NudgeWeightStage(input) --shifts weight by an amount
  weightStage = weightStage + input
  updateAll()
end

function NudgeWeight(input) --shifts weight by an amount
  currentWeight = currentWeight + input * 10
  updateAll()
end

local function syncWeight ()
	currentWeight = currentWeight
	print(currentWeight)
end

pings.syncWeight = syncWeight

function events.tick()
  --Weight Stage
  --updateWeightStage() --Do i need this?

	if timer < 0 then

	updateAll()

	timer = 10
	else
	timer = timer - 1
	end

	if digestTimer < 0 then
	digestTimer = 10
	foodCheck()
	else
	digestTimer = digestTimer - 1
	end

end

function events.entity_init()
	updateAll()
end
--DEBUG

