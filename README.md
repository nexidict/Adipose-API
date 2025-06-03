# 🍔 Adipose API 
Figura library that adds Weight Gain functionality with animation support.

- [Features](#️-features)
- [Installation](#️-installation)
- [Stage Configuration](#-stage-configuration)

## ⚙️ Features
- **Staged Based Weight Gain**: designate Weight Stages with different modelparts or even whole models.
- **Granular Weight Gain**: use an animation to smooth out the transition between stages.
- **Stuffed Animation**: use an animation to reflect stomach fullness.
- **Weight Saving via Config**: your weight wont reset on a model reload.
- **Pehkui Compatibility**: When designating a stage you can set certain Pehkui scales for each stage.
  - Automatically picks commands based on permissions.
  - If Pehkui4All is installed, lesserscale will be used if scale isnt available (**Ensure relevant scales are enabled in P4A config)**.
- **[Overstuffed](https://forum.weightgaming.com/t/overstuffed-an-actual-working-minecraft-weight-gain-mod/47948) mod compatibility**: When Overstuffed is installed, adipose will use Overstuffed's stuffed, weight values and Pehkui commands automatically.

## 🛠️ Installation

1. Download the file [`Adipose.lua`](https://github.com/Tyrus5255/Adipose-API/blob/15b73dac8e77e5a7117cf1bcc6e2034bfa7e36e1/Adipose.lua) and drop it into your Figura avatar project.
2. Import the library as follows: 
```lua
adipose = require("path.to.Adipose")
```
3. Create a new stage, and assign the model from `Models` or `ModelPart`s you need:
```lua
-- Using Models
weightStage0 = adipose.new()
  :setParts({ models.modelW0 })

weightStage1 = adipose.new()
  :setParts({ models.modelW1 })
```

```lua
-- Using ModelParts
weightStage0 = adipose.new()
  :setParts({ 
    models.model.BodyW0,
    models.model.TailW0,
    ...
  })

weightStage1 = adipose.new()
  :setParts({
    models.model.BodyW1,
    models.model.TailW1,
    ...
  })
```

You can also set other configuration parameters. Check out the list here: [Configuration](#-stage-configuration)

4. Save your script.
5. Done!

## 📃 Stage Configuration


| Configuration                                 | Description                                                                         |
|-----------------------------------------------|-------------------------------------------------------------------------------------|
| `setParts(parts: table<Models\|ModelPart>)`   | Parts of the model/model that shows when at that specific weight stage.             |
| `setGranularAnimation(animation: animations)` | Animation used to show how much weight you're gaining before the next weight stage. |
| `setStuffedAnimation(animation: animations)`  | Animation used to show how stuffed you are.                                         |
| `setEyeHeight(offset: number)`                | This is the value used by Pehkui (and relatives) to set `pehkui:eye_height`.        |
| `setHitboxWidth(width: number)`               | This is the value used by Pehkui (and relatives) to set `pehkui:hitbox_width`.      |
| `setHitboxHeight(height: number)`             | This is the value used by Pehkui (and relatives) to set `pehkui:hitbox_height`.     |
| `setMotion(motion: number)`                   | This is the value used by Pehkui (and relatives) to set `pehkui:motion`.            |

### Full example
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
