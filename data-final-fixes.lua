-- ============================================================================
-- Note: Step 1 (create autoplace-control) and Step 2 (clone scrap resource)
-- are moved to data.lua. This allows other mods (like Mining Drones Remastered)
-- that scan data.raw.resource during data-final-fixes to see and support
-- the nauvis-scrap resource.
-- ============================================================================


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

-- Step 5: Remove surface_conditions from the recycler crafting recipe so the
-- recycler item can be crafted in an assembler on Nauvis. The recycler entity
-- itself is already placeable and functional on Nauvis without modification.
local recycler_recipe = data.raw.recipe["recycler"]
if recycler_recipe then
    recycler_recipe.surface_conditions = nil
end
