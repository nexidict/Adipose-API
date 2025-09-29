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
    - [Set Scaling List](#setscaling)

## ⚙️ Features

- **Staged Based Weight Gain**: designate Weight Stages with different modelparts or even whole models.
- **Granular Weight Gain**: use an animation to smooth out the transition between stages.
- **Stuffed Animation**: use an animation to reflect stomach fullness.
- **Weight Saving via Config**: your weight won't reset on a model reload.

## 🛠️ Installation

1. Download the file [`Adipose.lua`](https://github.com/nexidict/Adipose-API/blob/main/Adipose.lua) and drop it into your Figura avatar project.

2. Import the library:

    ```lua
    local adipose = require('Adipose')
    ```

3. Create and configure stages:

    ```lua
    adipose.weightStage:newStage()
          :setParts(models.modelW0)
          :setGranularAnimation(animations.modelW0.granularity)
          :setStuffedAnimation(animations.modelW0.stuffed)

    adipose.weightStage:newStage()
          :setParts(models.modelW1)
          :setGranularAnimation(animations.modelW1.granularity)
          :setStuffedAnimation(animations.modelW1.stuffed)

    adipose.weightStage:newStage()
          :setParts(models.modelW2)
          :setGranularAnimation(animations.modelW2.granularity)
          :setStuffedAnimation(animations.modelW2.stuffed)
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
forceUpdate | `Boolean` | If `true`, forces the script ignore update conditions

**Example:**

```lua
adipose.setWeight(adipose.minWeight, false)
```

#### `setOnWeightChange()`

Lambda function which allows to write custom behavior upon weight stage changes.

**Paramters:**

Name | Type | Description
---  | ---  | ---
weight | `Number` | Total weight value
index | `Number` | Weight stage index
granularity | `Number` | Granularity progress
stuffed | `Number` | Stuffed progress

**Example:**

```lua
adipose.setOnWeightChange(function (weight, index, granularity stuffed)
  -- Update UI, set Pehkui scaling, play sounds...
  ...
end)
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

#### `setScaling()`

Set the key-value pair list containing scaling parameters and values.

This only serves as a helper table to store potential Pehkui scaling options. Meant to be paired with the [Pehkui Figura](https://github.com/nexidict/Pehkui-Figura) script.

**Parameters:**

Name | Type | Description
---  | ---  | ---
scaling | `table<string, number>` | Table of string-value pairs

**Returns:**

Type | Description
---  | ---
`Adipose.WeightStage` | Returns self for chaining

**Example:**

```lua
stage:setScaling({
  ['pehkui:eye_height'] = 1.1,
  ['pehkui:hitbox_height'] = 1.1,
  ['pehkui:hitbox_width'] = 1.1,
  ['pehkui:motion'] = 1,
  ...
})
```