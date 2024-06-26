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

function rotation.pve()
    if not (rotation.settings.mode == "PvE (Default APL)") then return end
    if player.mounted or player.buff("Drink") then return end

    -- Buffs
    shadow.shadowform()
    shadow.innerFire()
    shadow.vampiricEmbrace()

    auto_target()
    shadow.WasCastingCheck()

    if not target.combat and not player.combat then
        return
    end

    shadow.healthstone()

    -- Dungeon Logic
    shadow.shadowWordDeath("web wrap")
    shadow.mindFlay("web wrap")
    shadow.mindFlay("mirror image")

    -- AoE Rotation
    shadow.mindSear("aoe")
    shadow.vampiricTouch("aoe")
    shadow.shadowWordPain("aoe")
    shadow.mindSear("aoe_vt")

    -- Items
    shadow.globalSapperCharge()
    shadow.saroniteBomb()
    shadow.berserking()
    shadow.inventorySlot10()
    shadow.inventorySlot13()
    shadow.inventorySlot14()
    shadow.potionOfSpeed()

    -- Opener Rotation
    shadow.vampiricTouch("opener")
    shadow.devouringPlague("opener")
    shadow.mindBlast("opener")
    shadow.shadowfiend("opener")
    shadow.mindFlay("opener")
    shadow.shadowWordPain("opener")

    -- Main Rotation
    shadow.vampiricTouch()
    shadow.devouringPlague()
    shadow.shadowWordPain()
    shadow.shadowfiend()
    shadow.mindBlast()
    shadow.innerFocus()
    shadow.mindFlay()
    shadow.shadowWordDeath()
end
