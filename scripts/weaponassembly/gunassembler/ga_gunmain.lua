require "/scripts/weaponassembly/util/util.lua"
require "/scripts/weaponassembly/gunassembler/ga_assemblyManager.lua"
require "/scripts/weaponassembly/gunassembler/ga_disassemblyManager.lua"

function init(virtual)
  if not virtual then
    self.partStats = config.getParameter("partStats", {})

    -- TODO: Use this somewere, no need to hardcode things
    self.partIndex = {butt = 1, middle = 2, barrel = 3}

    self.globalStats = {"weaponType", "level", "levelScale"}

    if storage.inventory == nil then storage.inventory = {} end
  end
end

function die()

end

function containerCallback(args)
  local slots = {}
  for i = 0, 3 do
    if inventorySlotChanged(i) then
      table.insert(slots, i)
    end
  end

  containerSlotsChanged(slots)
end

function containerSlotsChanged(slots)
  if slots[1] == 3 then
    if storage.inventory[4] then sb.logInfo("Input gun : %s", root.itemConfig(storage.inventory[4])) end
    containerTakeItem(0)
    containerTakeItem(1)
    containerTakeItem(2)
  end
  if slots[1] == 0 or slots[1] == 1 or slots[1] == 2 then
    containerTakeItem(3)
  end


  local parts = breakIntoParts()
  if parts then
    containerPutItem(parts["butt"], 0)
    containerPutItem(parts["middle"], 1)
    containerPutItem(parts["barrel"], 2)
    if storage.inventory[1] then sb.logInfo("Output butt   : %s", root.itemConfig(storage.inventory[1])) end
    if storage.inventory[2] then sb.logInfo("Output middle : %s", root.itemConfig(storage.inventory[2])) end
    if storage.inventory[3] then sb.logInfo("Output barrel : %s", root.itemConfig(storage.inventory[3])) end
    return
  end

  local gun = combineParts()
  if gun then
    containerPutItem(gun, 3)
    sb.logInfo("Output gun : %s", root.itemConfig(gun))
    return
  end

end

function containerTakeItem(slot)
  world.containerTakeAt(entity.id(), slot)
  storage.inventory[slot+1] = nil
end

function containerPutItem(item, slot)
  world.containerPutItemsAt(entity.id(), item, slot)
  storage.inventory[slot+1] = world.containerItemAt(entity.id(), slot)
end

function main()
end
