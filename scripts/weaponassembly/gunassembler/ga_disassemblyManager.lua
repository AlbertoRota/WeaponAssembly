require "/scripts/weaponassembly/util/util.lua"

function breakIntoParts()
  local inputGun = world.containerItemAt(entity.id(), 3)
  if inputGun and self.acceptedWeapons[inputGun.name] then
    if world.containerItemAt(entity.id(), 0) == nil and world.containerItemAt(entity.id(), 1) == nil and world.containerItemAt(entity.id(), 2) == nil then
      return disassemble(inputGun)
    end
  end
end

function disassemble(weapon)
  local parts = {}

  local splitName = {}
  for namepiece in string.gmatch(weapon.parameters.shortdescription, "%a+") do
    splitName[#splitName+1] = namepiece
  end

  local weaponConfig = root.itemConfig(weapon).config
  for partName,stats in pairs(self.partStats) do

    -- Basic part initialization
    parts[partName] = {
      name = buildName(partName, weaponConfig),
      count = 1,
      parameters = {
        disassembled = true,
        partType = partName,
        rarity = weaponConfig.rarity,
        image = getPartImage(partName, weaponConfig),
        inventoryIcon = getPartImage(partName, weaponConfig),
        shortdescription = buildShortDescription(partName, weaponConfig),
        description = buildDescription(partName, weaponConfig),
        weaponType = root.itemConfig(weapon).config.category,
        weaponData = {}
      }
    }

    -- Stat copy process
    local propertiesToStore = root.itemConfig(parts[partName]).config.propertiesToStore
    parts[partName].parameters.weaponData = cloneProperties(propertiesToStore, root.itemConfig(weapon))

    local propertiesToAverage = root.itemConfig(parts[partName]).config.propertiesToAverage
    parts[partName].parameters.averageableData = cloneProperties(propertiesToAverage, root.itemConfig(weapon))

  end

  sb.logInfo("parts disassembled : %s", parts)
  return parts
end

-------------------------------------------------------
-- Urility functions
-------------------------------------------------------
function buildName(partName, weaponConfig)
  return string.lower(weaponConfig.category .. partName)
end

function buildShortDescription(partName, weaponConfig)
  local partNiceName = {middle = "Body", butt = "Stock", barrel = "Barrel"}
  return weaponConfig.shortdescription .. " " .. partNiceName[partName]
end

function buildDescription(partName, weaponConfig)
  local description = ""
  if partName == "butt" then
    description = "Special ability:\n    " .. weaponConfig.tooltipFields.altAbilityLabel
  elseif partName == "middle" then
    description = "Rate of fire:\n    " .. weaponConfig.tooltipFields.speedLabel
  elseif partName == "barrel" then
    description = "Damage per second:\n    " .. weaponConfig.tooltipFields.dpsLabel
  end
  return description
end

function getPartImage(partName, weaponConfig)
  return weaponConfig.animationParts[partName]
end
