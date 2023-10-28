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
    shadow.AutoAttack("tremor")
    shadow.Shoot("tremor")
    shadow.ShadowWordDeath("tremor")
    shadow.PsychicHorror("disarm")
    shadow.ShadowWordDeath("polymorph")
    shadow.ShadowWordDeath("seduction")
    shadow.ShadowWordDeath("execute")
    shadow.DevouringPlague("execute")
    shadow.Shadowfiend()
    shadow.FearWard()
    shadow.Fade()

    -- CC
    shadow.PsychicScream("lowhp")
    shadow.PsychicScream("mutiple")
    shadow.PsychicScream("focus")
    shadow.Silence()
    shadow.PsychicHorror("cc")
    shadow.ShackleUndead("gargoyle")

    shadow.DispelMagic("defensive")
    shadow.DispelMagic("healer")
    shadow.DispelMagic("offensive")
    shadow.MassDispel("immune")
    shadow.AbolishDisease()
    shadow.Dispersion()

    -- Healing
    shadow.PowerWordShield()
    shadow.PrayerOfMending()
    shadow.Renew()
    shadow.BindingHeal()
    shadow.FlashHeal()
    shadow.HolyNova("heal")

    -- Damage
    shadow.InnerFire()
    shadow.InventorySlot10()
    shadow.VampiricTouch()
    shadow.DevouringPlague()
    shadow.ShadowWordPain()

    shadow.HolyNova("snakes")
    shadow.MindBlast()
    shadow.MindFlay()
end
