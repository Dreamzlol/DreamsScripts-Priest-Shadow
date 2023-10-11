local Unlocker, awful, rotation = ...
local shadow = rotation.priest.shadow
local Spell = awful.Spell
local player, target = awful.player, awful.target

if not rotation.settings.mode == "PvE" then
    return
end

awful.Populate({
    -- Racials
    pve_berserking        = Spell(26297, { beneficial = true }),

    -- Buffs
    pve_shadowform        = Spell(15473, { beneficial = true }),
    pve_inner_fire        = Spell(48168, { beneficial = true }),
    pve_vampiric_embrace  = Spell(15286, { beneficial = true }),
    pve_dispersion        = Spell(47585),
    pve_inner_focus       = Spell(14751, { beneficial = true }),

    -- Damage
    pve_mind_blast        = Spell(48127, { damage = "magic" }),
    pve_mind_flay         = Spell(48156, { damage = "magic" }),
    pve_vampiric_touch    = Spell(48160, { damage = "magic", ignoreFacing = true }),
    pve_devouring_plague  = Spell(48300, { damage = "magic", ignoreFacing = true }),
    pve_shadow_word_pain  = Spell(2767, { damage = "magic", ignoreFacing = true }),
    pve_mind_sear         = Spell(53023, { damage = "magic", ignoreFacing = true }),
    pve_shadowfiend       = Spell(34433, { damage = "magic", ignoreFacing = true }),
    pve_shadow_word_death = Spell(48158, { damage = "magic", ignoreFacing = true }),
}, shadow, getfenv(1))

local function filter(obj)
    return obj.combat and obj.los and obj.distance < 40 and obj.enemy and not obj.dead
end

local function SettingsCheck(settingsVar, castId)
    for k, v in pairs(settingsVar) do
        if k == castId and v == true then
            return true
        end
        if type(v) == "table" then
            for _, id in ipairs(v) do
                if castId == id then
                    return true
                end
            end
        end
    end
end

