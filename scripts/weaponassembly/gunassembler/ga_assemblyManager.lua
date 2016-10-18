require "/scripts/util.lua"
require "/scripts/weaponassembly/util/util.lua"

function combineParts()
  local parts = getInputParts()

  if parts and world.containerItemAt(entity.id(), 3) == nil then
    return assemble(parts)
  end
end

-- TODO: Change this to ignore weapon name
function getInputParts()
  -- We have all the parts
  local parts = {}
  parts["butt"] = world.containerItemAt(entity.id(), 0)
  parts["middle"] = world.containerItemAt(entity.id(), 1)
  parts["barrel"] = world.containerItemAt(entity.id(), 2)
  if not parts["butt"] or (parts["butt"].name ~= "WA_butt" and parts["butt"].name ~= "WA_technique") then return false end
  if not parts["middle"] or (parts["middle"].name ~= "WA_middle" and parts["middle"].name ~= "WA_handle") then return false end
  if not parts["barrel"] or (parts["barrel"].name ~= "WA_barrel" and parts["barrel"].name ~= "WA_blade") then return false end

  -- All the parts are of the same type
  local partTypes = {}
  partTypes["butt"] = parts["butt"].parameters.weaponType
  partTypes["middle"] = parts["middle"].parameters.weaponType
  partTypes["barrel"] = parts["barrel"].parameters.weaponType
  if partTypes["butt"] ~= partTypes["middle"] or partTypes["middle"] ~= partTypes["barrel"] then return false end

  return parts
end

function assemble(parts)
  local rarity = findRarity(parts)

  local weaponType = parts["middle"].parameters.weaponType
  weaponType = string.gsub(weaponType, "<Rarity>", rarity, 1)
  weaponType = string.gsub(weaponType, "<rarity>", rarity:lower(), 1)

  local newGun = {
    name = weaponType,
    count = 1,
    parameters = {
      itemName = weaponType,
      rarity = rarity
    }
  }

  local weaponDataArr = {}
  for partName,part in pairs(parts) do
    weaponDataArr[partName] = part.parameters.averageableData
    local propertiesToStore = root.itemConfig(parts[partName]).config.propertiesToStore
    util.mergeTable(newGun, cloneProperties(propertiesToStore, parts[partName].parameters.weaponData))
  end

  local propertiesToAverage = root.itemConfig(parts["middle"]).config.propertiesToAverage
  local averagedProperties = averageProperties(propertiesToAverage, weaponDataArr)
  util.mergeTable(newGun, averagedProperties)

  return newGun
end

-------------------------------------------------------
-- Urility functions
-------------------------------------------------------
function findRarity(parts)
  local rarities = {"common", "uncommon", "rare", "legendary"}
  local rarityValues = {common = 1, uncommon = 2, rare = 3, legendary = 4}
  local sum = 0
  for _,part in pairs(parts) do
    local rarity = part.parameters.rarity:lower()
    if rarity then sum = sum + rarityValues[rarity] end
  end
  local avg = math.floor(sum / 3 + 0.5)
  return rarities[avg]
end

function buildWeaponType(weaponConfig)
  -- Capitalized and Lowecase rarity replacement
  local weaponType = string.gsub(weaponConfig.itemName, weaponConfig.rarity, "<Rarity>", 1)
  weaponType = string.gsub(weaponType, weaponConfig.rarity:lower(), "<rarity>", 1)

  return weaponType
end
