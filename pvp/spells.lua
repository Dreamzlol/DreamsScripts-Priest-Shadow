local Unlocker, awful, rotation = ...
local shadow = rotation.priest.shadow
local spell = awful.Spell
local player, target, focus = awful.player, awful.target, awful.focus
local item = awful.Item

if not awful.player.class2 == "PRIEST" then return end

local getItemID = function(slot)
    itemID = GetInventoryItemID("player", slot)
    return itemID
end

awful.Populate({
    -- Buffs
    FearWard        = spell(6346, { beneficial = true, ignoreCasting = true, ignoreChanneling = true }),
    PowerWordShield = spell(48066, { beneficial = true, ignoreUsable = true, ignoreCasting = true }),
    InnerFire       = spell(48168, { beneficial = true }),
    Shadowform      = spell(15473, { beneficial = true }),
    VampiricEmbrace = spell(15286, { beneficial = true }),
    Fade            = spell(586, { beneficial = true }),

    -- Heals
    PrayerOfMending = spell(48113, { heal = true }),
    BindingHeal     = spell(48120, { heal = true }),
    FlashHeal       = spell(48071, { heal = true }),
    Renew           = spell(48068, { heal = true }),

    -- Damage spells
    Shadowfiend     = spell(34433, { effect = "magic", ignoreFacing = true, ignoreMoving = true }),
    MindBlast       = spell(48127, { effect = "magic", targeted = true }),
    VampiricTouch   = spell(48160, { effect = "magic", targeted = true, ignoreFacing = true }),
    MindFlay        = spell(48156, { effect = "magic" }),
    DevouringPlague = spell(48300, { effect = "magic", targeted = true, ignoreFacing = true, ignoreMoving = true }),
    ShadowWordPain  = spell(48125, { effect = "magic", targeted = true, ignoreFacing = true, ignoreMoving = true }),
    ShadowWordDeath = spell(48158, { effect = "magic", targeted = true, ignoreFacing = true, ignoreMoving = true, ignoreCasting = true, ignoreChanneling = true }),

    -- Others
    HolyNova        = spell(48078, { radius = 10, ignoreCasting = true, ignoreChanneling = true }),
    ShackleUndead   = spell(10955, { effect = "magic", ignoreFacing = true, cc = true }),
    PsychicScream   = spell(10890, { effect = "magic", ignoreFacing = true, cc = "fear", ignoreCasting = true, ignoreChanneling = true }),
    MassDispel      = spell(32375, { ignoreFacing = true, radius = 15 }),
    DispelMagic     = spell(988, { effect = "magic", ignoreFacing = true }),
    Shoot           = spell(5019, { ignoreChanneling = true, ignoreCasting = true }),
    AbolishDisease  = spell(552, { effect = "magic", ignoreFacing = true, ignoreLoS = true }),
    Silence         = spell(15487, { effect = "magic", cc = true, targeted = true, ignoreFacing = true, ignoreCasting = true, ignoreChanneling = true }),
    PsychicHorror   = spell(64044, { effect = "magic", targeted = true, ignoreCasting = true, ignoreChanneling = true }),
    Dispersion      = spell(47585, { beneficial = true, ignoreControl = true, ignoreMoving = true }),

    -- Items
    InventorySlot10 = item(getItemID(10)),
}, shadow, getfenv(1))

local function unitFilter(obj)
    return obj.los and obj.exists and not obj.dead
end

local wasCasting = {}
function WasCastingCheck()
    local time = awful.time
    if player.casting then
        wasCasting[player.castingid] = time
    end
    for spell, when in pairs(wasCasting) do
        if time - when > 0.100+awful.buffer then
            wasCasting[spell] = nil
        end
    end
end

local function findTremorTotem()
    if awful.fighting("SHAMAN") then
        return awful.totems.find(function(obj)
            return obj.id == 5913
        end)
    end
    return nil
end

local tremor = findTremorTotem()

local Draw = awful.Draw
Draw(function(draw)
    local ex, ey, ez = awful.focus.position()
    local px, py, pz = awful.player.position()

    if focus.exists and not focus.buff("Fear Ward") and not tremor then
        draw:SetColor(204, 153, 255, 100) -- ready
        draw:Circle(px, py, pz, 8)

        draw:SetColor(102, 255, 102, 100) -- ready
        draw:FilledCircle(ex, ey, ez, 1)
    else
        draw:SetColor(255, 51, 51, 100) -- not ready
        draw:FilledCircle(ex, ey, ez, 1)
    end
end)

