local Unlocker, awful, rotation = ...
local shadow = rotation.priest.shadow
local player, target = awful.player, awful.target
awful.ttd_enabled = true

if not awful.player.class2 == "PRIEST" then
    return
end

local function auto_target()
    if not rotation.settings.use_auto_target then return end
    local enemy = awful.enemies.within(40).lowest
    if not enemy or not enemy.exists then
        return
    end
    if enemy.combat and not enemy.dead then
        enemy.setTarget()
    end
end

function rotation.wowSims()
    if not (rotation.settings.mode == "PvE (WoWSims APL)") then return end
    if player.mounted or player.buff("Drink") then return end

    -- Buffs
    shadow.wowSims_shadowform()
    shadow.wowSims_innerFire()
    shadow.wowSims_vampiricEmbrace()

    auto_target()
    shadow.WasCastingCheck()

    if not target.combat and not player.combat then
        return
    end

    shadow.wowSims_healthstone()
    
    -- Dungeon Logic
    shadow.wowSims_shadowWordDeath("web wrap")
    shadow.wowSims_mindFlay("web wrap")
    shadow.wowSims_mindFlay("mirror image")

    -- AoE Rotation
    shadow.wowSims_mindSear("aoe")
    shadow.wowSims_vampiricTouch("aoe")
    shadow.wowSims_shadowWordPain("aoe")
    shadow.wowSims_mindSear("aoe_vt")

    -- Items
    shadow.wowSims_saroniteBomb()
    shadow.wowSims_berserking()
    shadow.wowSims_inventorySlot10()
    shadow.wowSims_inventorySlot13()
    shadow.wowSims_inventorySlot14()
    shadow.wowSims_potionOfSpeed()

    -- Main Rotation
    shadow.wowSims_vampiricTouch("opener")
    shadow.wowSims_shadowfiend()

    shadow.wowSims_devouringPlague("refresh")
    shadow.wowSims_shadowWordPain()
    shadow.wowSims_vampiricTouch("refresh")
    shadow.wowSims_devouringPlague()
    shadow.wowSims_mindBlast()
    shadow.wowSims_innerFocus()
    shadow.wowSims_shadowWordDeath()
    shadow.wowSims_mindFlay()
end
