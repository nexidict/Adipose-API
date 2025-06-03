# 🍔 Adipose API 
Figura library that adds Weight Gain functionality with animation support.

- [Features](#️-features)
- [Installation](#️-installation)
- [Functions](#-functions)

## ⚙️ Features
- **Staged Based Weight Gain**: designate Weight Stages with different modelparts or even whole models.
- **Granular Weight Gain**: use an animation to smooth out the transition between stages.
- **Stuffed Animation**: use an animation to reflect stomach fullness.
- **Weight Saving via Config**: your weight wont reset on a model reload.
- **Pehkui Compatibility**: When designating a stage you can set certain Pehkui scales for each stage.
  - Automatically picks commands based on permissions.
  - If Pehkui4All is installed, lesserscale will be used if scale isnt available (**Ensure relevant scales are enabled in P4A config)**.
- **[Overstuffed](https://forum.weightgaming.com/t/overstuffed-an-actual-working-minecraft-weight-gain-mod/47948) mod compatibility**: When Overstuffed is installed, adipose will use Overstuffed's stuffed, weight values and Pehkui commands automatically.

> **Note: Pehkui, Pehkui4All or Overstuffed are optional**. Adipose will check for their presence, and if they are not installed, it will skip Pehkui related commands. The library will still change weight and update the model without them.

## 🛠️ Installation

1. Download the file [`Adipose.lua`](https://github.com/Tyrus5255/Adipose-API/blob/15b73dac8e77e5a7117cf1bcc6e2034bfa7e36e1/Adipose.lua) and drop it into your Figura avatar project.
2. Import the library as follows: 
```lua
local adipose = require("Adipose")
```
3. Create a new stage, and assign the model from `Models` or `ModelPart`s you need:
```lua
-- Using Models
adipose.weightStage:newStage()
  :setParts({ models.modelW0 })

adipose.weightStage:newStage()
  :setParts({ models.modelW1 })
```

```lua
-- Using ModelParts
adipose.weightStage:newStage()
  :setParts({ 
    models.model.BodyW0,
    models.model.TailW0,
    ...
  })

adipose.weightStage:newStage()
  :setParts({
    models.model.BodyW1,
    models.model.TailW1,
    ...
  })
```

You can also set other configuration parameters. Check out the list here: [Configuration](#-stage-configuration)

4. Save your script.
5. Done!

## 📃 Functions

### Configuration

| Configuration                                 | Description                                                                         |
|-----------------------------------------------|-------------------------------------------------------------------------------------|
| `setParts(parts: table<Models\|ModelPart>)`   | Parts of the model/model that shows when at that specific weight stage.             |
| `setGranularAnimation(animation: animations)` | Animation used to show how much weight you're gaining before the next weight stage. |
| `setStuffedAnimation(animation: animations)`  | Animation used to show how stuffed you are.                                         |
| `setEyeHeight(offset: number)`                | This is the value used by Pehkui (and relatives) to set `pehkui:eye_height`.        |
| `setHitboxWidth(width: number)`               | This is the value used by Pehkui (and relatives) to set `pehkui:hitbox_width`.      |
| `setHitboxHeight(height: number)`             | This is the value used by Pehkui (and relatives) to set `pehkui:hitbox_height`.     |
| `setMotion(motion: number)`                   | This is the value used by Pehkui (and relatives) to set `pehkui:motion`.            |

#### Full example
```lua
local adipose = require('Adipose')

...

adipose.weightStage:newStage()
      :setParts({ models.modelW0 })
      :setHitboxWidth(1.1)
      :setHitboxHeight(1.1)
      :setMotion(1.2)
      :setEyeHeight(1)
```

### Setting Weight

| Function                               | Description                                                                                                                                                  |
|----------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `setWeight(amount: number)`            | Set weight by value. To determine your current weight, Adipose uses a range from 100 to 1000. (specifically from `Adipose.minWeight` to `Adipose.maxWeight`) |
| `setCurrentWeightStage(stage: number)` | Set weight by stage. I.E if you have 5 stages, passing `5` to the function changes the stage to the fifth.                                                   |
| `adjustWeightByAmount(amount: number)` | Increase/decrease weight by a certain amount. I.E weight of 500, passing -50 would set the weight to 450.                                                    |
| `adjustWeightByStage(amount: number)`  | Increase/decrease weight stage by a certain amount. I.E current weight stage is 5, passing -1 would set the weight stage to 4.                               |

### Flags

All of these functions accept booleans as parameters, and will enable/disable different functionalities respectively.

- `setHitboxState(state: boolean)`: enables/disables hitboxes changes
- `setMotionState(state: boolean)`: enables/disables motion changes
- `setEyeHeightState(state: boolean)`: enables/disables eye height changes