local spellStopCasting = awful.unlock("SpellStopCasting")

local swdCc = {
    ["Blind"] = true,
    ["Gouge"] = true,
    ["Repentance"] = true,
    ["Scatter Shot"] = true,
    ["Freezing Arrow"] = true,
}

awful.onEvent(function(info, event, source, dest)
    if event == "SPELL_CAST_SUCCESS" then
        if not source.enemy then return end

        local _, spellName = select(12, unpack(info))
        if swdCc[spellName] then
            spellStopCasting()
            ShadowWordDeath:Cast(source)
            return
        end
    end
end)

local swdCast = {
    ["Polymorph"] = true,
    ["Seduction"] = true,
}

ShadowWordDeath:Callback("polymorph", function(spell)
    awful.enemies.loop(function(unit)
        if swdCast[unit.casting] and unit.castRemains <= awful.buffer + awful.latency + 0.3 then
            spellStopCasting()
            if spell:Cast(unit) then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end)
end)

ShadowWordDeath:Callback("seduction", function(spell)
    awful.enemyPets.loop(function(unit)
        if swdCast[unit.casting] and unit.castRemains <= awful.buffer + awful.latency + 0.3 then
            spellStopCasting()
            if spell:Cast(unit) then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end)
end)

Shoot:Callback("tremor", function(spell)
    awful.totems.stomp(function(totem, uptime)
        if uptime < 0.3 then return end

        if totem.id == 5913 then
            if not IsCurrentSpell(spell.id) then
                return spell:Cast(totem)
            end
        end
    end)
end)

ShadowWordDeath:Callback("execute", function(spell)
    if not target or not target.exists then return end

    if target.enemy and target.hp <= 20 then
        if spell:Cast(target) then
            awful.alert(spell.name .. " (Execute)", spell.id)
            return
        end
    end
end)

Shadowform:Callback(function(spell)
    if not player.buff(spell.id) and awful.fullGroup.lowest.hp >= 60 then
        return spell:Cast()
    end
end)

VampiricEmbrace:Callback(function(spell)
    if not player.buff(spell.id) then
        return spell:Cast()
    end
end)

Dispersion:Callback(function(spell)
    if not player.combat then return end

    if player.hp <= 40 then
        return spell:Cast()
    end
end)

local interruptCast = {
    ["Polymorph"] = true,
    ["Seduction"] = true,
    ["Fear"] = true,
    ["Chaos Bolt"] = true,
    ["Holy Light"] = true,
    ["Flash of Light"] = true,
    ["Flash Heal"] = true,
    ["Binding Heal"] = true,
    ["Greater Heal"] = true,
    ["Penance"] = true,
    ["Prayer of Healing"] = true,
    ["Vampiric Touch"] = true,
    ["Healing Wave"] = true,
    ["Lesser Healing Wave"] = true,
    ["Chain Heal"] = true,
    ["Regrowth"] = true,
    ["Rejuvenation"] = true,
    ["Healing Touch"] = true,
    ["Nourish"] = true,
    ["Cyclone"] = true
}

local interruptChannel = {
    ["Penance"] = true,
    ["Tranquility"] = true
}

Silence:Callback(function(spell)
    if target.hp > 80 then return end

    awful.enemies.loop(function(enemy)
        if not enemy.casting and not enemy.channeling then return end
        if enemy.silenceDR <= 0.25 then return end

        if interruptCast[enemy.cast] then
            if enemy.castRemains < awful.buffer + awful.latency + 0.03 then
                spellStopCasting()
                if spell:Cast(enemy) then
                    awful.alert(spell.name, spell.id)
                    return
                end
            end
        elseif interruptChannel[enemy.channel] then
            if enemy.channelRemains < awful.buffer + awful.latency + 1.0 then
                spellStopCasting()
                if spell:Cast(enemy) then
                    awful.alert(spell.name, spell.id)
                    return
                end
            end
        end
    end)
end)

PsychicHorror:Callback("disarm", function(spell)
    awful.enemies.loop(function(enemy)
        if enemy.buff("Bladestorm") then
            return spell:Cast(enemy)
        elseif enemy.buff("Shadow Dance") then
            return spell:Cast(enemy)
        end
    end)
end)

