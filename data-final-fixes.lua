-- Step 1: Ensure the "scrap" autoplace-control prototype exists.
-- Another mod (e.g. Everything on Nauvis) may have removed it, or Space Age
-- may scope it only to Fulgora. We (re)create it unconditionally.
if not data.raw["autoplace-control"]["scrap"] then
    data:extend({
        {
            type = "autoplace-control",
            name = "scrap",
            localised_name = {"entity-name.scrap"},
            richness = true,
            order = "b-z",
            category = "resource"
        }
    })
end

-- Step 2: Ensure the scrap resource uses standard ore-patch generation
-- instead of Fulgora's unique noise expressions (which reference terrain
-- features that don't exist on Nauvis).
local scrap = data.raw.resource["scrap"]
if scrap then
    local resource_autoplace = require("resource-autoplace")
    scrap.autoplace = resource_autoplace.resource_autoplace_settings({
        name = "scrap",
        order = "c",
        base_density = 0.9,
        base_spots_per_km2 = 1.25,
        has_starting_area_placement = false,
        random_spot_size_minimum = 2,
        random_spot_size_maximum = 6,
        regular_rq_factor_multiplier = 1
    })
end

-- Step 3: Register scrap in Nauvis's map generation settings.
local nauvis = data.raw.planet["nauvis"]
if nauvis and nauvis.map_gen_settings then
    local mgs = nauvis.map_gen_settings

    -- Ensure necessary tables exist
    mgs.autoplace_controls = mgs.autoplace_controls or {}
    mgs.autoplace_settings = mgs.autoplace_settings or {}
    mgs.autoplace_settings.entity = mgs.autoplace_settings.entity or { settings = {} }
    mgs.autoplace_settings.entity.settings = mgs.autoplace_settings.entity.settings or {}

    -- Register scrap for Nauvis map generation
    mgs.autoplace_controls["scrap"] = {}
    mgs.autoplace_settings.entity.settings["scrap"] = {}
end

-- Step 4: Make recycling a standard researchable technology with red + green science.
-- In vanilla Space Age this is a trigger tech (unlocked by mining a Fulgoran ruin).
-- We remove the trigger and replace it with a normal research unit so it works on Nauvis.
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

-- Step 5: Remove surface_conditions from the recycler crafting recipe so the
-- recycler item can be crafted in an assembler on Nauvis. The recycler entity
-- itself is already placeable and functional on Nauvis without modification.
local recycler_recipe = data.raw.recipe["recycler"]
if recycler_recipe then
    recycler_recipe.surface_conditions = nil
end

