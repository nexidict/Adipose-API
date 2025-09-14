--@class Pehkui
local pehkui = {}

-- LIBRARIES
local queueLib

for _, path in ipairs(listFiles("/", true)) do
    if string.find(path, "Queue") then queueLib = require(path) end
end
assert(queueLib, "Missing Queue file! Make sure to download that from the GitHub too!")

-- VARIABLES
pehkui.options = {
    ["pehkui:base"]             = true,
    ["pehkui:width"]            = true,
    ["pehkui:height"]           = true,
    ["pehkui:hitbox_width"]     = true,
    ["pehkui:hitbox_height"]    = true,
    ["pehkui:eye_height"]       = true,
    ["pehkui:model_width"]      = true,
    ["pehkui:model_height"]     = true,
    ["pehkui:third_person"]     = true,
    ["pehkui:motion"]           = true,
    ["pehkui:step_height"]      = true,
    ["pehkui:view_bobbing"]     = true,
    ["pehkui:falling"]          = true,
    ["pehkui:flight"]           = true,
    ["pehkui:jump_height"]      = true,
    ["pehkui:visibility"]       = true,
    ["pehkui:reach"]            = true,
    ["pehkui:block_reach"]      = true,
    ["pehkui:entity_reach"]     = true,
    ["pehkui:held_item"]        = true,
    ["pehkui:drops"]            = true,
    ["pehkui:projectiles"]      = true,
    ["pehkui:explosions"]       = true,
    ["pehkui:attack"]           = true,
    ["pehkui:defense"]          = true,
    ["pehkui:knockback"]        = true,
    ["pehkui:health"]           = true,
    ["pehkui:mining_speed"]     = true,
    ["pehkui:attack_speed"]     = true
}

local queueTimer = 0
local commandQueue = queueLib:new()

-- FLAGS
local function loadConfig()
    for k, default in pairs(pehkui.options) do
        local stored = config:load(k)
        if stored == nil then
            config:save(k, default)
            -- log("Created config entry: " .. k .. " = " .. tostring(default))
        else
            pehkui.options[k] = stored
            -- log("Loaded config entry: " .. k .. " = " .. tostring(stored))
        end
    end
end

function pehkui.initFlags(scaleList)
    local changed = false
    for k, _ in pairs(scaleList) do
        -- Only create if it doesn't exist at all
        if pehkui.options[k] == nil then
            pehkui.options[k] = true   -- default for new keys
            config:save(k, true)
            changed = true
            log("Registered new scaling flag: " .. k)
        end
    end
    if changed then
        log("Pehkui flags updated")
    end
end

function pehkui.setScaleState(scale, state)
    assert(pehkui.options[scale] ~= nil, 'Unknown scaling option')
    pehkui.options[scale] = state
    config:save(scale, state)
end

-- EVENTS
function events.entity_init()
    pehkui.pehkuiCheck = client:isModLoaded("pehkui")
	pehkui.p4aCheck = client:isModLoaded("pehkui4all")
    pehkui.opCheck = player:getPermissionLevel() == 4   

    --IF YOU HATE THE STARTUP MESSAGE THIS IS THE THING TO DELETE! \/

    if pehkui.pehkuiCheck then
        if pehkui.opCheck then
            print("OP Detected, Using /scale for Scaling")
        elseif pehkui.p4aCheck then
            print("Pehkui 4 All Detected, Using /lesserscale for Scaling")
        else
            print("Insufficient Permissions for Scaling, Scaling Disabled")
        end	
    else
        print("Pehkui not Installed, scaling Disabled")
    end

    --IF YOU HATE THE STARTUP MESSAGE THIS IS THE THING TO DELETE! /\

    loadConfig()
end

function events.tick()
    if queueTimer > 15 then
        queueTimer = 0

        if commandQueue:isEmpty() then return end

        local command = commandQueue:pop()
        log(command)
        host:sendChatCommand(command)
    else queueTimer = queueTimer + 1 end
end

-- SCALING
function pehkui.setScale(scale, value)
    if pehkui.options[scale] == false and value ~= 1 then return end

    if pehkui.opCheck and pehkui.pehkuiCheck then
        commandQueue:push('scale set '..scale..' '..value..' @s')
    elseif pehkui.p4aCheck then
        local prefixIndex = string.find(scale, ":")
        scale = string.sub(scale, prefixIndex+1)
        commandQueue:push('lesserscale set '..value..' '..scale)
    end
end

return pehkui