PsychicHorror:Callback("cc", function(spell)
    if focus.exists and target.hp <= 60 and not focus.debuff("Silence") and not focus.bcc then
        return spell:Cast(focus)
    end
end)

Fade:Callback(function(spell)
    if player.slowed or player.rooted then
        return spell:Cast()
    end
end)

DevouringPlague:Callback(function(spell)
    if not target or not target.exists then return end
    if target.bcc then return end

    if target.enemy and target.debuffRemains("Devouring Plague") <= 2 then
        return spell:Cast(target)
    end
end)

DevouringPlague:Callback("execute", function(spell)
    if not target or not target.exists then return end
    if target.bcc then return end

    if target.enemy and target.hp <= 20 then
        return spell:Cast(target)
    end
end)

ShadowWordPain:Callback(function(spell)
    if not target or not target.exists then return end
    if target.bcc then return end

    if target.enemy and target.debuffRemains("Shadow Word: Pain") <= 2 then
        return spell:Cast(target)
    end
end)

VampiricTouch:Callback(function(spell)
    if not target or not target.exists then return end
    if player.casting then return end
    if target.bcc then return end

    if target.enemy and target.debuffRemains("Vampiric Touch") <= spell.castTime then
        return spell:Cast(target)
    end
end)

MindFlay:Callback(function(spell)
    if not target or not target.exists then return end
    if target.bcc then return end
    if not target.debuff("Vampiric Touch", player) then return end
    if not target.debuff("Shadow Word: Pain", player) then return end
    if not target.debuff("Devouring Plague", player) then return end

    if target.enemy then
        return spell:Cast(target)
    end
end)

PowerWordShield:Callback(function(spell)
    awful.fullGroup.loop(function(unit)
        if not unit then return end
        if awful.prep then return end

        if awful.arena then
            if not unit.debuff("Weakened Soul") and not unit.buff("Power Word: Shield") then
                return spell:Cast(unit)
            end
        end
        if not awful.arena then
            if not player.debuff("Weakened Soul") and not player.buff("Power Word: Shield") then
                return spell:Cast(player)
            end
        end
    end)
end)

PrayerOfMending:Callback(function(spell)
    awful.fullGroup.loop(function(unit)
        if awful.arena then
            if not unit.buff("Prayer of Mending") and unit.hp <= 60 then
                return spell:Cast(unit)
            end
        end
        if not awful.arena then
            if not player.buff("Prayer of Mending") and player.hp <= 60 then
                return spell:Cast(player)
            end
        end
    end)
end)

BindingHeal:Callback(function(spell)
    if not awful.arena then return end

    awful.fullGroup.loop(function(unit)
        if unit.hp <= 60 and player.hp <= 60 then
            return spell:Cast(unit)
        end
    end)
end)

FlashHeal:Callback(function(spell)
    awful.fullGroup.loop(function(unit)
        if awful.arena then
            if unit.hp <= 60 then
                return spell:Cast(unit)
            end
        end
        if not awful.arena then
            if player.hp <= 60 then
                return spell:Cast(player)
            end
        end
    end)
end)

Renew:Callback(function(spell)
    awful.fullGroup.loop(function(unit)
        if awful.arena then
            if not unit.buff("Renew") and unit.hp <= 60 then
                return spell:Cast(unit)
            end
        end
        if not awful.arena then
            if not player.buff("Renew") and player.hp <= 60 then
                return spell:Cast(player)
            end
        end
    end)
end)

Shadowfiend:Callback(function(spell)
    if not target or not target.exists then return end
    if target.bcc then return end

    if target.enemy then
        if player.manaPct <= 20 or target.hp <= 60 then
            return spell:Cast(target)
        end
    end
end)

MindBlast:Callback(function(spell)
    if not target or not target.exists then return end
    if target.bcc then return end
    if not target.debuff("Vampiric Touch", player) then return end
    if not target.debuff("Shadow Word: Pain", player) then return end
    if not target.debuff("Devouring Plague", player) then return end

    if target.enemy then
        return spell:Cast(target)
    end
end)