pve_shadowform:Callback(function(spell)
    if not player.buff("Shadowform") then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

pve_inner_fire:Callback(function(spell)
    if not player.buff("Inner Fire") then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

pve_berserking:Callback(function(spell)
    if not rotation.settings.use_cds then
        return
    end

    if target.level == -1 and player.buffStacks("Shadow Weaving") == 5 then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

pve_inner_focus:Callback(function(spell)
    if not rotation.settings.use_cds then
        return
    end

    if target.level == -1 and player.buffStacks("Shadow Weaving") == 5 then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

pve_vampiric_embrace:Callback(function(spell)
    if not player.buff("Vampiric Embrace") then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

pve_vampiric_touch:Callback("aoe", function(spell)
    if not rotation.settings.useAoe then
        return
    end
    if player.casting then
        return
    end
    if player.moving then
        return
    end

    if not SettingsCheck(rotation.settings.aoeRotation, "Vampiric Touch") then
        return
    end

    awful.enemies.within(40).filter(filter).loop(function(enemy)
        if not enemy or not enemy.exists then
            return
        end
        -- (ICC) Shroud of the Occult: Envelops the caster in a powerful barrier that deflects all harmful magic,
        -- prevents cast interruption, and absorbs up to 50000 damage before breaking.
        if enemy.buff("Shroud of the Occult") then
            return
        end
        -- (Heroic+) Mirror Image: This NPC can be found in The Oculus , The Nexus , and The Violet Hold.
        if enemy.name("Mirror Image") then
            return
        end
        if enemy.debuffRemains("Vampiric Touch", player) < 1 and target.ttd >= 14 then
            if spell:Cast(enemy) then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end)
end)

pve_shadow_word_pain:Callback("aoe", function(spell)
    if not rotation.settings.useAoe then
        return
    end

    if not SettingsCheck(rotation.settings.aoeRotation, "Shadow Word: Pain") then
        return
    end

    awful.enemies.within(40).filter(filter).loop(function(enemy)
        if not enemy or not enemy.exists then
            return
        end
        -- (ICC) Shroud of the Occult: Envelops the caster in a powerful barrier that deflects all harmful magic,
        -- prevents cast interruption, and absorbs up to 50000 damage before breaking.
        if enemy.buff("Shroud of the Occult") then
            return
        end
        -- (Heroic+) Mirror Image: This NPC can be found in The Oculus , The Nexus , and The Violet Hold.
        if enemy.name("Mirror Image") then
            return
        end
        if not enemy.debuff("Shadow Word: Pain", player) and target.ttd >= 14 then
            if spell:Cast(enemy) then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end)
end)

pve_mind_sear:Callback("aoe", function(spell)
    if not rotation.settings.useAoe then
        return
    end
    if player.moving then
        return
    end
    if not SettingsCheck(rotation.settings.aoeRotation, "Mind Sear") then
        return
    end
    local hasVT, count = awful.enemies.around(target, 10,
        function(obj) return obj.combat and obj.enemy and not obj.dead and obj.debuff("Vampiric Touch", player) end)
    if target and target.exists then
        if count >= rotation.settings.mind_sear and hasVT then
            if spell:Cast(target) then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end
end)

-- Opener Rotation
pve_vampiric_touch:Callback("opener", function(spell)
    if not target or not target.exists then
        return
    end
    if player.casting then
        return
    end
    if player.moving then
        return
    end
    -- (ICC) Shroud of the Occult: Envelops the caster in a powerful barrier that deflects all harmful magic,
    -- prevents cast interruption, and absorbs up to 50000 damage before breaking.
    if target.buff("Shroud of the Occult") then
        return
    end
    -- (Heroic+) Mirror Image: This NPC can be found in The Oculus , The Nexus , and The Violet Hold.
    if target.name == "Mirror Image" then
        return
    end
    if target.debuffRemains("Vampiric Touch", player) < 1 and player.buffStacks("Shadow Weaving") < 2 and target.ttd >= 14 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

pve_devouring_plague:Callback("opener", function(spell)
    if not target or not target.exists then
        return
    end
    if not target.debuff("Vampiric Touch", player) then
        return
    end
    -- (ICC) Shroud of the Occult: Envelops the caster in a powerful barrier that deflects all harmful magic,
    -- prevents cast interruption, and absorbs up to 50000 damage before breaking.
    if target.buff("Shroud of the Occult") then
        return
    end
    if not target.debuff("Devouring Plague", player) and player.buffStacks("Shadow Weaving") <= 2 and target.ttd >= 14 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

pve_mind_blast:Callback("opener", function(spell)
    if not rotation.settings.use_mind_blast then
        return
    end
    if player.moving then
        return
    end
    if target and target.exists then
        if target.debuff("Vampiric Touch", player) and player.buffStacks("Shadow Weaving") <= 3 then
            if spell:Cast(target) then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end
end)

pve_shadowfiend:Callback("opener", function(spell)
    if not rotation.settings.use_cds then
        return
    end
    if target and target.exists then
        if target.level == -1 and target.debuff("Vampiric Touch", player) and player.buffStacks("Shadow Weaving") <= 3 then
            if spell:Cast(target) then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end
end)

pve_mind_flay:Callback("opener", function(spell)
    if player.moving then
        return
    end
    if target and target.exists then
        if target.debuff("Vampiric Touch", player) and player.buffStacks("Shadow Weaving") < 5 then
            if spell:Cast(target) then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end
end)

pve_shadow_word_pain:Callback("opener", function(spell)
    if not target or not target.exists then
        return
    end
    -- (ICC) Shroud of the Occult: Envelops the caster in a powerful barrier that deflects all harmful magic,
    -- prevents cast interruption, and absorbs up to 50000 damage before breaking.
    if target.buff("Shroud of the Occult") then
        return
    end
    -- (Heroic+) Mirror Image: This NPC can be found in The Oculus , The Nexus , and The Violet Hold.
    if target.name == "Mirror Image" then
        return
    end
    if not target.debuff("Shadow Word: Pain", player) and player.buffStacks("Shadow Weaving") == 5 and target.ttd >= 14 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

-- Main Rotation
pve_vampiric_touch:Callback(function(spell)
    if not target or not target.exists then
        return
    end
    if player.casting then
        return
    end
    if player.moving then
        return
    end
    -- (ICC) Shroud of the Occult: Envelops the caster in a powerful barrier that deflects all harmful magic,
    -- prevents cast interruption, and absorbs up to 50000 damage before breaking.
    if target.buff("Shroud of the Occult") then
        return
    end
    -- (Heroic+) Mirror Image: This NPC can be found in The Oculus , The Nexus , and The Violet Hold.
    if target.name == "Mirror Image" then
        return
    end
    if target.debuffRemains("Vampiric Touch", player) < 1 and player.buffStacks("Shadow Weaving") == 5 and target.ttd >= 14 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

pve_devouring_plague:Callback(function(spell)
    if not target or not target.exists then
        return
    end
    -- (ICC) Shroud of the Occult: Envelops the caster in a powerful barrier that deflects all harmful magic,
    -- prevents cast interruption, and absorbs up to 50000 damage before breaking.
    if target.buff("Shroud of the Occult") then
        return
    end
    if not target.debuff("Devouring Plague", player) and player.buffStacks("Shadow Weaving") == 5 and target.ttd >= 14 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

pve_shadowfiend:Callback(function(spell)
    if not rotation.settings.use_cds then
        return
    end
    if target and target.exists then
        if target.level == -1 and player.buffStacks("Shadow Weaving") == 5 then
            if spell:Cast(target) then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end
end)

pve_mind_blast:Callback(function(spell)
    if not rotation.settings.use_mind_blast then
        return
    end
    if player.moving then
        return
    end
    if target and target.exists then
        if player.buffStacks("Shadow Weaving") == 5 then
            if spell:Cast(target) then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end
end)

pve_mind_flay:Callback(function(spell)
    if player.moving then
        return
    end
    if target and target.exists then
        if player.buffStacks("Shadow Weaving") == 5 then
            if spell:Cast(target) then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end
end)

pve_shadow_word_pain:Callback(function(spell)
    if not target or not target.exists then
        return
    end
    -- (ICC) Shroud of the Occult: Envelops the caster in a powerful barrier that deflects all harmful magic,
    -- prevents cast interruption, and absorbs up to 50000 damage before breaking.
    if target.buff("Shroud of the Occult") then
        return
    end
    -- (Heroic+) Mirror Image: This NPC can be found in The Oculus , The Nexus , and The Violet Hold.
    if target.name == "Mirror Image" then
        return
    end
    if not target.debuff("Shadow Word: Pain", player) and player.buffStacks("Shadow Weaving") == 5 and target.ttd >= 14 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

pve_shadow_word_death:Callback(function(spell)
    if not target or not target.exists then
        return
    end
    -- (ICC) Shroud of the Occult: Envelops the caster in a powerful barrier that deflects all harmful magic,
    -- prevents cast interruption, and absorbs up to 50000 damage before breaking.
    if target.buff("Shroud of the Occult") then
        return
    end
    -- (Heroic+) Mirror Image: This NPC can be found in The Oculus , The Nexus , and The Violet Hold.
    if target.name == "Mirror Image" then
        return
    end
    -- (Ulduar) Profound Darkness: Inflicts 750 damage to all enemies, and increases Shadow damage taken by 10% per application.
    if player.debuff("Profound Darkness") then
        return
    end
    if player.moving then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)
