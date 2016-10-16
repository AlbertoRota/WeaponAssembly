function inventorySlotChanged(slot)
  if not compare(storage.inventory[slot + 1], world.containerItemAt(entity.id(), slot)) then
    storage.inventory[slot+1] = world.containerItemAt(entity.id(), slot)
    return true
  end
  return false
end

function compare(t1,t2)
  if t1 == t2 then return true end
  if type(t1) ~= type(t2) then return false end
  if type(t1) ~= "table" then return false end
  for k,v in pairs(t1) do
    if not compare(v, t2[k]) then return false end
  end
  for k,v in pairs(t2) do
    if not compare(v, t1[k]) then return false end
  end
  return true
end

function round(num, numDecimals)
  local mult = 10^(numDecimals or 0)
  return math.floor(num * mult + 0.5) / mult
end

function cloneProperties (propertiesToStore, weaponConfig)
  -- Load value/table into target and return
  if type(propertiesToStore) ~= "table" then
    return  weaponConfig
  end

  -- Go one level deeper
  local meta = getmetatable(propertiesToStore)
  local target = {}
  for k, v in pairs(propertiesToStore) do
    target[k] = cloneProperties(propertiesToStore[k], weaponConfig[k])
  end
  setmetatable(target, meta)
  return target
end