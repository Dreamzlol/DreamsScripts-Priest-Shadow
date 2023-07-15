local Unlocker, awful, rotation = ...
local shadow = rotation.priest.shadow
local Spell = awful.Spell
local player, target = awful.player, awful.target

awful.Populate({
    -- Buffs
    shadowform          = Spell(15473, { beneficial = true }),
    inner_fire          = Spell(48168, { beneficial = true }),
    vampiric_embrace    = Spell(15286, { beneficial = true }),
    dispersion          = Spell(47585),

    -- Damage
    mind_blast          = Spell(48127, { damage = "magic" }),
    mind_flay           = Spell(48156, { damage = "magic" }),
    vampiric_touch      = Spell(48160, { damage = "magic", ignoreFacing = true }),
    devouring_plague    = Spell(48300, { damage = "magic", ignoreFacing = true }),
    shadow_word_pain    = Spell(2767, { damage = "magic", ignoreFacing = true }),
    mind_sear           = Spell(53023, { damage = "magic", ignoreFacing = true }),
    shadowfiend         = Spell(34433, { damage = "magic", ignoreFacing = true }),
    shadow_word_death   = Spell(48158, { damage = "magic", ignoreFacing = true }),

    -- Items
    engineer_gloves     = Spell(6603, { ignoreFacing = true }),
}, shadow, getfenv(1))

local function isBoss(unit)
    return unit.level == -1
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

shadowform:Callback(function(spell)
    if not player.buff("Shadowform") then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

inner_fire:Callback(function(spell)
    if not player.buff("Inner Fire") then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

vampiric_embrace:Callback(function(spell)
    if not player.buff("Vampiric Embrace") then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

local function useInventoryItem()
    RunMacroText("/use 10");
end

engineer_gloves:Callback(function(spell)
    local start = GetInventoryItemCooldown("player", 10)
    if target.enemy and isBoss(target) and start == 0 then
        if useInventoryItem() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

vampiric_touch:Callback("aoe", function(spell)
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

    local count, _, objects = awful.enemies.around(player, 36, function(obj)
        return obj.combat
    end)
    if count >= 2 then
        for i, enemy in ipairs(objects) do
            if enemy.debuffRemains("Vampiric Touch", player) < 1 and enemy.ttd > 20 then
                if spell:Cast(enemy) then
                    awful.alert(spell.name, spell.id)
                    return
                end
            end
        end
    end
end)

shadow_word_pain:Callback("aoe", function(spell)
    if not rotation.settings.useAoe then
        return
    end

    if not SettingsCheck(rotation.settings.aoeRotation, "Shadow Word: Pain") then
        return
    end

    local count, _, objects = awful.enemies.around(player, 36, function(obj)
        return obj.combat
    end)
    if count >= 2 then
        for i, enemy in ipairs(objects) do
            if not enemy.debuff("Shadow Word: Pain", player) and enemy.ttd > 20 then
                if spell:Cast(enemy) then
                    awful.alert(spell.name, spell.id)
                    return
                end
            end
        end
    end
end)

mind_sear:Callback("aoe", function(spell)
    if player.moving then
        return
    end
    if not SettingsCheck(rotation.settings.aoeRotation, "Mind Sear") then
        return
    end

    local count, _, objects = awful.enemies.around(target, 10)
    if target.enemy and count >= rotation.settings.mind_sear then
        for i, unit in ipairs(objects) do
            if unit.debuff("Shadow Word: Pain", player) and unit.debuff("Vampiric Touch", player) then
                if spell:Cast(target) then
                    awful.alert(spell.name, spell.id)
                    return
                end
            end
        end
    end
end)

-- Opener Rotation
vampiric_touch:Callback("opener", function(spell)
    if player.casting then
        return
    end
    if player.moving then
        return
    end

    if target.enemy and target.debuffRemains("Vampiric Touch", player) < 1 and player.buffStacks("Shadow Weaving") < 2 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

devouring_plague:Callback("opener", function(spell)
    if not target.debuff("Vampiric Touch", player) then
        return
    end

    if target.enemy and not target.debuff("Devouring Plague", player) and player.buffStacks("Shadow Weaving") <= 2 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

mind_blast:Callback("opener", function(spell)
    if player.moving then
        return
    end

    if target.enemy and target.debuff("Vampiric Touch", player) and player.buffStacks("Shadow Weaving") <= 3 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

shadowfiend:Callback("opener", function(spell)
    if target.enemy and isBoss(target) and target.debuff("Vampiric Touch", player) and
        player.buffStacks("Shadow Weaving") <= 3 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

mind_flay:Callback("opener", function(spell)
    if player.moving then
        return
    end

    if target.enemy and target.debuff("Vampiric Touch", player) and player.buffStacks("Shadow Weaving") < 5 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

shadow_word_pain:Callback("opener", function(spell)
    if target.enemy and not target.debuff("Shadow Word: Pain", player) and player.buffStacks("Shadow Weaving") == 5 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

-- Main Rotation
vampiric_touch:Callback(function(spell)
    if player.casting then
        return
    end
    if player.moving then
        return
    end

    if target.enemy and target.debuffRemains("Vampiric Touch", player) < 1 and player.buffStacks("Shadow Weaving") == 5 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

devouring_plague:Callback(function(spell)
    if target.enemy and not target.debuff("Devouring Plague", player) and player.buffStacks("Shadow Weaving") == 5 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

shadowfiend:Callback(function(spell)
    if target.enemy and isBoss(target) and player.buffStacks("Shadow Weaving") == 5 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

mind_blast:Callback(function(spell)
    if player.moving then
        return
    end

    if target.enemy and player.buffStacks("Shadow Weaving") == 5 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

mind_flay:Callback(function(spell)
    if player.moving then
        return
    end

    if target.enemy and player.buffStacks("Shadow Weaving") == 5 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

shadow_word_pain:Callback(function(spell)
    if target.enemy and not target.debuff("Shadow Word: Pain", player) and player.buffStacks("Shadow Weaving") == 5 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

shadow_word_death:Callback(function(spell)
    if target.enemy and player.moving then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)
