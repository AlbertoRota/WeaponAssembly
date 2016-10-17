require "/scripts/util.lua"
require "/scripts/weaponassembly/util/util.lua"

function combineParts()
  local parts = getInputParts()

  if parts and world.containerItemAt(entity.id(), 3) == nil then
    return assemble(parts)
  end
end

function getInputParts()
  -- We have all the parts
  local parts = {}
  parts["butt"] = world.containerItemAt(entity.id(), 0)
  parts["middle"] = world.containerItemAt(entity.id(), 1)
  parts["barrel"] = world.containerItemAt(entity.id(), 2)
  if not parts["butt"] or parts["butt"].name ~= "WA_butt" then return false end
  if not parts["middle"] or parts["middle"].name ~= "WA_middle" then return false end
  if not parts["barrel"] or parts["barrel"].name ~= "WA_barrel" then return false end

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
  local weaponType = parts["middle"].parameters.weaponType:lower()
  local newGun = {
    name = rarity .. weaponType,
    count = 1,
    parameters = {
      itemName = rarity .. weaponType,
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

function findName(parts)
  local nameTable = {}

  if parts["middle"].parameters.weaponData.weaponName then nameTable[#nameTable+1] = parts["middle"].parameters.weaponData.weaponName end
  if parts["butt"].parameters.weaponData.weaponName then nameTable[#nameTable+1] = parts["butt"].parameters.weaponData.weaponName end
  if parts["barrel"].parameters.weaponData.weaponName then nameTable[#nameTable+1] = parts["barrel"].parameters.weaponData.weaponName end

  return table.concat(nameTable, " ")
end

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
