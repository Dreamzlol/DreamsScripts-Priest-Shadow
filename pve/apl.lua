local Unlocker, awful, rotation = ...
local shadow = rotation.priest.shadow
local player, target = awful.player, awful.target
awful.ttd_enabled = true

local function engineering_gloves()
    if player.channel == "Mind Flay" then
        return
    end

    local UseInventoryItem = awful.unlock("UseInventoryItem")
    local start = GetInventoryItemCooldown("player", 10)

    if target and target.exists then
        if target.level == -1 and start == 0 then
            if UseInventoryItem(10) then
                awful.alert("Hyperspeed Accelerators", 54758)
                return
            end
        end
    end
end

local item_saronite_bomb = awful.Item(41119)
local function saronite_bomb()
    if not rotation.settings.useSaroniteBomb then
        return
    end

    if target and target.exists then
        if item_saronite_bomb:Usable() and target.level == -1 then
            if item_saronite_bomb:UseAoE(target) then
                awful.alert(item_saronite_bomb.name, item_saronite_bomb.id)
            end
        end
    end
end

local function trinket()
    local use_inventory_item = awful.unlock("UseInventoryItem")
    local get_item_cooldown13 = GetInventoryItemCooldown("player", 13)
    local get_item_cooldown14 = GetInventoryItemCooldown("player", 14)

    if target and target.exists then
        if target.level == -1 then
            if get_item_cooldown13 == 0 then
                use_inventory_item(13)
                return
            elseif get_item_cooldown14 == 0 then
                use_inventory_item(14)
                return
            end
        end
    end
end

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

    if not target.combat and not player.combat then
        return
    end

    auto_target()

    -- Items
    engineering_gloves()
    shadow.pve_berserking()
    trinket()

    -- AoE Rotation
    shadow.pve_vampiric_touch("aoe")
    shadow.pve_shadow_word_pain("aoe")
    shadow.pve_mind_sear("aoe")

    -- Opener Rotation
    shadow.pve_vampiric_touch("opener")
    shadow.pve_devouring_plague("opener")
    saronite_bomb()
    shadow.pve_mind_blast("opener")
    shadow.pve_shadowfiend("opener")
    shadow.pve_mind_flay("opener")
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
