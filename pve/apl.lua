local Unlocker, awful, rotation = ...
local shadow = rotation.priest.shadow
local player, target = awful.player, awful.target

local function engineering_gloves()
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

function rotation.APL_PvE()
    if player.mounted or player.buff("Drink") then
        return
    end

    -- Buffs
    shadow.shadowform()
    shadow.inner_fire()
    shadow.vampiric_embrace()

    if not player.combat then
        return
    end

    -- Items
    engineering_gloves()

    -- AoE Rotation
    shadow.vampiric_touch("aoe")
    shadow.shadow_word_pain("aoe")
    shadow.mind_sear("aoe")

    -- Opener Rotation
    shadow.vampiric_touch("opener")
    shadow.devouring_plague("opener")
    shadow.mind_blast("opener")
    shadow.shadowfiend("opener")
    shadow.mind_flay("opener")
    shadow.shadow_word_pain("opener")

    -- Main Rotation
    shadow.shadow_word_death()
    shadow.vampiric_touch()
    shadow.devouring_plague()
    shadow.shadowfiend()
    shadow.mind_blast()
    shadow.mind_flay()
    shadow.shadow_word_pain()
end

return rotation.APL_PvE