local Unlocker, awful, rotation = ...
local shadow = rotation.priest.shadow
local spell = awful.Spell
local player, target = awful.player, awful.target
local item = awful.Item

if not awful.player.class2 == "PRIEST" then
    return
end

local getItemID = function(slot)
    itemID = GetInventoryItemID("player", slot)
    return itemID
end

awful.Populate({
    -- Racials
    berserking         = spell(26297, { beneficial = true }),
    -- Items
    inventorySlot10    = item(getItemID(10)),
    inventorySlot13    = item(getItemID(13)),
    inventorySlot14    = item(getItemID(14)),
    saroniteBomb       = item(41119),
    globalSapperCharge = item(42641),
    potionOfSpeed      = item(40211),
    healthstone        = item({ 36892, 36894, 36893, 36891, 36890, 36889 }),
    -- Buffs
    shadowform         = spell(15473, { beneficial = true }),
    innerFire          = spell(48168, { beneficial = true }),
    vampiricEmbrace    = spell(15286, { beneficial = true }),
    dispersion         = spell(47585, { beneficial = true }),
    innerFocus         = spell(14751, { beneficial = true }),
    -- Damage
    mindBlast          = spell(48127, { damage = "magic" }),
    mindFlay           = spell(48156, { damage = "magic" }),
    vampiricTouch      = spell(48160, { damage = "magic", ignoreFacing = true }),
    devouringPlague    = spell(48300, { damage = "magic", ignoreFacing = true }),
    shadowWordPain     = spell(48125, { damage = "magic", ignoreFacing = true }),
    mindSear           = spell(53023, { damage = "magic", ignoreFacing = true }),
    shadowfiend        = spell(34433, { damage = "magic", ignoreFacing = true }),
    shadowWordDeath    = spell(48158, { damage = "magic", ignoreFacing = true }),
}, shadow, getfenv(1))

local function filter(obj)
    return obj.combat and obj.los and obj.distance < 40 and obj.enemy and not obj.dead
end

local function isBoss(unit)
    if unit.level == -1 or (unit.level == 82 and player.buff("Luck of the Draw")) then
        return true
    end
end

local wasCasting = {}
function shadow.WasCastingCheck()
    local time = awful.time
    if player.casting then
        wasCasting[player.castingid] = time
    end
    for spell, when in pairs(wasCasting) do
        if time - when > 0.100 + awful.buffer then
            wasCasting[spell] = nil
        end
    end
end

saroniteBomb:Update(function(item)
    if not rotation.settings.useSaroniteBomb then return end
    if not target or not target.exists then return end
    if target.distance >= 27 then return end
    if target.moving then return end
    if not item.usable then return end
    if player.moving then return end
    if player.casting or player.channel then return end

    if target.level == -1 then
        if item:UseAoE(target) then
            return awful.alert(item.name, item.id)
        end
    end
end)

globalSapperCharge:Update(function(item)
    if not rotation.settings.useGlobalSapperCharge then return end
    if not target or not target.exists then return end
    if target.distance >= 13 then return end
    if target.moving then return end
    if not item.usable then return end
    if player.casting or player.channel then return end

    if target.level == -1 then
        if item:Use() then
            return awful.alert(item.name, item.id)
        end
    end
end)

potionOfSpeed:Update(function(item)
    if not rotation.settings.usePotionSpeed then return end
    if not target or not target.exists then return end
    if not item.usable then return end
    if player.moving then return end
    if player.casting or player.channel then return end

    if target.level == -1 then
        if item:Use() then
            return awful.alert(item.name, 53908)
        end
    end
end)

healthstone:Update(function(item)
    if not item.usable then return end
    if player.casting or player.channel then return end

    if player.hp <= rotation.settings.useHealthstone then
        if item:Use() then
            return awful.alert(item.name, item.id)
        end
    end
end)

inventorySlot10:Update(function(item)
    if not rotation.settings.use_cds then return end
    if not target or not target.exists then return end
    if not item.usable then return end
    if player.moving then return end
    if player.casting or player.channel then return end

    if isBoss(target) then
        if item:Use() then
            return awful.alert("Hyperspeed Acceleration", 54758)
        end
    end
end)

