require "/scripts/util.lua"
require "/scripts/weaponassembly/util/util.lua"

function combineParts()
  local parts = getInputParts()

  if parts and world.containerItemAt(entity.id(), 3) == nil then
    return assemble(parts)
  end
end

function getInputParts()
  local parts = {}

  parts["butt"] = world.containerItemAt(entity.id(), 0)
  parts["middle"] = world.containerItemAt(entity.id(), 1)
  parts["barrel"] = world.containerItemAt(entity.id(), 2)

  if not parts["butt"] or parts["butt"].parameters.partType ~= "butt" then return false end
  if not parts["middle"] or parts["middle"].parameters.partType ~= "middle" then return false end
  if not parts["barrel"] or parts["barrel"].parameters.partType ~= "barrel" then return false end

  return parts
end

function assemble(parts)
  local newGun = {
    name = "rareassaultrifle",
    count = 1,
    parameters = {
      itemName = "rareassaultrifle",
      assembled = true,
      shortdescription = "Rare Assault Rifle", --findName(parts),
      rarity = "Rare"--findRarity(parts)
    }
  }

  newGun.parameters.level = 1 --(parts["butt"].parameters.weaponData.level + parts["middle"].parameters.weaponData.level + parts["barrel"].parameters.weaponData.level) / 3
  -- newGun.parameters.levelScale = (parts["butt"].parameters.weaponData.levelScale + parts["middle"].parameters.weaponData.levelScale + parts["barrel"].parameters.weaponData.levelScale) / 3

  local images = {}
  for partName,part in pairs(parts) do
    -- if newGun.parameters.weaponType and newGun.parameters.weaponType ~= part.parameters.weaponData.weaponType then return false end

    -- newGun.parameters.weaponType = part.parameters.weaponData.weaponType
    images[partName] = part.parameters.image
    local propertiesToStore = root.itemConfig(parts[partName]).config.propertiesToStore
    sb.logInfo("Merging parts[%s] : %s", partName, parts[partName])
    util.mergeTable(newGun, cloneProperties(propertiesToStore, parts[partName].parameters.weaponData))
    --[[
    stats = self.partStats[partName]
    for _,stat in ipairs(stats) do
      if part.parameters.weaponData[stat] ~= nil then newGun.parameters[stat] = part.parameters.weaponData[stat] end
    end
    --]]
  end

  local drawables = makeDrawables(images)
  -- newGun.parameters.drawables = drawables
  -- newGun.parameters.inventoryIcon = drawables

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
  local avg = math.floor(sum / 3)
  return rarities[avg]
end

function makeDrawables(images)
  local buttSize = root.imageSize(images["butt"])
  local middleSize = root.imageSize(images["middle"])
  local barrelSize = root.imageSize(images["barrel"])

  local drawables = {}
  drawables[1] = {image = images["butt"], position = {-math.ceil(buttSize[1] / 2) + -math.floor(middleSize[1] / 2) + 0.1, 0}}
  drawables[2] = {image = images["middle"], position = {0,0}}
  drawables[3] = {image = images["barrel"], position = {math.floor(barrelSize[1] / 2) + math.ceil(middleSize[1] / 2) - 0.1, 0}}
  return drawables
end
