local Unlocker, awful, rotation = ...
local shadow = rotation.priest.shadow
local player = awful.player

if not awful.player.class2 == "PRIEST" then
    return
end

function rotation.pvp()
    if not (rotation.settings.mode == "PvP") then return end
    if player.mounted then return end
    if player.buff("Drink") then return end
    if player.casting == "Mind Control" or player.channel == "Mind Control" then return end

    shadow.Shadowform()
    shadow.VampiricEmbrace()

    shadow.HolyNova("stealth")
    shadow.Shoot("tremor")
    shadow.PsychicHorror("disarm")
    shadow.ShadowWordDeath("polymorph")
    shadow.ShadowWordDeath("seduction")
    shadow.ShadowWordDeath("execute")
    shadow.DevouringPlague("execute")
    shadow.Shadowfiend()
    shadow.FearWard()

    -- CC
    shadow.PsychicScream("lowhp")
    shadow.PsychicScream("mutiple")
    shadow.PsychicScream("focus")
    shadow.Silence()
    shadow.PsychicHorror("cc")

    shadow.DispelMagic("defensive")
    shadow.DispelMagic("healer")
    shadow.MassDispel("combat")
    shadow.MassDispel("immune")
    shadow.AbolishDisease()
    shadow.Fade()
    shadow.Dispersion()
    shadow.InnerFire()
    shadow.PowerWordShield()
    shadow.PrayerOfMending()
    shadow.HolyNova("heal")
    shadow.Renew()

    shadow.InventorySlot10()
    shadow.VampiricTouch()
    shadow.DevouringPlague()
    shadow.ShadowWordPain()

    shadow.BindingHeal()
    shadow.FlashHeal()

    shadow.DispelMagic("offensive")
    shadow.ShackleUndead("lich")
    shadow.ShackleUndead("gargoyle")
    shadow.HolyNova("snakes")
    shadow.MindBlast()
    shadow.MindFlay()
end
