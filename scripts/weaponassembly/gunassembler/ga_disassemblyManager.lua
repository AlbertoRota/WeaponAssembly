require "/scripts/weaponassembly/util/util.lua"

function breakIntoParts()
  local inputGun = world.containerItemAt(entity.id(), 3)
  if inputGun then
    sb.logInfo("builder : %s", root.itemConfig(inputGun).config.builder)
  end
  if inputGun and root.itemConfig(inputGun).config.builder == "/items/buildscripts/buildweapon.lua" then
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

  -- TODO: Replace with parameter from the own gun, not pased to the object
  for partName,stats in pairs(self.partStats) do

    -- Basic part initialization
    parts[partName] = {
      name = "WA_" .. partName,
      count = 1,
      parameters = {
        rarity = weaponConfig.rarity,
        image = getPartImage(partName, weaponConfig),
        inventoryIcon = getPartImage(partName, weaponConfig),
        shortdescription = buildShortDescription(partName, weaponConfig),
        description = buildDescription(partName, weaponConfig),
        weaponType = weaponConfig.category
      }
    }

    -- Stat copy process
    local propertiesToStore = root.itemConfig(parts[partName]).config.propertiesToStore
    parts[partName].parameters.weaponData = cloneProperties(propertiesToStore, root.itemConfig(weapon))

    local propertiesToAverage = root.itemConfig(parts[partName]).config.propertiesToAverage
    parts[partName].parameters.averageableData = cloneProperties(propertiesToAverage, root.itemConfig(weapon))

  end

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
  local weaponNiceName = string.gsub(weaponConfig.shortdescription, "(%w+)", "", 1)
  return weaponNiceName .. " " .. partNiceName[partName]
end

function buildDescription(partName, weaponConfig)
  local description = ""
  if partName == "butt" then
    description = "Level:           " .. weaponConfig.level
    if weaponConfig.tooltipFields.altAbilityLabel then
      description = description .. "\nSpecial ability: " .. weaponConfig.tooltipFields.altAbilityLabel
    end
  elseif partName == "middle" then
    description = "Level:        " .. weaponConfig.level .. "\nRate of fire: " .. weaponConfig.tooltipFields.speedLabel
  elseif partName == "barrel" then
    description = "Level:             " .. weaponConfig.level .. "\nDamage per second: " .. weaponConfig.tooltipFields.dpsLabel
  end
  return description
end

function getPartImage(partName, weaponConfig)
  return weaponConfig.animationParts[partName]
end
