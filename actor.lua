local Unlocker, awful, rotation = ...
local shadow = rotation.priest.shadow
local class = awful.player.class2
local current_mode = nil

if class ~= "PRIEST" then
    return
end

awful.print("|cffFFFFFFDreams{ |cff00B5FFScripts |cffFFFFFF} - Shadow Loaded!")
awful.print("|cffFFFFFFDreams{ |cff00B5FFScripts |cffFFFFFF} - Version: 2.1.1")

shadow:Init(function()
    if rotation.settings.mode ~= current_mode then
        current_mode = rotation.settings.mode
        local mode = "|cffFFFFFFDreams{ |cff00B5FFScripts |cffFFFFFF} - Roation Mode: " .. current_mode
        awful.print(mode)
    end

    if (rotation.settings.mode == "PvE") then
        rotation.apl_pve()
    end
    if (rotation.settings.mode == "PvP") then
        rotation.apl_pvp()
    end
end, 0.05)