inventorySlot13:Update(function(item)
    if not rotation.settings.use_cds then return end
    if not target or not target.exists then return end
    if not item.usable then return end
    if player.moving then return end
    if player.casting or player.channel then return end

    if isBoss(target) then
        if item:Use() then
            return awful.alert(item.name, item.id)
        end
    end
end)

inventorySlot14:Update(function(item)
    if not rotation.settings.use_cds then return end
    if not target or not target.exists then return end
    if not item.usable then return end
    if player.moving then return end
    if player.casting or player.channel then return end

    if isBoss(target) then
        return item:Use()
    end
end)

awful.Draw(function(draw)
    if not rotation.settings.use_draw_ttd then return end

    draw:SetColor(255, 102, 255, 100)
    awful.enemies.loop(function(enemy)
        if not enemy or not enemy.exists then return end
        if not enemy.los and enemy.distance > 40 then return end
        if enemy.dead then return end
        if enemy.ttd > 600 then return end

        if enemy.combat then
            local x, y, z = enemy.position()
            local timer = string.format("%.0f", enemy.ttd)

            draw:Text("TTD: " .. timer .. "secs", "GameFontNormal", x, y, z)
        end
    end)
end)

shadowform:Callback(function(spell)
    if not player.buff(spell.id) then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

innerFire:Callback(function(spell)
    if not player.buff(spell.id) then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

berserking:Callback(function(spell)
    if not rotation.settings.use_cds then return end

    if isBoss(target) then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

innerFocus:Callback(function(spell)
    if not rotation.settings.use_cds then return end
    if player.moving then return end
    if target.debuffRemains("Vampiric Touch", player) < 2
        and target.debuffRemains("Devouring Plague", player) < 2
        and target.debuffRemains("Shadow Word: Pain", player) < 2 then
        return
    end

    if player.buffStacks("Shadow Weaving") == 5 and isBoss(target) then
        if spell:Cast() then
            return awful.alert(spell.name, spell.id)
        end
    end
end)

vampiricEmbrace:Callback(function(spell)
    if not player.buff(spell.id) then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

shadowWordPain:Callback("aoe", function(spell)
    if not rotation.settings.useAoe then return end
    if not rotation.settings.aoeRotation["Shadow Word: Pain"] then return end

    awful.enemies.within(40).filter(filter).loop(function(enemy)
        if not enemy or not enemy.exists then return end
        if enemy.buff("Shroud of the Occult") then return end
        if enemy.name == "Mirror Image" then return end
        if enemy.ttd < rotation.settings.ttd_timer then return end

        if player.buffStacks("Shadow Weaving") == 5 and not enemy.debuff(spell.id, player) then
            if spell:Cast(enemy) then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end)
end)

vampiricTouch:Callback("aoe", function(spell)
    if not rotation.settings.useAoe then return end
    if not rotation.settings.aoeRotation["Vampiric Touch"] then return end
    if wasCasting[spell.id] then return end
    if player.moving then return end

    awful.enemies.within(40).filter(filter).loop(function(enemy)
        if not enemy or not enemy.exists then return end
        if enemy.buff("Shroud of the Occult") then return end
        if enemy.name == "Mirror Image" then return end
        if enemy.ttd < rotation.settings.ttd_timer then return end

        if enemy.debuffRemains(spell.id, player) <= spell.castTime then
            if spell:Cast(enemy) then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end)
end)

mindSear:Callback("aoe", function(spell)
    if not rotation.settings.useAoe then return end
    if not rotation.settings.aoeRotation["Mind Sear"] then return end
    if not target or not target.exists then return end
    if player.moving then return end

    local count = awful.enemies.around(target, 12, function(obj) return obj.combat and obj.enemy and not obj.dead end)
    if count >= 7 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

mindSear:Callback("aoe_vt", function(spell)
    if not rotation.settings.useAoe then return end
    if not rotation.settings.aoeRotation["Mind Sear"] then return end
    if not target or not target.exists then return end
    if player.moving then return end

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
vampiricTouch:Callback("opener", function(spell)
    if not target or not target.exists then return end
    if wasCasting[spell.id] then return end
    if player.moving then return end
    if target.buff("Shroud of the Occult") then return end
    if target.name == "Mirror Image" then return end
    if target.ttd < rotation.settings.ttd_timer then return end
    if player.buff("Shadow Weaving") then return end

    if not target.debuff(spell.id, player) or target.debuffRemains(spell.id, player) <= spell.castTime then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

devouringPlague:Callback("opener", function(spell)
    if not target or not target.exists then return end
    if not target.debuff("Vampiric Touch", player) then return end
    if target.buff("Shroud of the Occult") then return end
    if target.ttd < rotation.settings.ttd_timer then return end

    if player.buffStacks("Shadow Weaving") <= 1 and not target.debuff(spell.id, player) then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

mindBlast:Callback("opener", function(spell)
    if not rotation.settings.use_mind_blast then return end
    if not target or not target.exists then return end
    if player.moving then return end

    if player.buffStacks("Shadow Weaving") <= 2 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

shadowfiend:Callback("opener", function(spell)
    if not rotation.settings.use_cds then return end
    if not target or not target.exists then return end
    if not target.debuff("Vampiric Touch", player) then return end

    if player.buffStacks("Shadow Weaving") <= 3 and isBoss(target) then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

mindFlay:Callback("opener", function(spell)
    if not target or not target.exists then return end
    if player.moving then return end

    if player.buffStacks("Shadow Weaving") <= 3 and target.debuff("Vampiric Touch", player) then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

shadowWordPain:Callback("opener", function(spell)
    if not target or not target.exists then return end
    if target.buff("Shroud of the Occult") then return end
    if target.name == "Mirror Image" then return end
    if target.ttd < rotation.settings.ttd_timer then return end

    if player.buffStacks("Shadow Weaving") == 5 and not target.debuff(spell.id, player) then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

-- Main Rotation
vampiricTouch:Callback(function(spell)
    if not target or not target.exists then return end
    if wasCasting[spell.id] then return end
    if player.moving then return end
    if target.buff("Shroud of the Occult") then return end
    if target.name == "Mirror Image" then return end
    if target.ttd < rotation.settings.ttd_timer then return end

    if player.buffStacks("Shadow Weaving") == 5 and target.debuffRemains(spell.id, player) <= spell.castTime then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

devouringPlague:Callback(function(spell)
    if not target or not target.exists then return end
    if target.buff("Shroud of the Occult") then return end
    if target.ttd < rotation.settings.ttd_timer then return end

    if player.buffStacks("Shadow Weaving") == 5 and target.debuffRemains(spell.id, player) <= 1.75 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

shadowfiend:Callback(function(spell)
    if not rotation.settings.use_cds then return end
    if not target or not target.exists then return end

    if player.buffStacks("Shadow Weaving") == 5 and isBoss(target) then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

mindBlast:Callback(function(spell)
    if not rotation.settings.use_mind_blast then return end
    if not target or not target.exists then return end
    if player.moving then return end

    if player.buffStacks("Shadow Weaving") == 5 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

mindFlay:Callback(function(spell)
    if not target or not target.exists then return end
    if player.moving then return end

    if player.buffStacks("Shadow Weaving") == 5 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

mindFlay:Callback("mirror image", function(spell)
    if not player.buff("Luck of the Draw") then return end
    if player.moving then return end

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

shadowWordPain:Callback(function(spell)
    if not target or not target.exists then return end
    if target.buff("Shroud of the Occult") then return end
    if target.name == "Mirror Image" then return end
    if target.ttd < rotation.settings.ttd_timer then return end

    if player.buffStacks("Shadow Weaving") == 5 and not target.debuff(spell.id, player) then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

shadowWordDeath:Callback(function(spell)
    if not target or not target.exists then return end
    if target.buff("Shroud of the Occult") then return end
    if target.name == "Mirror Image" then return end
    if player.debuff("Profound Darkness") then return end

    if player.moving then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

shadowWordDeath:Callback("web wrap", function(spell)
    if not player.buff("Luck of the Draw") then return end
    if player.debuff("Web Wrap") then return end

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

mindFlay:Callback("web wrap", function(spell)
    if not player.buff("Luck of the Draw") then return end
    if player.debuff("Web Wrap") then return end

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
