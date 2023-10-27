local Unlocker, awful, rotation = ...

if not awful.player.class2 == "PRIEST" then
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
    spellId = 14325,
    var = "use_auto_target",
    text = "Auto Target",
    size = 30
})

statusFrame:Button({
    spellId = 34433,
    var = "use_cds",
    text = "CDs",
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
        { label = awful.textureEscape(15336, 16) .. " PvE (Default APL)", value = "PvE (Default APL)", tooltip = "Use PvE Rotation with Default APL" },
        { label = awful.textureEscape(33193, 16) .. " PvE (WoWSims APL)", value = "PvE (WoWSims APL)", tooltip = "Use PvE Rotation with WoWSims APL" },
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

Spells:Slider({
    text = awful.textureEscape(48300) .. " TTD Timer",
    var = "ttd_timer",
    min = 0,
    max = 60,
    step = 1,
    default = 10,
    valueType = " secs",
    tooltip = "Time To Die for Dots in seconds. Example: If the unit lives longer than 8 Seconds, then it should cast Dots. (Vampiric Touch, Devouring Plague, Shadow Word: Pain)"
})

local Items = gui:Tab(awful.textureEscape(10890, 16) .. " Item Settings")
Items:Text({
    text = "|cff00B5FFItem Settings",
    header = true,
    paddingBottom = 10,
})

Items:Slider({
    text = "Healthstone",
    var = "useHealthstone",
    min = 0,
    max = 100,
    step = 1,
    default = 20,
    valueType = "%",
    tooltip = "Use Healthstone at certain HP threshhold"
})

Items:Checkbox({
    text = "Use Saronite Bomb",
    var = "useSaroniteBomb",
    tooltip = "Use Saronite Bomb while fighting against a Raid Boss",
    default = true
})

Items:Checkbox({
    text = "Use Global Thermal Sapper Charge",
    var = "useGlobalSapperCharge",
    tooltip = "Use Global Thermal Sapper Charge while fighting against a Raid Boss",
    default = true
})

Items:Checkbox({
    text = "Use Potion of Speed",
    var = "usePotionSpeed",
    tooltip = "Use Potion of Speed while fighting against a Raid Boss, you still need too pre pot",
    default = true
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
    text = "Show TTD Timer",
    var = "use_draw_ttd",
    tooltip = "Shows the Time To Die Timer on mobs",
    default = false
})

Toggles:Checkbox({
    text = "Use Mind Blast",
    var = "use_mind_blast",
    tooltip = "Use Mind Blast in the Rotation",
    default = true
})

Toggles:Checkbox({
    text = "Use Auto Target",
    var = "use_auto_target",
    tooltip = "Use Auto Target. It will Auto Target the lowest unit in 40 yards",
    default = true
})

Toggles:Text({
    text = "|cff00B5FFToggles (PvP)",
    header = true,
    paddingBottom = 10,
})

Toggles:Checkbox({
    text = "Use Silence",
    var = "useSilence",
    tooltip = "Use Silence for Heal & Crowd Control Spells",
    default = true
})

Toggles:Checkbox({
    text = "Use Psychic Horror",
    var = "usePsychicHorror",
    tooltip = "Use Psychic Horror on Focus if current Target is under 60% HP or a Rogue has Shadow Dance or Warrior Bladestorm up",
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
