require "/scripts/weaponassembly/WA_util.lua"
require "/scripts/weaponassembly/WA_paintManager.lua"

function init()
  if storage.inventory == nil then storage.inventory = {} end
  if storage.lastInventory == nil then storage.lastInventory = {} end
end

function die()

end

function containerCallback(args)
  local slots = {}
  for i = 0, 4 do
    storage.lastInventory[i + 1] = storage.inventory[i + 1]
    if inventorySlotChanged(i) then
      table.insert(slots, i)
    end
  end

  containerSlotsChanged(slots)
end

function containerSlotsChanged(slots)
  if slots[1] == 3 then
      if storage.lastInventory[4] then
        containerTakeItem(4)
      else
        world.spawnItem(containerSpitItem(4), entity.position())
      end
  end
  if slots[1] == 0 or slots[1] == 1 or slots[1] == 2 then
    if storage.lastInventory[4] and storage.lastInventory[5] then
      containerTakeItem(4)
    end
  end
  if slots[1] == 4 then
    if storage.lastInventory[4] and storage.lastInventory[5] then
      containerTakeItem(0)
      containerTakeItem(1)
      containerTakeItem(2)
      containerTakeItem(3)
    end
  end

  local weapon = paintWeapon()
  if weapon then
    containerPutItem(weapon, 4)
    return
  end

end

-------------------------------------------------------
-- Urility functions
-------------------------------------------------------
-- REVIEW: This code is duplicated, generalize it
function containerTakeItem(slot)
  world.containerTakeNumItemsAt(entity.id(), slot, 1)
  storage.inventory[slot+1] = world.containerItemAt(entity.id(), slot)
end

function containerSpitItem(slot)
  storage.inventory[slot+1] = nil
  return world.containerTakeAt(entity.id(), slot)
end

function containerPutItem(item, slot)
  world.containerPutItemsAt(entity.id(), item, slot)
  storage.inventory[slot+1] = world.containerItemAt(entity.id(), slot)
end
