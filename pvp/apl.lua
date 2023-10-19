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
    shadow.ShadowWordDeath("tremor")
    shadow.AutoAttack("totems")
    shadow.ShadowWordDeath("polymorph")
    shadow.ShadowWordDeath("seduction")
    shadow.engineer_gloves("execute")
    shadow.ShadowWordDeath("execute")
    shadow.Shadowfiend()
    shadow.FearWard()

    -- CC
    shadow.Silence()
    shadow.PsychicHorror()

    shadow.DispelMagic("healer")
    shadow.MassDispel("combat")
    shadow.MassDispel("immune")
    shadow.PsychicScream("lowhp")
    shadow.PsychicScream("mutiple")
    shadow.PsychicScream("focus")
    shadow.DesperatePrayer()
    shadow.Dispersion()
    shadow.PowerWordShield()
    shadow.PrayerOfMending()
    shadow.InnerFire()
    shadow.Fade()

    -- Heal
    shadow.BindingHeal()
    shadow.FlashHeal()
    shadow.Renew()

    shadow.VampiricTouch("sustain")
    shadow.DispelMagic("defensive")
    shadow.DispelMagic("offensive")

    -- Burst Damage
    if awful.burst then
        shadow.VampiricTouch("sustain")
        shadow.Shadowfiend("burst")
        shadow.MindBlast("sustain")
        shadow.engineer_gloves("burst")
        shadow.ShadowWordDeath("burst")
        shadow.ShadowWordPain("sustain")
        shadow.DevouringPlague("sustain")
    end

    shadow.ShadowWordPain("sustain")
    shadow.DevouringPlague("sustain")

    shadow.ShackleUndead("lich")
    shadow.ShackleUndead("gargoyle")
    shadow.AbolishDisease()

    shadow.HolyNova("snakes")

    -- Sustained Damage
    shadow.MindFlay("sustain")
    shadow.MindBlast("sustain")
end
