local Unlocker, awful, rotation = ...
local pve = rotation.priest.shadow
local player, target = awful.player, awful.target
awful.ttd_enabled = true

if not awful.player.class2 == "PRIEST" then
    return
end
if not (rotation.settings.mode == "PvE") then
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

function rotation.pve()
    if player.mounted or player.buff("Drink") then
        return
    end

    -- Buffs
    pve.shadowform()
    pve.innerFire()
    pve.vampiricEmbrace()

    auto_target()

    if not target.combat and not player.combat then
        return
    end

    -- Dungeon Logic
    pve.shadowWordDeath("web wrap")
    pve.mindFlay("web wrap")
    pve.mindFlay("mirror image")

    -- AoE Rotation
    pve.mindSear("aoe")
    pve.vampiricTouch("aoe")
    pve.shadowWordPain("aoe")
    pve.mindSear("aoe_vt")

    -- Items
    pve.saroniteBomb()
    pve.berserking()
    pve.inventorySlot10()
    pve.inventorySlot13()
    pve.inventorySlot14()
    pve.potionOfSpeed()

    -- Opener Rotation
    pve.vampiricTouch("opener")
    pve.devouringPlague("opener")
    pve.mindBlast("opener")
    pve.shadowfiend("opener")
    pve.mindFlay("opener")
    pve.shadowWordPain("opener")

    -- Main Rotation
    pve.shadowWordDeath()
    pve.vampiricTouch()
    pve.devouringPlague()
    pve.shadowfiend()
    pve.mindBlast()
    pve.innerFocus()
    pve.mindFlay()
    pve.shadowWordPain()
end
