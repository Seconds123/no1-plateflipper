local resourceName = nil

if GetResourceState("qb-inventory") == "started" then
    resourceName = "qb-inventory"
elseif GetResourceState("ps-inventory") == "started" then
    resourceName = "ps-inventory"
elseif GetResourceState("lj-inventory") == "started" then
    resourceName = "lj-inventory"
end

if not resourceName then return end

function RemoveItem(source, item, amount)
    if exports[resourceName]:RemoveItem(source, item, amount) then
        TriggerClientEvent('inventory:client:ItemBox', source, GetItem(item), "remove", amount)
        return true
    else return false end
end

function AddItem(source, item, amount)
    if exports[resourceName]:AddItem(source, item, amount) then
        TriggerClientEvent('inventory:client:ItemBox', source, GetItem(item), "add", amount)
        return true
    else return false end
end