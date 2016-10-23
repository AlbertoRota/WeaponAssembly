function paintWeapon()
  local weapon = getWeapon()
  local inks = getInks()
  if weapon and inks and world.containerItemAt(entity.id(), 4) == nil then
    return paint(weapon, inks)
  end
end

function getWeapon()
  local weapon = world.containerItemAt(entity.id(), 3)
  if not isValidWeapon(weapon) then return false end
  return weapon
end

function getInks()
  local items = {}
  local inks = {}
  items["main"] = world.containerItemAt(entity.id(), 0)
  items["secondary"] = world.containerItemAt(entity.id(), 1)
  items["detail"] = world.containerItemAt(entity.id(), 2)

  for k,v in pairs(items) do
    local itemConfig = root.itemConfig(v).config
    if not itemConfig.dyeColorIndex then return false end
    inks[k] = itemConfig
  end

  return inks
end

function paint(weapon, inks)
  sb.logInfo("weapon to paint = %s", weapon)
  if not weapon.parameters.WA_customPalettes then weapon.parameters.WA_customPalettes = {} end
  for layer, ink in pairs(inks) do
    weapon.parameters.WA_customPalettes[layer] = {
      palette = ink.WA_palette or "/items/active/weapons/colors/WA_baseColors.weaponcolors",
      colorIndex = ink.dyeColorIndex
    }
  end

  return weapon
end

-------------------------------------------------------
-- Urility functions
-------------------------------------------------------
-- TODO: Duplicate code, clean it
function isValidWeapon(weapon)
  if weapon then
    local builder = root.itemConfig(weapon).config.builder
    if builder == "/items/buildscripts/buildweapon.lua" or builder == "/items/buildscripts/sup_buildweapon.lua"  then
      return true
    end
  end
  return false
end
