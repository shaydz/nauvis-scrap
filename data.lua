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
