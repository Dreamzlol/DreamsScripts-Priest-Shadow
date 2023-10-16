local Unlocker, awful, rotation = ...
local shadow = rotation.priest.shadow
local player, target = awful.player, awful.target
awful.ttd_enabled = true

local function auto_target()
    if not rotation.settings.use_auto_target then
        return
    end
    local enemy = awful.enemies.within(40).lowest
    if not enemy or not enemy.exists then
        return
    end
    if enemy.combat and not enemy.dead then
        enemy.setTarget()
    end
end

function rotation.apl_pve()
    if player.mounted or player.buff("Drink") then
        return
    end

    -- Buffs
    shadow.pve_shadowform()
    shadow.pve_inner_fire()
    shadow.pve_vampiric_embrace()

    auto_target()

    if not target.combat or not player.combat then
        return
    end

    shadow.pve_shadow_word_death("web wrap") -- Dungeon Logic
    shadow.pve_mind_flay("web wrap") -- Dungeon Logic
    shadow.pve_mind_flay("mirror image") -- Dungeon Logic

    -- Items
    shadow.pve_saronite_bomb()

    -- AoE Rotation
    shadow.pve_vampiric_touch("aoe")
    shadow.pve_shadow_word_pain("aoe")
    shadow.pve_mind_sear("aoe")

    -- Opener Rotation
    shadow.pve_vampiric_touch("opener")
    shadow.pve_devouring_plague("opener")
    shadow.pve_mind_blast("opener")
    shadow.pve_shadowfiend("opener")
    shadow.pve_mind_flay("opener")

    shadow.pve_berserking()
    shadow.pve_inventory_slot_10()
    shadow.pve_inventory_slot_13()
    shadow.pve_inventory_slot_14()

    shadow.pve_shadow_word_pain("opener")

    -- Main Rotation
    shadow.pve_shadow_word_death()
    shadow.pve_vampiric_touch()
    shadow.pve_devouring_plague()
    shadow.pve_shadowfiend()
    shadow.pve_mind_blast()
    shadow.pve_inner_focus()
    shadow.pve_mind_flay()
    shadow.pve_shadow_word_pain()
end
