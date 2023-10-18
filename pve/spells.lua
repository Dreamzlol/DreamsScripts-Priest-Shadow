local Unlocker, awful, rotation = ...
local shadow = rotation.priest.shadow
local Spell = awful.Spell
local player, target = awful.player, awful.target
local NewItem = awful.NewItem

if not awful.player.class2 == "PRIEST" then
    return
end
if not (rotation.settings.mode == "PvE") then
    return
end

local getItemId = function(slot)
    itemId = GetInventoryItemID("player", slot)
    return itemId
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
    pve_shadow_word_pain  = Spell(48125, { damage = "magic", ignoreFacing = true }),
    pve_mind_sear         = Spell(53023, { damage = "magic", ignoreFacing = true }),
    pve_shadowfiend       = Spell(34433, { damage = "magic", ignoreFacing = true }),
    pve_shadow_word_death = Spell(48158, { damage = "magic", ignoreFacing = true }),

    -- Items
    pve_inventory_slot_10 = NewItem(getItemId(10)),
    pve_inventory_slot_13 = NewItem(getItemId(13)),
    pve_inventory_slot_14 = NewItem(getItemId(14)),
    pve_saronite_bomb     = NewItem(41119),
    pve_potion_of_speed   = NewItem(40211),
}, shadow, getfenv(1))

local function filter(obj)
    return obj.combat and obj.los and obj.distance < 40 and obj.enemy and not obj.dead
end

pve_saronite_bomb:Update(function(item)
    if not rotation.settings.useSaroniteBomb then
        return
    end
    if not target or not target.exists then
        return
    end
    if target.dist > item.range then
        return
    end
    if not item.usable then
        return
    end
    if player.casting or player.channel then
        return
    end

    if target.level == -1 then
        if item:UseAoE(target) then
            return awful.alert(item.name, item.id)
        end
    end
end)

pve_potion_of_speed:Update(function(item)
    if not rotation.settings.use_potion_speed then
        return
    end
    if not target or not target.exists then
        return
    end
    if not item.usable then
        return
    end
    if player.casting or player.channel then
        return
    end

    if target.level == -1 then
        if item:Use() then
            return awful.alert(item.name, 53908)
        end
    end
end)

pve_inventory_slot_10:Update(function(item)
    if not rotation.settings.use_cds then
        return
    end
    if not target or not target.exists then
        return
    end
    if not item.usable then
        return
    end
    if player.moving then
        return
    end
    if player.casting or player.channel then
        return
    end

    if target.level == -1 or (target.level == 82 and player.buff("Luck of the Draw")) then
        if item:Use() then
            return awful.alert("Hyperspeed Acceleration", 54758)
        end
    end
end)

pve_inventory_slot_13:Update(function(item)
    if not rotation.settings.use_cds then
        return
    end
    if not target or not target.exists then
        return
    end
    if not item.usable then
        return
    end
    if player.moving then
        return
    end
    if player.casting or player.channel then
        return
    end

    if target.level == -1 or (target.level == 82 and player.buff("Luck of the Draw")) then
        if item:Use() then
            return awful.alert(item.name, item.id)
        end
    end
end)

pve_inventory_slot_14:Update(function(item)
    if not rotation.settings.use_cds then
        return
    end
    if not target or not target.exists then
        return
    end
    if not item.usable then
        return
    end
    if player.moving then
        return
    end
    if player.casting or player.channel then
        return
    end

    if target.level == -1 or (target.level == 82 and player.buff("Luck of the Draw")) then
        return item:Use()
    end
end)

