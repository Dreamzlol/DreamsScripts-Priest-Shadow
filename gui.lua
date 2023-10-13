local Unlocker, awful, rotation = ...
local class = awful.player.class2

if class ~= "PRIEST" then
    return
end

local blue = { 0, 181, 255, 1 }
local white = { 255, 255, 255, 1 }
local background = { 0, 13, 49, 1 }

local gui, settings, cmd = awful.UI:New('ds', {
    title = "Dreams{ |cff00B5FFScripts |cffFFFFFF }",
    show = true,
    width = 345,
    height = 220,
    scale = 1,
    colors = {
        title = white,
        primary = white,
        accent = blue,
        background = background,
    }
})

rotation.settings = settings

local statusFrame = gui:StatusFrame({
    colors = {
        background = { 0, 0, 0, 0 },
        enabled = { 30, 240, 255, 1 },
    },
    maxWidth = 600,
    padding = 12,
})

statusFrame:Button({
    spellId = 48160,
    var = "useAoe",
    text = "AoE",
    size = 30
})

statusFrame:Button({
    spellId = 34433,
    var = "use_cds",
    text = "CDs",
    size = 30
})

statusFrame:Button({
    spellId = 14325,
    var = "use_auto_target",
    text = "Auto Target",
    size = 30
})

-- Welcome
local Welcome = gui:Tab(awful.textureEscape(15473, 16) .. " Welcome")
Welcome:Text({
    text = "|cff00B5FFInformation",
    header = true,
    paddingBottom = 10,
})

Welcome:Text({
    text = "Set up Macros for your spells you want too use manually like Dispersion etc.",
    paddingBottom = 10,
})

Welcome:Text({
    text = "(See Macros tab for example)",
    paddingBottom = 10,
})

Welcome:Text({
    text = "|cff00B5FFDiscord",
    header = true,
    paddingBottom = 10,
})

Welcome:Text({
    text = "If you have any suggestions or questions, feel free to join the Discord and let me know!",
    paddingBottom = 10,
})

Welcome:Text({
    text = "|cffFF0099discord.gg/axWkr4sFMJ",
})

local Mode = gui:Tab(awful.textureEscape(48160, 16) .. " Rotation Mode")
Mode:Text({
    text = "|cff00B5FFRotation Mode",
    header = true,
    paddingBottom = 10,
})

Mode:Dropdown({
    var = "mode",
    tooltip = "Select the Rotation Mode.",
    options = {
        { label = awful.textureEscape(15336, 16) .. " PvE", value = "PvE", tooltip = "Use PvE Rotation" },
        { label = awful.textureEscape(15487, 16) .. " PvP", value = "PvP", tooltip = "Use PvP Rotation" },
    },
    placeholder = "None",
    header = "Select Rotation Mode",
})

local Spells = gui:Tab(awful.textureEscape(2767, 16) .. " Spell Settings")
Spells:Text({
    text = "|cff00B5FFSpell Settings (PvE)",
    header = true,
    paddingBottom = 10,
})

Spells:Dropdown({
    var = "aoeRotation",
    multi = true,
    tooltip = "Choose the Spells for AoE Rotation being used",
    options = {
        { label = awful.textureEscape(48160, 16) .. " Vampiric Touch",  value = "Vampiric Touch" },
        { label = awful.textureEscape(2767, 16) .. " Shadow Word Pain", value = "Shadow Word: Pain" },
        { label = awful.textureEscape(53023, 16) .. " Mind Sear",       value = "Mind Sear" },
    },
    placeholder = "Choose spells",
    header = "Spells for AoE Rotation",
    default = { "Vampiric Touch", "Shadow Word: Pain", "Mind Sear" }
})

Spells:Dropdown({
    var = "mind_sear",
    tooltip = "Use Mind Sear if more than selected enemies are around target. Default: 4",
    options = {
        { label = "> 1 enemies", value = 1, tooltip = "Use Mind Sear if 1 enemies are around target" },
        { label = "> 2 enemies", value = 2, tooltip = "Use Mind Sear if 2 enemies are around target" },
        { label = "> 3 enemies", value = 3, tooltip = "Use Mind Sear if 3 enemies are around target" },
        { label = "> 4 enemies", value = 4, tooltip = "Use Mind Sear if 4 enemies are around target" },
        { label = "> 5 enemies", value = 5, tooltip = "Use Mind Sear if 5 enemies are around target" },
        { label = "> 6 enemies", value = 6, tooltip = "Use Mind Sear if 6 enemies are around target" },
        { label = "> 7 enemies", value = 7, tooltip = "Use Mind Sear if 7 enemies are around target" },
        { label = "> 8 enemies", value = 8, tooltip = "Use Mind Sear if 8 enemies are around target" },
    },
    header = awful.textureEscape(53023) .. " Mind Sear",
    default = 4
})

Spells:Slider({
    text = awful.textureEscape(48300) .. " TTD Timer",
    var = "ttd_timer",
    min = 0,
    max = 60,
    step = 1,
    default = 20,
    valueType = " secs",
    tooltip = "Time To Die for Dots in seconds. Example: If the unit lives longer than 20 Seconds, then it should cast Dots. (Vampiric Touch, Devouring Plague, Shadow Word: Pain)"
})

local Toggles = gui:Tab(awful.textureEscape(8105, 16) .. " Toggles")
Toggles:Text({
    text = "|cff00B5FFToggles (PvE)",
    header = true,
    paddingBottom = 10,
})

Toggles:Checkbox({
    text = "Use AoE (Multidot)",
    var = "useAoe",
    tooltip = "AoE / Multidot enemies near you",
    default = true
})

Toggles:Checkbox({
    text = "Use Saronite Bomb",
    var = "useSaroniteBomb",
    tooltip = "Use Saronite Bomb",
    default = true
})

Toggles:Checkbox({
    text = "Use Mind Blast",
    var = "use_mind_blast",
    tooltip = "Use Mind Blast",
    default = true
})

Toggles:Checkbox({
    text = "Use Auto Target",
    var = "use_auto_target",
    tooltip = "Use Auto Target. It will Auto Target the lowest unit in 40 yards",
    default = true
})

local Macros = gui:Tab(awful.textureEscape(47585, 16) .. " Macros")
Macros:Text({
    text = "|cff00B5FFMacros",
    header = true,
    paddingBottom = 10,
})

Macros:Text({
    text = awful.textureEscape(47585) .. "  Dispersion",
    header = true,
    paddingBottom = 10,
})

Macros:Text({ text = "#showtooltip Dispersion" })
Macros:Text({ text = "/awful cast Dispersion" })
