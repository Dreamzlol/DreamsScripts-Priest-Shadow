local Unlocker, awful, rotation = ...
local shadow = rotation.priest.shadow
local current_mode = nil

if not awful.player.class2 == "PRIEST" then
    return
end

awful.print("|cffFFFFFFDreams{ |cff00B5FFScripts |cffFFFFFF} - Shadow Loaded!")
awful.print("|cffFFFFFFDreams{ |cff00B5FFScripts |cffFFFFFF} - Version: 2.1.9")

shadow:Init(function()
    if rotation.settings.mode ~= current_mode then
        current_mode = rotation.settings.mode
        local mode = "|cffFFFFFFDreams{ |cff00B5FFScripts |cffFFFFFF} - Roation Mode: " .. current_mode
        awful.print(mode)
    end

    if (rotation.settings.mode == "PvE (Default APL)") then
        rotation.pve()
    end
    if (rotation.settings.mode == "PvE (WoWSims APL)") then
        rotation.wowSims()
    end
    if (rotation.settings.mode == "PvP") then
        rotation.pvp()
    end
end, 0.05)
