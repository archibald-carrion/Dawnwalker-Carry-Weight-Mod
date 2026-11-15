-- InfiniteCarryWeight for The Blood of Dawnwalker (UE4SS Lua mod) - v2
-- Raises the player's weight limit so you never become encumbered.
--
-- v2: no global object sweep (v1 crashed doing that). Only a handful of
-- known classes are looked up by name, and only once you are in-game.
-- Everything is logged to ue4ss/UE4SS.log with prefix [InfiniteCarry].

local BIG_FLOAT = 999999.0
local BIG_INT   = 999999

-- Class names taken from the game's executable.
local MODULES = { "DogwoodInventory", "DogwoodStats", "DogwoodCharacterDevelopment", "DogwoodSystem" }
local CLASSES = {
    "InventoryComponent",
    "InventorySubsystem",
    "DogwoodInventorySettings",
    "InventoryBlueprintFunctionLibrary",
    "DogwoodStatsSettings",
    "DogwoodStatsBlueprintFunctionLibrary",
}
local LIMIT_PROPS = { WeightLimit = true, MaxWeight = true }

local function log(msg) print("[InfiniteCarry] " .. msg .. "\n") end

local targets = {}   -- { path=, short=, prop=, kind= }
local scanned = false
local reported = {}

local function findClass(short)
    for _, m in ipairs(MODULES) do
        local path = "/Script/" .. m .. "." .. short
        local c = StaticFindObject(path)
        if c and c:IsValid() then return c, path, m end
    end
    return nil
end

local function hook(path, fname)
    local ok, err = pcall(function()
        if fname == "GetWeightLimit" then
            RegisterHook(path, function() end, function() return BIG_FLOAT end)
        else -- CanExceedWeightLimit
            RegisterHook(path, function() end, function() return true end)
        end
    end)
    log((ok and "Hooked " or "Hook failed ") .. path .. (ok and "" or (": " .. tostring(err))))
end

local function scan()
    for _, short in ipairs(CLASSES) do
        log("Looking up class " .. short)
        local cls, path, module = findClass(short)
        if not cls then
            log("  not found")
        else
            log("  found " .. path)
            local ok, err = pcall(function()
                cls:ForEachProperty(function(prop)
                    local pname = prop:GetFName():ToString()
                    local l = pname:lower()
                    if l:find("weight") or l:find("encumb") or l:find("carry") then
                        local kind = prop:GetClass():GetFName():ToString()
                        log(("  property %s (%s)"):format(pname, kind))
                        if LIMIT_PROPS[pname] and (kind == "FloatProperty" or kind == "DoubleProperty" or kind == "IntProperty") then
                            table.insert(targets, { path = path, module = module, short = short, prop = pname, kind = kind })
                        end
                    end
                end)
            end)
            if not ok then log("  property scan error: " .. tostring(err)) end

            ok, err = pcall(function()
                cls:ForEachFunction(function(fn)
                    local fname = fn:GetFName():ToString()
                    local l = fname:lower()
                    if l:find("weight") or l:find("encumb") then
                        log(("  function %s"):format(fname))
                        if fname == "GetWeightLimit" or fname == "CanExceedWeightLimit" then
                            hook(path .. ":" .. fname, fname)
                        end
                    end
                end)
            end)
            if not ok then log("  function scan error: " .. tostring(err)) end
        end
    end
    log(("Scan complete: %d limit properties targeted"):format(#targets))
end

local function setOn(obj, t)
    if not (obj and obj:IsValid()) then return end
    local ok, cur = pcall(function() return obj[t.prop] end)
    if not ok or type(cur) ~= "number" then return end
    local want = (t.kind == "IntProperty") and BIG_INT or BIG_FLOAT
    -- Only touch inventories that actually have a limit (the player: 200).
    -- Chests/NPCs/loot bags use 0 = unlimited, leave them alone.
    if cur > 0 and cur < want then
        obj[t.prop] = want
        local key = obj:GetFullName() .. "." .. t.prop
        if not reported[key] then
            reported[key] = true
            log(("Set %s on %s: %s -> %s"):format(t.prop, obj:GetFullName(), tostring(cur), tostring(want)))
        end
    end
end

local function apply()
    for _, t in ipairs(targets) do
        -- live instances
        local list = FindAllOf(t.short)
        if list then for _, inst in ipairs(list) do setOn(inst, t) end end
    end
end

-- Wait until a save is loaded (an InventoryComponent exists), then scan once
-- and keep re-applying every 3s (the game may recalculate the limit).
LoopAsync(3000, function()
    ExecuteInGameThread(function()
        if not scanned then
            if FindFirstOf("InventoryComponent") then
                log("In-game detected, scanning")
                scanned = true
                scan()
            end
        else
            apply()
        end
    end)
    return false
end)

log("Loaded v2")
