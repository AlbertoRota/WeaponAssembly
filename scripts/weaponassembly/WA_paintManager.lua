require "/scripts/weaponassembly/WA_precdyeHelper.lua"

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
    if not itemConfig.dyeColorIndex and not itemConfig.dyeMode then return false end
    inks[k] = itemConfig
  end

  return inks
end

function paint(weapon, inks)
  if not weapon.parameters.WA_customPalettes then weapon.parameters.WA_customPalettes = {} end
  for layer, ink in pairs(inks) do
    if ink.dyeColorIndex and ink.dyeColorIndex > 0 then
      local baseColors = root.assetJson("/items/active/weapons/colors/WA_baseColors.weaponcolors").colors
      local targetColors = baseColors[ink.dyeColorIndex]
      weapon.parameters.WA_customPalettes[layer] = targetColors
    elseif  ink.dyeColorIndex and ink.dyeColorIndex == 0 then
      weapon.parameters.WA_customPalettes[layer] = nil
    elseif ink.dyeMode then
      local colors = weapon.parameters.WA_customPalettes[layer]
      if not colors then
        local layers = root.assetJson("/items/active/weapons/colors/WA_layers.weaponcolors")
        local palette = root.itemConfig(weapon).config.builderConfig[1].palette
        local weaponPalette = string.match(palette, "/([^/]+)%.weaponcolors")
        colors = layers[weaponPalette .. layer]
      end
      weapon.parameters.WA_customPalettes[layer] = applyPrecDye(colors, ink.dyeMode)
    end
  end

  return weapon
end

-------------------------------------------------------
-- Urility functions
-------------------------------------------------------
-- REVIEW: Duplicate code, clean it
function isValidWeapon(weapon)
  if weapon then
    local builder = root.itemConfig(weapon).config.builder
    if builder == "/items/buildscripts/buildweapon.lua" or builder == "/items/buildscripts/sup_buildweapon.lua"  then
      return true
    end
  end
  return false
end