HolyNova:Callback("snakes", function(spell)
    if player.debuff(25809) then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

HolyNova:Callback("heal", function(spell)
    if player.hp <= 20 and player.moving then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

HolyNova:Callback("stealth", function(spell)
    awful.enemies.loop(function(unit)
        if unit.buff("Shadow Dance") then return end

        if unit.stealth and unit.distance <= 10 then
            if spell:Cast() then
                return awful.alert("Rogue", spell.id)
            end
        end
    end)
end)

ShackleUndead:Callback("gargoyle", function(spell)
    awful.enemyPets.loop(function(unit)
        if unit.debuff("Shackle Undead") then return end

        if unit.id == 27829 then
            return spell:Cast(unit)
        end
    end)
end)

ShackleUndead:Callback("lich", function(spell)
    awful.enemies.loop(function(unit)
        if unit.debuff("Shackle Undead") then return end

        if unit.buff(49039) then
            return spell:Cast(unit)
        end
    end)
end)

local fearImmunity = { 6346, 49039, 48707, 642, 31224 }

PsychicScream:Callback("mutiple", function(spell)
    if awful.enemies.around(player, 6.5, function(enemy)
            return enemy.los and enemy.ccRemains <= 0.2 and not enemy.isPet and not enemy.buffFrom(fearImmunity) and
                not tremor
        end) >= 2 then
        if spell:Cast() then
            awful.alert(spell.name .. " (Mutiple)", spell.id)
            return
        end
    end
end)

PsychicScream:Callback("focus", function(spell)
    if not focus.exists then return end
    if focus.buffFrom(fearImmunity) then return end
    if not focus.los then return end
    if focus.debuff("Cyclone") then return end

    if focus.distanceLiteral <= 9 and focus.ccRemains <= 1.0 and not tremor then
        if spell:Cast() then
            awful.alert(spell.name .. " (Focus)", spell.id)
            return
        end
    end
end)

PsychicScream:Callback("lowhp", function(spell)
    awful.enemies.within(40).filter(unitFilter).loop(function(unit)
        if unit.distanceLiteral <= 9 and player.hp <= 20 then
            if spell:Cast() then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end)
end)

local dispelImmune = {
    ["Divine Shield"] = true,
    ["Ice Block"] = true
}

MassDispel:Callback("immune", function(spell)
    awful.enemies.loop(function(unit)
        for i, buff in ipairs(unit.buffs) do
            local name = unpack(buff)
            if dispelImmune[name] and awful.fullGroup.lowest.hp >= 40 then
                return spell:SmartAoE(unit)
            end
        end
    end)
end)

MassDispel:Callback("combat", function(spell)
    awful.enemies.loop(function(unit)
        if unit.debuff("Sap") and not player.combat then
            if spell:SmartAoE(unit) then
                awful.alert(spell.name .. " (Getting combat)", spell.id)
                return
            end
        end
    end)
end)

local dispelDisease = {
    ["Disease"] = true
}

AbolishDisease:Callback(function(spell)
    awful.fullGroup.loop(function(unit)
        if unit.hp <= 40 then return end
        if unit.buff("Abolish Disease") then return end

        for i = 1, #unit.debuffs do
            local _, _, _, type = unpack(unit['debuff' .. i])
            if dispelDisease[type] then
                return spell:Cast(unit)
            end
        end
    end)
end)

local dispelDefensive = {
    ["Earthgrab"] = true,
    ["Psychic Scream"] = true,
    ["Psychic Horror"] = true,
    ["Entrapment"] = true,
    ["Polymorph"] = true,
    ["Seduction"] = true,
    ["Frost Nova"] = true,
    ["Howl of Terror"] = true,
    ["Earthbind"] = true,
    ["Cone of Cold"] = true,
    ["Frost Bite"] = true,
    ["Deep Freeze"] = true,
    ["Pin"] = true,
    ["Hammer of Justice"] = true,
    ["Fear"] = true,
    ["Frost Shock"] = true,
    ["Entangling Roots"] = true,
    ["Freezing Arrow Effect"] = true,
    ["Freezing Trap"] = true,
    ["Chains of Ice"] = true,
    ["Immolate"] = true,
    ["Frostbolt"] = true,
    ["Dragon's Breath"] = true,
    ["Turn Evil"] = true,
    ["Repentance"] = true,
    ["Shadowflame"] = true,
    ["Hungering Cold"] = true,
    ["Hibernate"] = true,
    ["Freeze"] = true,
    ["Freezing Trap Effect"] = true,
    ["Strangulate"] = true,
    ["Death Coil"] = true,
    ["Silence"] = true,
    ["Shadowfury"] = true,
    ["Slow"] = true,
    ["Faerie Fire"] = true,
    ["Silencing Shot"] = true,
    ["Flame Shock"] = true,
    ["Faerie Fire (Feral)"] = true,
    ["Moonfire"] = true,
    ["Hunter's Mark"] = true,
    ["Frostfire Bolt"] = true,
    ["Corruption"] = true,
    ["Insect Swarm"] = true,
    ["Haunt"] = true
}

local dispelBlacklist = {
    ["Unstable Affliction"] = true
}

DispelMagic:Callback("defensive", function(spell)
    awful.fullGroup.loop(function(unit)
        for i, debuff in ipairs(unit.debuffs) do
            local name = unpack(debuff)

            if dispelBlacklist[name] then return end
            if dispelDefensive[name] then
                return spell:Cast(unit) and awful.alert(name, spell.id)
            end
        end
    end)
end)

local dispelOffensive = {
    ["Barkskin"] = true,
    ["Rejuvenation"] = true,
    ["Regrowth"] = true,
    ["Lifebloom"] = true,
    ["Wild Growth"] = true,
    ["Predator's Swiftness"] = true,
    ["Nature's Swiftness"] = true,
    ["Innervate"] = true,
    ["Icy Veins"] = true,
    ["Ice Barrier"] = true,
    ["Mana Shield"] = true,
    ["Combustion"] = true,
    ["Hand of Sacrifice"] = true,
    ["Hand of Freedom"] = true,
    ["Avenging Wrath"] = true,
    ["Beacon of Light"] = true,
    ["Sacred Shield"] = true,
    ["Divine Protection"] = true,
    ["Hand of Protection"] = true,
    ["Fear Ward"] = true,
    ["Power Word: Shield"] = true,
    ["Renew"] = true,
    ["Bloodlust"] = true,
    ["Elemental Mastery"] = true,
    ["Heroism"] = true,
    ["Riptide"] = true,
    ["Power Infusion"] = true,
    ["Focus Magic"] = true,
    ["Grace"] = true,
    ["Inspiration"] = true,
    ["Divine Aegis"] = true,
    ["Prayer of Shadow Protection"] = true,
    ["Shadow Protection"] = true,
    ["Prayer of Mending"] = true,
    ["Backdraft"] = true,
    ["Arcane Power"] = true,
    ["Presence of Mind"] = true,
    ["Divine Sacrifice"] = true,
    ["Divine Favor"] = true,
    ["Tidal Force"] = true,
    ["Natural Perfection"] = true,
    ["The Art of War"] = true
}

DispelMagic:Callback("offensive", function(spell)
    if not target or not target.exists then return end
    if not target.enemy then return end

    for i, buff in ipairs(target.buffs) do
        local name = unpack(buff)
        if dispelOffensive[name] and player.manaPct >= 20 then
            return spell:Cast(target) and awful.alert(name, spell.id)
        end
    end
end)

local dispelRegeneration = {
    ["Fear Ward"] = true,
    ["Divine Plea"] = true,
    ["Divine Illumination"] = true,
    ["Innervate"] = true
}

DispelMagic:Callback("healer", function(spell)
    if not awful.arena then return end

    awful.enemies.loop(function(unit)
        for i, buff in ipairs(unit.buffs) do
            local name = unpack(buff)
            if dispelRegeneration[name] then
                return spell:Cast(unit) and awful.alert(name, spell.id)
            end
        end
    end)
end)

FearWard:Callback(function(spell)
    awful.enemies.loop(function(unit)
        if unit.class == "Priest" and unit.distanceLiteral <= 20 and unit.cooldown(10890) == 0 then
            return spell:Cast(player)
        end

        if unit.class == "Warrior" and unit.distanceLiteral <= 20 and unit.cooldown(5246) == 0 then
            return spell:Cast(player)
        end

        if unit.class == "Warlock" and unit.distanceLiteral <= 20 and (unit.cooldown(17928) == 0 or unit.casting == "Fear" and unit.castTarget.isUnit(player)) then
            return spell:Cast(player)
        end
    end)
end)

InnerFire:Callback(function(spell)
    if player.buff("Inner Fire") then return end

    if player.hp >= 40 then
        return spell:Cast()
    end
end)

InventorySlot10:Update(function(item)
    if not target or not target.exists then return end
    if not player.combat then return end
    if target.distance > 35 then return end
    if not item.usable then return end
    if player.moving then return end
    if player.casting or player.channel then return end

    if target.enemy then
        if item:Use() then
            return awful.alert("Hyperspeed Acceleration", 54758)
        end
    end
end)
