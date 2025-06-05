# 🍔 Adipose API 
Figura library that adds Weight Gain functionality with animation support.

- [Features](#️-features)
- [Installation](#️-installation)
- [Functions](#-functions)
  - [Configuration](#configuration)
  - [Setting Weight](#setting-weight)
  - [Flags](#flags)

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
3. Create a new stage, and assign the models or model parts you need:
```lua
-- Using Models
adipose.weightStage:newStage()
  :setParts(models.modelW0)

adipose.weightStage:newStage()
  :setParts(models.modelW1)
```

```lua
-- Using ModelParts in a table
adipose.weightStage:newStage()
  :setParts({ 
    models.model.BodyW0,
    models.model.TailW0
  })

adipose.weightStage:newStage()
  :setParts({
    models.model.BodyW1,
    models.model.TailW1
  })
```

You can also set other configuration parameters. Check out the list here: [Configuration](#-stage-configuration)

4. Save your script.
5. Done!

## 📃 Functions

### Configuration

| Configuration                                           | Description                                                                         |
|---------------------------------------------------------|-------------------------------------------------------------------------------------|
| `setParts(parts: ModelPart\|[ModelPart])`               | Model or model parts that show when at that specific weight stage.                  |
| `setGranularAnimation(animation: Animation)`            | Animation used to show how much weight you're gaining before the next weight stage. |
| `setStuffedAnimation(animation: Animation)`             | Animation used to show how stuffed you are.                                         |
| `addScaleOption(minWeight: number, maxWeight: number?)` | Add a scaling option used by Pehkui.                                                |

#### Scaling Options

`addScaleOption` supports two modes of operation:

- Static - `addScaleOption(minWeight)` - Scaling option is set to constant `minWeight` value for that weight stage.
- Dynamic - `addScaleOption(minWeight, maxWeight)` - Scaling option varies from `minWeight` value to `maxWeight` value for that stage.

`addScaleOption` supports the following scaling options by default:

- `pehkui:eye_height`
- `pehkui:hitbox_height`
- `pehkui:hitbox_width`
- `pehkui:motion`

Scaling options can be toggled globally by setting the corresponding key in `adipose.pehkui`.

```lua
adipose.pehkui["pehkui:hitbox_width"] = false
```

Additional scaling options can be supported by adding keys to `adipose.pehkui`.

```lua
adipose.pehkui["pehkui:step_height"] = true
```

#### Full example

```lua
local adipose = require('Adipose')

adipose.weightStage:newStage()
      :setParts(models.modelW0)
      :addScaleOption("pehkui:eye_height", 1.2) -- Static
      :addScaleOption("pehkui:hitbox_height", 1.1) -- Static
      :addScaleOption("pehkui:hitbox_width", 1, 2) -- Dynamic
      :addScaleOption("pehkui:motion", 1, 0.8) -- Dynamic
```

### Setting Weight

| Function                               | Description                                                                                                                                                  |
|----------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `setWeight(amount: number)`            | Set weight by value. To determine your current weight, Adipose uses a range from 100 to 1000. (specifically from `Adipose.minWeight` to `Adipose.maxWeight`) |
| `setCurrentWeightStage(stage: number)` | Set weight by stage. I.E if you have 5 stages, passing `5` to the function changes the stage to the fifth.                                                   |
| `adjustWeightByAmount(amount: number)` | Increase/decrease weight by a certain amount. I.E weight of 500, passing -50 would set the weight to 450.                                                    |
| `adjustWeightByStage(amount: number)`  | Increase/decrease weight stage by a certain amount. I.E current weight stage is 5, passing -1 would set the weight stage to 4.                               |