awful.Draw(function(draw)
    if not rotation.settings.use_draw_ttd then
        return
    end
    draw:SetColor(255, 102, 255, 100)
    awful.enemies.loop(function(enemy)
        if not enemy or not enemy.exists then
            return
        end
        if not enemy.los and enemy.distance > 40 then
            return
        end
        if enemy.ttd > 600 then
            return
        end
        if enemy.combat and not enemy.dead then
            local x, y, z = enemy.position()
            local timer = string.format("%.0f", enemy.ttd)

            draw:Text("TTD: " .. timer .. "secs", "GameFontNormal", x, y, z)
        end
    end)
end)

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
    if not (player.buffStacks("Shadow Weaving") == 5) then
        return
    end
    if target.level == -1 or (target.level == 82 and player.buff("Luck of the Draw")) then
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
    if player.moving then
        return
    end
    if not (player.buffStacks("Shadow Weaving") == 5) then
        return
    end
    if target.level == -1 or (target.level == 82 and player.buff("Luck of the Draw")) then
        if spell:Cast() then
            pve_mind_flay:Cast()
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

pve_shadow_word_pain:Callback("aoe", function(spell)
    if not rotation.settings.useAoe then
        return
    end
    if not rotation.settings.aoeRotation["Shadow Word: Pain"] then
        return
    end

    awful.enemies.within(40).filter(filter).loop(function(enemy)
        if not enemy or not enemy.exists then
            return
        end
        if enemy.buff("Shroud of the Occult") then
            return
        end
        if enemy.name == "Mirror Image" then
            return
        end
        if enemy.ttd < rotation.settings.ttd_timer then
            return
        end
        if not (player.buffStacks("Shadow Weaving") == 5) then
            return
        end
        if not enemy.debuff("Shadow Word: Pain", player) then
            if spell:Cast(enemy) then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end)
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
    if not rotation.settings.aoeRotation["Vampiric Touch"] then
        return
    end

    awful.enemies.within(40).filter(filter).loop(function(enemy)
        if not enemy or not enemy.exists then
            return
        end
        if enemy.buff("Shroud of the Occult") then
            return
        end
        if enemy.name == "Mirror Image" then
            return
        end
        if enemy.ttd < rotation.settings.ttd_timer then
            return
        end
        if enemy.debuffRemains(spell.id, player) <= spell.castTime then
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
    if not target or not target.exists then
        return
    end
    if player.moving then
        return
    end
    if not rotation.settings.aoeRotation["Mind Sear"] then
        return
    end
    local count = awful.enemies.around(target, 12, function(obj) return obj.combat and obj.enemy and not obj.dead end)
    if count >= 7 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

pve_mind_sear:Callback("aoe_vt", function(spell)
    if not rotation.settings.useAoe then
        return
    end
    if not target or not target.exists then
        return
    end
    if player.moving then
        return
    end
    if not rotation.settings.aoeRotation["Mind Sear"] then
        return
    end
    local count = awful.enemies.around(target, 12,
        function(obj) return obj.combat and obj.enemy and not obj.dead and obj.debuff("Vampiric Touch", player) end)
    if count >= 3 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
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
    if target.buff("Shroud of the Occult") then
        return
    end
    if target.name == "Mirror Image" then
        return
    end
    if target.ttd < rotation.settings.ttd_timer then
        return
    end
    if player.buff("Shadow Weaving") then
        return
    end
    if target.debuffRemains(spell.id, player) <= spell.castTime then
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
    if target.buff("Shroud of the Occult") then
        return
    end
    if target.ttd < rotation.settings.ttd_timer then
        return
    end
    if not (player.buffStacks("Shadow Weaving") == 1) then
        return
    end
    if not target.debuff(spell.id, player) then
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
    if not target or not target.exists then
        return
    end
    if player.moving then
        return
    end
    if not (player.buffStacks("Shadow Weaving") == 2) then
        return
    end
    if target.debuff("Vampiric Touch", player) then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

pve_shadowfiend:Callback("opener", function(spell)
    if not rotation.settings.use_cds then
        return
    end
    if not target or not target.exists then
        return
    end
    if not target.debuff("Vampiric Touch", player) then
        return
    end
    if not (player.buffStacks("Shadow Weaving") == 3) then
        return
    end

    if target.level == -1 or (target.level == 82 and player.buff("Luck of the Draw")) then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

pve_mind_flay:Callback("opener", function(spell)
    if player.moving then
        return
    end
    if not target or not target.exists then
        return
    end
    if not (player.buffStacks("Shadow Weaving") == 3) then
        return
    end
    if target.debuff("Vampiric Touch", player) then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

pve_shadow_word_pain:Callback("opener", function(spell)
    if not target or not target.exists then
        return
    end
    if target.buff("Shroud of the Occult") then
        return
    end
    if target.name == "Mirror Image" then
        return
    end
    if target.ttd < rotation.settings.ttd_timer then
        return
    end
    if not (player.buffStacks("Shadow Weaving") == 5) then
        return
    end
    if not target.debuff(spell.id, player) then
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
    if target.buff("Shroud of the Occult") then
        return
    end
    if target.name == "Mirror Image" then
        return
    end
    if target.ttd < rotation.settings.ttd_timer then
        return
    end
    if not (player.buffStacks("Shadow Weaving") == 5) then
        return
    end
    if target.debuffRemains(spell.id, player) <= spell.castTime then
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
    if target.buff("Shroud of the Occult") then
        return
    end
    if target.ttd < rotation.settings.ttd_timer then
        return
    end
    if not (player.buffStacks("Shadow Weaving") == 5) then
        return
    end
    if target.debuffRemains(spell.id, player) <= 2.9 then
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
    if not target or not target.exists then
        return
    end
    if not (player.buffStacks("Shadow Weaving") == 5) then
        return
    end
    if target.level == -1 or (target.level == 82 and player.buff("Luck of the Draw")) then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

pve_mind_blast:Callback(function(spell)
    if not rotation.settings.use_mind_blast then
        return
    end
    if not target or not target.exists then
        return
    end
    if player.moving then
        return
    end
    if not (player.buffStacks("Shadow Weaving") == 5) then
        return
    end
    if spell:Cast(target) then
        awful.alert(spell.name, spell.id)
        return
    end
end)

pve_mind_flay:Callback(function(spell)
    if not target or not target.exists then
        return
    end
    if player.moving then
        return
    end
    if not (player.buffStacks("Shadow Weaving") == 5) then
        return
    end
    if spell:Cast(target) then
        awful.alert(spell.name, spell.id)
        return
    end
end)

pve_mind_flay:Callback("mirror image", function(spell)
    if not player.buff("Luck of the Draw") then
        return
    end
    if player.moving then
        return
    end
    awful.enemies.loop(function(enemy)
        if not enemy then
            return
        end
        if enemy.name == "Mirror Image" then
            if spell:Cast(enemy) then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end)
end)

pve_shadow_word_pain:Callback(function(spell)
    if not target or not target.exists then
        return
    end
    if target.buff("Shroud of the Occult") then
        return
    end
    if target.name == "Mirror Image" then
        return
    end
    if target.ttd < rotation.settings.ttd_timer then
        return
    end
    if not (player.buffStacks("Shadow Weaving") == 5) then
        return
    end
    if not target.debuff(spell.id, player) then
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
    if target.buff("Shroud of the Occult") then
        return
    end
    if target.name == "Mirror Image" then
        return
    end
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

pve_shadow_word_death:Callback("web wrap", function(spell)
    if not player.buff("Luck of the Draw") then
        return
    end
    if player.debuff("Web Wrap") then
        return
    end
    awful.units.loop(function(obj)
        if not obj then
            return
        end
        if obj.name == "Web Wrap" then
            if spell:Cast(obj) then
                awful.alert(spell.name .. " (Web Wrap)", spell.id)
                return
            end
        end
    end)
end)

pve_mind_flay:Callback("web wrap", function(spell)
    if not player.buff("Luck of the Draw") then
        return
    end
    if player.debuff("Web Wrap") then
        return
    end
    awful.units.loop(function(obj)
        if not obj then
            return
        end
        if obj.name == "Web Wrap" then
            if spell:Cast(obj) then
                awful.alert(spell.name .. " (Web Wrap)", spell.id)
                return
            end
        end
    end)
end)
