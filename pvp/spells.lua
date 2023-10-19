local Unlocker, awful, rotation = ...
local shadow = rotation.priest.shadow
local Spell = awful.Spell
local player, target, focus = awful.player, awful.target, awful.focus

if not awful.player.class2 == "PRIEST" then return end

awful.Populate({
    FearWard        = Spell(6346),
    DesperatePrayer = Spell(48173, { ignoreMoving = true, beneficial = true }),
    PowerWordShield = Spell(48066, { ignoreUsable = true, beneficial = true }),
    PrayerOfMending = Spell(48113, { beneficial = true }),
    BindingHeal     = Spell(48120, { beneficial = true }),
    FlashHeal       = Spell(48071, { beneficial = true }),
    Renew           = Spell(48068, { beneficial = true }),
    Shadowfiend     = Spell(34433, { beneficial = true }),
    MindBlast       = Spell(48127, { effect = "magic" }),
    VampiricTouch   = Spell(48160, { ignoreFacing = true, effect = "magic" }),
    MindFlay        = Spell(48156, { effect = "magic" }),
    DevouringPlague = Spell(48300, { ignoreFacing = true, effect = "magic" }),
    ShadowWordPain  = Spell(48125, { ignoreFacing = true, effect = "magic" }),
    HolyNova        = Spell(48078, { radius = 10, ignoreCasting = true, ignoreChanneling = true }),
    ShackleUndead   = Spell(10955, { ignoreFacing = true }),
    PsychicScream   = Spell(10890, { ignoreFacing = true, cc = "fear", effect = "magic" }),
    MassDispel      = Spell(32375, { ignoreFacing = true, radius = 15 }),
    DispelMagic     = Spell(988, { beneficial = true }),
    InnerFire       = Spell(48168, { beneficial = true }),
    AutoAttack      = Spell(6603, { ignoreChanneling = true, ignoreCasting = true }),
    ShadowWordDeath = Spell(48158, { ignoreFacing = true, ignoreCasting = true, ignoreChanneling = true }),
    AbolishDisease  = Spell(552, { ignoreFacing = true }),
    Fade            = Spell(586, { beneficial = true }),
    Shadowform      = Spell(15473),
    VampiricEmbrace = Spell(15286),
    Silence         = Spell(15487, { effect = "magic", ignoreFacing = true, ignoreCasting = true, ignoreChanneling = true }),
    PsychicHorror   = Spell(64044, { effect = "magic", cc = "stun", ignoreCasting = true, ignoreChanneling = true }),
    Dispersion      = Spell(47585),

    -- Items
    engineer_gloves = Spell(6603, { ignoreFacing = true }),
}, shadow, getfenv(1))

local function unitFilter(obj)
    return obj.los and obj.exists and not obj.dead
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

-- Draw
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

local SpellStopCasting = awful.unlock("SpellStopCasting")
local StartAttack = awful.unlock("StartAttack")

local preemptive = {
    -- Rogue
    ["Blind"] = true,
    ["Gouge"] = true,
    -- Paladin
    ["Repentance"] = true,
    -- Hunter
    ["Scatter Shot"] = true,
    ["Freezing Arrow"] = true,
    -- Mage
    ["Polymorph"] = true,
    -- Warlock
    ["Seduction"] = true
}

awful.onEvent(function(info, event, source, dest)
    if event == "SPELL_CAST_SUCCESS" then
        if not source.enemy then return end

        local _, spellName = select(12, unpack(info))
        if preemptive[spellName] then
            SpellStopCasting()
            ShadowWordDeath:Cast(source)
            return
        end
    end
end)

local swdCast = {
    -- Mage
    ["Polymorph"] = true,
    -- Warlock
    ["Seduction"] = true,
    ["Fear"] = true,
}

-- Shadow Word: Death
ShadowWordDeath:Callback("polymorph", function(spell)
    awful.enemies.loop(function(unit)
        if swdCast[unit.casting] and unit.castRemains < awful.buffer + awful.latency + 0.03 then
            SpellStopCasting()
            if spell:Cast(unit) then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end)
end)

ShadowWordDeath:Callback("seduction", function(spell)
    awful.enemyPets.loop(function(unit)
        if swdCast[unit.casting] and unit.castRemains < awful.buffer + awful.latency + 0.03 then
            SpellStopCasting()
            if spell:Cast(unit) then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end)
end)

ShadowWordDeath:Callback("burst", function(spell)
    if target.enemy then
        if spell:Cast(target) then
            awful.alert(spell.name .. " (Burst)", spell.id)
            return
        end
    end
end)

ShadowWordDeath:Callback("execute", function(spell)
    if target.enemy and target.hp < 20 then
        SpellStopCasting()
        if spell:Cast(target) then
            awful.alert(spell.name .. " (Burst)", spell.id)
            return
        end
    end
end)

