require "/scripts/weaponassembly/util/util.lua"

function breakIntoParts()
  local inputGun = world.containerItemAt(entity.id(), 3)
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

  local rootWeaponConfig = root.itemConfig(weapon)
  local weaponConfig = rootWeaponConfig.config
  local weaponParameters = rootWeaponConfig.parameters

  -- TODO: Replace with parameter from the own gun, not pased to the object
  local partList = buildPartList(weaponParameters)
  for _, partName in ipairs(partList) do
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
        weaponType = buildWeaponType(weaponConfig)
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
-- TODO: Review this code to make it better
function buildPartList(weaponParameters)
  local partList = {}
  local partCount = 0
  for k,v in pairs(weaponParameters.animationPartVariants) do
      table.insert(partList, k)
      partCount = partCount + 1
  end
  if partCount == 2 then table.insert(partList, "technique") end

  return partList
end

function getPartImage(partName, weaponConfig)
  return weaponConfig.animationParts[partName]
end

function buildShortDescription(partName, weaponConfig)
  local partNiceName = {middle = "Body", butt = "Stock", barrel = "Barrel", handle = "Handle", blade = "Blade", technique = "Technique"}
  local weaponNiceName = string.gsub(weaponConfig.shortdescription, "(%w+)", "", 1)
  return weaponNiceName .. " " .. (partNiceName[partName] or "Unknown part")
end

function buildDescription(partName, weaponConfig)
  local description = "Level: " .. (weaponConfig.level or 0)
  if partName == "butt" or partName == "technique" then
    if weaponConfig.tooltipFields.altAbilityLabel then
      description = description .. "\nSpecial ability: " .. weaponConfig.tooltipFields.altAbilityLabel
    end
  elseif partName == "middle" or partName == "handle" then
    description = description .. "\nRate of fire: " .. weaponConfig.tooltipFields.speedLabel
  elseif partName == "barrel" or partName == "blade" then
    description = description .. "\nDamage per second: " .. weaponConfig.tooltipFields.dpsLabel
  end
  return description
end

function buildWeaponType(weaponConfig)
  local weaponType = weaponConfig.itemName
  weaponType = string.gsub(weaponType, weaponConfig.rarity, "<Rarity>", 1)
  weaponType = string.gsub(weaponType, weaponConfig.rarity:lower(), "<rarity>", 1)
  return weaponType
end
