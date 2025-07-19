# 🍔 Adipose API 

Figura library that adds Weight Gain functionality with animation support.

**Table of Contents**

- [Features](#️-features)
- [Installation](#️-installation)
- [Functions](#-functions)
  - [Adipose API](#adipose-api)
    - [Require](#require)
  - [Weight Management](#weight-management)
    - [Set Weight](#setweight)
    - [Set Current Weight Stage](#setcurrentweightstage)
    - [Adjust Weight By Amount](#adjustweightbyamount)
    - [Adjust Weight By Stage](#adjustweightbystage)
  - [Weight Stage](#weight-stage)
    - [Set Parts](#setparts)
    - [Set Granular Animation](#setgranularanimation)
    - [Set Stuffed Animation](#setstuffedanimation)
    - [Set Eye Height](#seteyeheight)
    - [Set Hitbox Width](#sethitboxwidth)
    - [Set Hitbox Height](#sethitboxheight)
    - [Set Motion](#setmotion)
  - [Flags](#flags)
    - [Set Hitbox State](#sethitboxstate)
    - [Set Motion State](#setmotionstate)
    - [Set Eye Height State](#seteyeheightstate)

## ⚙️ Features

- **Staged Based Weight Gain**: designate Weight Stages with different modelparts or even whole models.
- **Granular Weight Gain**: use an animation to smooth out the transition between stages.
- **Stuffed Animation**: use an animation to reflect stomach fullness.
- **Weight Saving via Config**: your weight won't reset on a model reload.
- **Pehkui Compatibility**: When designating a stage you can set certain Pehkui scales for each stage.
  - Automatically picks commands based on permissions.
  - If Pehkui4All is installed, lesserscale will be used if scale isnt available (**Ensure relevant scales are enabled in P4A config)**.
- **[Overstuffed](https://forum.weightgaming.com/t/overstuffed-an-actual-working-minecraft-weight-gain-mod/47948) mod compatibility**: When Overstuffed is installed, adipose will use Overstuffed's stuffed, weight values and Pehkui commands automatically.

> **Note: Pehkui, Pehkui4All or Overstuffed are optional**. Adipose will check for their presence, and if they are not installed, it will skip Pehkui related commands. The library will still change weight and update the model without them.

**⚠ ENSURE Figura's "Chat Messages" setting is set to _ON_ for scaling to occur ⚠**
![Figura Chat Messages Setting](https://github.com/user-attachments/assets/210014bc-9efc-40c7-908d-6aba5c42277c)

## 🛠️ Installation

1. Download the file [`Adipose.lua`](https://github.com/Tyrus5255/Adipose-API/blob/15b73dac8e77e5a7117cf1bcc6e2034bfa7e36e1/Adipose.lua) and drop it into your Figura avatar project.

2. Import the library:

    ```lua
    local adipose = require('Adipose')
    ```

3. Create and configure stages:

    ```lua
    adipose.weightStage:newStage()
          :setParts(models.modelW0)
          :setEyeHeight(1)
          :setHitboxWidth(1)
          :setHitboxHeight(1)
          :setMotion(1)

    adipose.weightStage:newStage()
          :setParts(models.modelW1)
          :setEyeHeight(1)
          :setHitboxWidth(2)
          :setHitboxHeight(1)
          :setMotion(0.5)

    adipose.weightStage:newStage()
          :setParts(models.modelW2)
          :setEyeHeight(2)
          :setHitboxWidth(3)
          :setHitboxHeight(2)
          :setMotion(0.1)
    ```

4. Save your script.

5. Done!

## 📃 Functions

### Adipose API

#### Require

Import the Adipose API for use in a script.

**Example:**

```lua
local adipose = require('Adipose')
```

### Weight Management

#### `setWeight()`

Sets the current weight value.

Weight is limited from `adipose.minWeight` (default 100) to `adipose.maxWeight` (default 1000).

**Parameters:**

Name | Type | Description
---  | ---  | ---
amount | `Number` | Current weight value to set

**Example:**

```lua
adipose.setWeight(adipose.minWeight)
```

#### `setCurrentWeightStage()`

Sets the current weight stage, where 1 is the first stage.

**Parameters:**

Name | Type | Description
---  | ---  | ---
stage | `Number` | Current weight stage to set

**Example:**

```lua
adipose.setCurrentWeightStage(1)
```

#### `adjustWeightByAmount()`

Adjusts the current weight value.

**Parameters:**

Name | Type | Description
---  | ---  | ---
amount | `Number` | Weight value

**Example:**

```lua
adipose.adjustWeightByAmount(100)
```

#### `adjustWeightByStage()`

Adjusts the current weight stage.

**Parameters:**

Name | Type | Description
---  | ---  | ---
stage | `Number` | Weight stage

**Example:**

```lua
adipose.adjustWeightByStage(1)
```

#### `adipose.weightStage:newStage()`

Creates a new stage.

**Returns:**

Type | Description
---  | ---
`Adipose.WeightStage` | Returns self for chaining

**Example:**

```lua
local stage = adipose.weightStage:newStage()
```

### Weight Stage

#### `setParts()`

Sets the model or model parts to show at this stage.

**Parameters:**

Name | Type | Description
---  | ---  | ---
parts | `ModelPart\|[ModelPart]` | Model or table of model parts

**Returns:**

Type | Description
---  | ---
`Adipose.WeightStage` | Returns self for chaining

**Example:**

```lua
-- Using whole models
stage:setParts(models.modelW0)
```

**Example:**

```lua
-- Using table of model parts
stage:setParts(
  { 
    models.model.BodyW0,
    models.model.TailW0
  }
)
```

#### `setGranularAnimation()`

Set the animation used to show weight gain between stages.

The animation's loop mode must be set to "Hold on Last Frame" in Blockbench.

**Parameters:**

Name | Type | Description
---  | ---  | ---
animation | `Animation` | Animation with loop mode set to HOLD

**Returns:**

Type | Description
---  | ---
`Adipose.WeightStage` | Returns self for chaining

**Example:**

```lua
stage:setGranularAnimation(animations.model.weight)
```

#### `setStuffedAnimation()`

Set the animation used to show the stuffed level.

The animation's loop mode must be set to "Hold on Last Frame" in Blockbench.

**Parameters:**

Name | Type | Description
---  | ---  | ---
animation | `Animation` | Animation with loop mode set to HOLD

**Returns:**

Type | Description
---  | ---
`Adipose.WeightStage` | Returns self for chaining

**Example:**

```lua
stage:setStuffedAnimation(animations.model.stuffed)
```

#### `setEyeHeight()`

Set the eye height at this stage.

**Parameters:**

Name | Type | Description
---  | ---  | ---
offset | `Number` | Value of `pehkui:eye_height` to set when this stage is entered.

**Returns:**

Type | Description
---  | ---
`Adipose.WeightStage` | Returns self for chaining

**Example:**

```lua
stage:setEyeHeight(1)
```

#### `setHitboxWidth()`

Set the hitbox width at this stage.

**Parameters:**

Name | Type | Description
---  | ---  | ---
width | `Number` | Value of `pehkui:hitbox_width` to set when this stage is entered.

**Returns:**

Type | Description
---  | ---
`Adipose.WeightStage` | Returns self for chaining

**Example:**

```lua
stage:setHitboxWidth(1)
```

#### `setHitboxHeight()`

Set the hitbox height at this stage.

**Parameters:**

Name | Type | Description
---  | ---  | ---
height | `Number` | Value of `pehkui:hitbox_height` to set when this stage is entered.

**Returns:**

Type | Description
---  | ---
`Adipose.WeightStage` | Returns self for chaining

**Example:**

```lua
stage:setHitboxHeight(1)
```

#### `setMotion()`

Set the motion at this stage.

This parameter primarily affects movement speed but also affects step and jump height.

**Parameters:**

Name | Type | Description
---  | ---  | ---
motion | `Number` | Value of `pehkui:motion` to set when this stage is entered.

**Returns:**

Type | Description
---  | ---
`Adipose.WeightStage` | Returns self for chaining

**Example:**

```lua
stage:setMotion(1)
```

### Flags

#### `setHitboxState()`

Enable or disable commands to set `pehkui:hitbox_height` and `pehkui:hitbox_width` by Adipose.

**Parameters:**

Name | Type | Description
---  | ---  | ---
state | `Boolean` | Enable (`true`) or disable (`false`)

**Example:**

```lua
adipose.setHitboxState(false)
```

#### `setMotionState()`

Enable or disable commands to set `pehkui:motion` by Adipose.

**Parameters:**

Name | Type | Description
---  | ---  | ---
state | `Boolean` | Enable (`true`) or disable (`false`)

**Example:**

```lua
adipose.setMotionState(false)
```

#### `setEyeHeightState()`

Enable or disable commands to set `pehkui:eye_height` by Adipose.

**Parameters:**

Name | Type | Description
---  | ---  | ---
state | `Boolean` | Enable (`true`) or disable (`false`)

**Example:**

```lua
adipose.setEyeHeightState(false)
```
