if GetResourceState("qb-inventory") ~= "started" then return end

function RemoveItem(source, item, amount)
    return exports['qb-inventory']:RemoveItem(source, item, amount)
end

function AddItem(source, item, amount)
    return exports['qb-inventory']:AddItem(source, item, amount)
end