local function checkForFearDebuff(obj)
    return obj.debuff(10890) and not obj.isPet
end

ShadowWordDeath:Callback("tremor", function(spell)
    awful.totems.stomp(function(totem, uptime)
        if uptime < 0.3 then
            return
        end

        if totem.id == 5913 and awful.enemies.around(player, 30, checkForFearDebuff) > 0 then
            SpellStopCasting()
            if spell:Cast(totem) then
                awful.alert("Destroying " .. totem.name, spell.id)
                return
            end
        end
    end)
end)

-- Auto Attack
AutoAttack:Callback("totems", function(spell)
    awful.totems.stomp(function(totem, uptime)
        if uptime < 0.3 then return end

        if totem.id == 5913 and totem.distanceLiteral < 5 then
            if not spell.current then
                if totem.setTarget() then
                    StartAttack()
                    if spell:Cast(totem) then
                        awful.alert("Destroying " .. totem.name, spell.id)
                        return
                    end
                end
            end
        end
    end)
end)

Shadowform:Callback(function(spell)
    if not player.buff("Shadowform") and awful.fullGroup.lowest.hp > 40 then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

VampiricEmbrace:Callback(function(spell)
    if not player.buff("Vampiric Embrace") then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

Dispersion:Callback(function(spell)
    if not player.combat then return end

    if player.hp < 40 then
        SpellStopCasting()
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

local interruptCast = {
    -- Mage
    ["Polymorph"] = true,
    -- Warlock
    ["Seduction"] = true,
    ["Fear"] = true,
    ["Chaos Bolt"] = true,
    -- Paladin
    ["Holy Light"] = true,
    ["Flash of Light"] = true,
    -- Priest
    ["Flash Heal"] = true,
    ["Binding Heal"] = true,
    ["Greater Heal"] = true,
    ["Penance"] = true,
    ["Prayer of Healing"] = true,
    ["Vampiric Touch"] = true,
    -- Shaman
    ["Healing Wave"] = true,
    ["Lesser Healing Wave"] = true,
    ["Chain Heal"] = true,
    -- Druid
    ["Regrowth"] = true,
    ["Rejuvenation"] = true,
    ["Healing Touch"] = true,
    ["Nourish"] = true,
    ["Cyclone"] = true
}

local interruptChannel = {
    -- Priest
    ["Penance"] = true,
    -- Druid
    ["Tranquility"] = true
}

Silence:Callback(function(spell)
    awful.enemies.within(40).filter(unitFilter).loop(function(enemy)
        if not enemy.casting and not enemy.channeling then return end
        if enemy.silenceDR < 0.25 then return end

        if interruptCast[enemy.cast] then
            if enemy.castRemains < awful.buffer + awful.latency + 0.03 then
                SpellStopCasting()
                if spell:Cast(enemy) then
                    awful.alert(spell.name, spell.id)
                    return
                end
            end
        elseif interruptChannel[enemy.channel] then
            if enemy.channelRemains < awful.buffer + awful.latency + 2 then
                SpellStopCasting()
                if spell:Cast(enemy) then
                    awful.alert(spell.name, spell.id)
                    return
                end
            end
        end
    end)
end)

PsychicHorror:Callback(function(spell)
    awful.enemies.within(40).filter(unitFilter).loop(function(enemy)
        if enemy.buff("Bladestorm") or enemy.buff("Shadow Dance") then
            SpellStopCasting()
            if spell:Cast(enemy) then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end)

    if focus.exists and target.hp < 60 and not focus.debuff("Silence") and not focus.bcc then
        SpellStopCasting()
        if spell:Cast(focus) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

Fade:Callback(function(spell)
    if player.slowed or player.rooted then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

-- Devouring Plague
DevouringPlague:Callback("sustain", function(spell)
    if target.bcc then return end

    if target.enemy and target.debuffRemains("Devouring Plague") < 5 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

-- Shadow Word Pain
ShadowWordPain:Callback("sustain", function(spell)
    if target.bcc then return end

    if target.enemy and target.debuffRemains("Shadow Word: Pain") < 2 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

-- Vampiric Touch
VampiricTouch:Callback("sustain", function(spell)
    if target.bcc then return end
    if player.casting then return end

    if target.enemy and target.debuffRemains("Vampiric Touch") < 2 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

MindFlay:Callback("sustain", function(spell)
    if not target.debuff("Vampiric Touch", player) then
        return
    end

    if target.bcc then return end

    if target.enemy then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

-- Desperate Prayer
DesperatePrayer:Callback(function(spell)
    if player.hp < 40 then
        if spell:Cast(player) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

-- Power Word: Shield
PowerWordShield:Callback(function(spell)
    local unit = awful.fullGroup.within(40).filter(unitFilter).lowest
    if awful.prep then return end
    if not unit then return end
    if not unit.debuff or unit.debuff("Weakened Soul") then return end
    if not unit.buff or unit.buff("Power Word: Shield") then return end

    if unit.hp < 95 then
        if spell:Cast(unit) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

-- Prayer of Mending
PrayerOfMending:Callback(function(spell)
    local unit = awful.fullGroup.within(40).filter(unitFilter).lowest
    if not unit then return end
    if not awful.arena then return end
    if unit.buff("Prayer of Mending") then return end

    if unit.hp < 40 then
        if spell:Cast(unit) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

-- Binding Heal
BindingHeal:Callback(function(spell)
    local unit = awful.friends.within(40).filter(unitFilter).lowest

    if not awful.arena then return end
    if player.moving then return end

    if unit.hp < 40 and player.hp < 40 then
        if spell:Cast(unit) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

-- Flash Heal
FlashHeal:Callback(function(spell)
    local unit = awful.fullGroup.within(40).filter(unitFilter).lowest

    if not awful.arena then return end
    if player.moving then return end

    if unit.hp < 40 then
        if spell:Cast(unit) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

-- Renew
Renew:Callback(function(spell)
    local unit = awful.fullGroup.within(40).filter(unitFilter).lowest

    if not awful.arena then return end
    if unit.buff("Renew") then return end

    if unit.hp > 20 and unit.hp < 40 then
        if spell:Cast(unit) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

-- Shadowfiend
Shadowfiend:Callback("burst", function(spell)
    if target.enemy then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

Shadowfiend:Callback(function(spell)
    if not target.enemy then return end

    if player.manaPct < 20 or target.hp < 40 then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

-- Mind Blast
MindBlast:Callback("sustain", function(spell)
    if not target.debuff("Vampiric Touch", player) then
        return
    end
    if target.bcc then
        return
    end

    if target.enemy then
        if spell:Cast(target) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

-- Holy Nova
HolyNova:Callback("snakes", function(spell)
    if player.debuff(25809) then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

HolyNova:Callback("stealth", function(spell)
    awful.enemies.within(40).filter(unitFilter).loop(function(unit)
        if unit.buff("Shadow dance") then return end

        if unit.stealth and unit.distance <= 10 then
            SpellStopCasting()
            if spell:Cast() then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end)
end)

-- Shackle Undead
ShackleUndead:Callback("gargoyle", function(spell)
    awful.enemyPets.within(30).filter(unitFilter).loop(function(unit)
        if unit.debuff("Shackle Undead") then return end

        if unit.id == 27829 then
            if spell:Cast(unit) then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end)
end)

ShackleUndead:Callback("lich", function(spell)
    awful.enemies.within(30).filter(unitFilter).loop(function(unit)
        if unit.debuff("Shackle Undead") then return end

        if unit.buff(49039) then
            if spell:Cast(unit) then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end)
end)

local fearImmunity = { 6346, 49039, 48707, 642, 31224 }

-- Psychic Scream
PsychicScream:Callback("mutiple", function(spell)
    if awful.enemies.around(player, 6.5, function(enemy)
            return enemy.los and enemy.ccRemains < 0.1 and not enemy.isPet and not enemy.buffFrom(fearImmunity) and
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

    if focus.distanceLiteral < 9 and focus.ccRemains < 0.1 and not tremor then
        if spell:Cast() then
            awful.alert(spell.name .. " (Focus)", spell.id)
            return
        end
    end
end)

PsychicScream:Callback("lowhp", function(spell)
    awful.enemies.within(40).filter(unitFilter).loop(function(unit)
        if unit.distanceLiteral < 9 and player.hp < 20 then
            if spell:Cast() then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end)
end)

-- Mass Dispel: Buffs
local dispelImmune = {
    ["Divine Shield"] = true,
    ["Ice Block"] = true
}

-- Mass Dispel
MassDispel:Callback("immune", function(spell)
    awful.enemies.within(40).filter(unitFilter).loop(function(unit)
        for i, buff in ipairs(unit.buffs) do
            local name = unpack(buff)
            if dispelImmune[name] and awful.fullGroup.lowest.hp > 40 then
                if spell:SmartAoE(unit) then
                    awful.alert(spell.name .. " (Immune)", spell.id)
                    return
                end
            end
        end
    end)
end)

MassDispel:Callback("combat", function(spell)
    awful.enemies.within(40).filter(unitFilter).loop(function(unit)
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

-- Abolish Disease
AbolishDisease:Callback(function(spell)
    awful.fullGroup.within(40).filter(unitFilter).loop(function(unit)
        if unit.hp < 40 then return end
        if unit.buff("Abolish Disease") then return end

        for i = 1, #unit.debuffs do
            local _, _, _, type = unpack(unit['debuff' .. i])
            if dispelDisease[type] then
                if spell:Cast(unit) then
                    awful.alert(spell.name, spell.id)
                    return
                end
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
    ["Deep Freeze"] = true,
    ["Pin"] = true,
    ["Hammer of Justice"] = true,
    ["Fear"] = true,
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
    ["Slow"] = true
}

local dispelBlacklist = {
    ["Unstable Affliction"] = true
}

DispelMagic:Callback("defensive", function(spell)
    awful.fullGroup.within(40).filter(unitFilter).loop(function(unit)
        for i, debuff in ipairs(unit.debuffs) do
            local name = unpack(debuff)

            if dispelBlacklist[name] then return end
            if dispelDefensive[name] then
                if spell:Cast(unit) then
                    awful.alert(spell.name .. " (Defensive)", spell.id)
                    return
                end
            end
        end
    end)
end)

local dispelOffensive = {
    -- Druid
    ["Barkskin"] = true,
    ["Rejuvenation"] = true,
    ["Regrowth"] = true,
    ["Lifebloom"] = true,
    ["Predator's Swiftness"] = true,
    ["Nature's Swiftness"] = true,
    ["Innervate"] = true,

    -- Mage
    ["Icy Veins"] = true,
    ["Ice Barrier"] = true,
    ["Mana Shield"] = true,
    ["Combustion"] = true,

    -- Paladin
    ["Hand of Sacrifice"] = true,
    ["Hand of Freedom"] = true,
    ["Avenging Wrath"] = true,
    ["Beacon of Light"] = true,
    ["Sacred Shield"] = true,
    ["Divine Protection"] = true,
    ["Hand of Protection"] = true,

    -- Priest
    ["Fear Ward"] = true,
    ["Power Word: Shield"] = true,
    ["Renew"] = true,

    -- Shaman
    ["Bloodlust"] = true,
    ["Elemental Mastery"] = true,
    ["Heroism"] = true,
    ["Riptide"] = true
}

DispelMagic:Callback("offensive", function(spell)
    for i, buff in ipairs(target.buffs) do
        if not target.enemy then return end

        local name = unpack(buff)
        if dispelOffensive[name] and player.manaPct > 20 and awful.fullGroup.lowest.hp > 40 then
            if spell:Cast(target) then
                awful.alert(spell.name .. " (Offensive)", spell.id)
                return
            end
        end
    end
end)

local dispelRegeneration = {
    -- Priest
    ["Fear Ward"] = true,

    -- Paladin
    ["Divine Plea"] = true,
    ["Divine Illumination"] = true,

    -- Druid
    ["Innervate"] = true
}

-- Dispel Magic
DispelMagic:Callback("healer", function(spell)
    awful.enemies.within(40).filter(unitFilter).loop(function(unit)
        for i, buff in ipairs(unit.buffs) do
            local name = unpack(buff)
            if dispelRegeneration[name] and awful.fullGroup.lowest.hp > 40 then
                if spell:Cast(unit) then
                    awful.alert(spell.name .. " (Offensive)", spell.id)
                    return
                end
            end
        end
    end)
end)

-- Fear Ward
FearWard:Callback(function(spell)
    awful.friends.within(40).filter(unitFilter).loop(function(unit)
        if unit.class == "Priest" and unit.distanceLiteral <= 20 and unit.cooldown(10890) == 0 then
            SpellStopCasting()
            if spell:Cast(player) then
                awful.alert(spell.name, spell.id)
                return
            end
        end

        if unit.class == "Warrior" and unit.distanceLiteral <= 20 and unit.cooldown(5246) == 0 then
            SpellStopCasting()
            if spell:Cast(player) then
                awful.alert(spell.name, spell.id)
                return
            end
        end

        if unit.class == "Warlock" and unit.distanceLiteral <= 20 and (unit.cooldown(17928) == 0 or unit.casting == "Fear" and unit.castTarget.isUnit(player)) then
            SpellStopCasting()
            if spell:Cast(player) then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end)
end)

-- Inner Fire
InnerFire:Callback(function(spell)
    if player.buff("Inner Fire") then return end

    if player.hp > 40 then
        if spell:Cast(player) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

local function useInventoryItem()
    RunMacroText("/use 10");
end

engineer_gloves:Callback("execute", function(spell)
    local start = GetInventoryItemCooldown("player", 10)
    if target.enemy and target.hp < 20 and start == 0 then
        if useInventoryItem() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

engineer_gloves:Callback("burst", function(spell)
    local start = GetInventoryItemCooldown("player", 10)
    if target.enemy and start == 0 then
        if useInventoryItem() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)
