local Unlocker, awful, rotation = ...
local shadow = rotation.priest.shadow
local currentMode = nil

awful.print("|cffFFFFFFDreams{ |cff00B5FFScripts |cffFFFFFF} - Shadow Loaded!")
awful.print("|cffFFFFFFDreams{ |cff00B5FFScripts |cffFFFFFF} - Version: 2.0.0")


shadow:Init(function()
    if rotation.settings.mode ~= currentMode then
        currentMode = rotation.settings.mode
        if rotation.settings.mode == "PvE" then
            awful.print("|cffFFFFFFDreams{ |cff00B5FFScripts |cffFFFFFF} - Shadow PvE active")
        elseif rotation.settings.mode == "PvP" then
            awful.print("|cffFFFFFFDreams{ |cff00B5FFScripts |cffFFFFFF} - Shadow PvP active")
        end
    end

    if rotation.settings.mode == "PvE" then
        rotation.APL_PvE()
    elseif rotation.settings.mode == "PvP" then
        rotation.APL_PvP()
    end
end, 0.05)

