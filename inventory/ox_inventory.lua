if GetResourceState("ox_inventory") ~= "started" then return end

local ox_inventory = exports.ox_inventory

function RemoveItem(source, item, amount)
    return ox_inventory:RemoveItem(source, item, amount)
end

function AddItem(source, item, amount)
    return ox_inventory:AddItem(source, item, amount)
end