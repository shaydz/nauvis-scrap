-- ============================================================================
-- SCRAP GENERATION: Create a Nauvis-specific clone of scrap.
-- We do NOT modify the original "scrap" resource, preserving Fulgora generation.
-- Instead, we create "nauvis-scrap" which uses standard ore placement but
-- mines into the same "scrap" item.
-- ============================================================================

-- Step 1: Create a "nauvis-scrap" autoplace-control for the map gen UI.
data:extend({
    {
        type = "autoplace-control",
        name = "nauvis-scrap",
        localised_name = {"entity-name.scrap"},
        richness = true,
        order = "b-z",
        category = "resource"
    }
})

-- Step 2: Clone the scrap resource for Nauvis with standard ore generation.
local original_scrap = data.raw.resource["scrap"]
if original_scrap then
    local nauvis_scrap = table.deepcopy(original_scrap)
    nauvis_scrap.name = "nauvis-scrap"
    nauvis_scrap.localised_name = {"entity-name.scrap"}

    -- Use standard ore-patch generation that works on Nauvis terrain.
    -- Density matches uranium ore for rarity.
    local resource_autoplace = require("resource-autoplace")
    nauvis_scrap.autoplace = resource_autoplace.resource_autoplace_settings({
        name = "nauvis-scrap",
        order = "c",
        base_density = 0.9,
        has_starting_area_placement = false,
        regular_rq_factor_multiplier = 1
    })

    data:extend({nauvis_scrap})
end

-- Step 3: Register nauvis-scrap on Nauvis's map generation (NOT the original scrap).
local nauvis = data.raw.planet["nauvis"]
if nauvis and nauvis.map_gen_settings then
    local mgs = nauvis.map_gen_settings

    -- Ensure necessary tables exist
    mgs.autoplace_controls = mgs.autoplace_controls or {}
    mgs.autoplace_settings = mgs.autoplace_settings or {}
    mgs.autoplace_settings.entity = mgs.autoplace_settings.entity or { settings = {} }
    mgs.autoplace_settings.entity.settings = mgs.autoplace_settings.entity.settings or {}

    -- Remove original scrap from Nauvis if another mod added it
    mgs.autoplace_controls["scrap"] = nil
    mgs.autoplace_settings.entity.settings["scrap"] = nil

    -- Register our Nauvis-specific scrap clone
    mgs.autoplace_controls["nauvis-scrap"] = {}
    mgs.autoplace_settings.entity.settings["nauvis-scrap"] = {}
end

-- ============================================================================
-- RECYCLING TECHNOLOGY: Make it a standard researchable tech with red + green.
-- In vanilla Space Age this is a trigger tech (unlocked by mining a Fulgoran ruin).
-- We remove the trigger so it works without visiting Fulgora.
-- ============================================================================

-- Step 4: Convert recycling from trigger tech to standard research.
local recycling_tech = data.raw.technology["recycling"]
if recycling_tech then
    -- Remove the Fulgoran ruin trigger (vanilla Space Age uses this instead of unit)
    recycling_tech.research_trigger = nil
    -- Set standard research with red + green science
    recycling_tech.unit = {
        count = 50,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 30
    }
    -- Require green science tech as prerequisite
    recycling_tech.prerequisites = {"logistic-science-pack"}
end

-- Step 5: Remove surface_conditions from the recycler so it can be placed on Nauvis.
local recycler = data.raw.furnace["recycler"]
if recycler then
    recycler.surface_conditions = nil
end

-- Step 6: Remove surface_conditions from scrap-recycling recipe if present.
local scrap_recycling = data.raw.recipe["scrap-recycling"]
if scrap_recycling then
    scrap_recycling.surface_conditions = nil
end
