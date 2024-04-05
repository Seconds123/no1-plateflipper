local vehicles = {}
local vehicles_plate = {}

lib.callback.register('no1-plateflipper:IsFlippedInstalled', function(source, plate)
    if vehicles[plate] then
        return vehicles[plate]
    end

    local installed = MySQL.scalar.await('SELECT flipper_installed FROM player_vehicles WHERE plate = ?', { plate })
    vehicles[plate] = installed
    return installed
end)

lib.callback.register('no1-plateflipper:GetPlateIndex', function(source, plate, netid)
    if vehicles_plate[plate] then
        return vehicles_plate[plate]
    end

    local entity = NetworkGetEntityFromNetworkId(netid)

    local plateIndex = MySQL.scalar.await("SELECT JSON_EXTRACT(" .. VEHICLE_COLUMN .. ", '$.plateIndex') FROM " .. VEHICLE_TABLE .. " WHERE plate = ?", { plate })
    if not plateIndex then
        vehicles_plate[plate] = 0
        Entity(entity).state.plate_index = 0
        return 0
    end

    Entity(entity).state.plate_index = plateIndex

    return plateIndex
end)

lib.callback.register('no1-plateflipper:callback:IsVehicleOwned', function(source, plate)
    return IsVehicleOwned(plate)
end)

-- Job Check Function --
function HasWhitelistedJob(playerId) 
    if not Config.UseJobCheck then return true end

    local jobName = GetPlayerJob(playerId)
    local hasJob = false

    for _, job in pairs(Config.JobsAllowed) do
        if job == jobName then
            hasJob = true
            break
        end
    end

    return hasJob
end

RegisterNetEvent('no1-plateflipper:InstallFlipper', function(plate)
    local src = source

    if not canInstall(GetPlayerJob(src)) then return end

    local success = exports.ox_inventory:RemoveItem(src, 'plateflipper', 1)

    if success then
        MySQL.update('UPDATE player_vehicles SET flipper_installed = 1 WHERE plate = ?', { plate })
        TriggerClientEvent('QBCore:Notify', src, "You've installed the plate flipper in the vehicle, re-enter the vehicle to enable it ("..Config.FlipKey.." key)")
    end
end)

RegisterNetEvent('no1-plateflipper:InstallPlateFlipper', function(plate, plateIndex)
    local src = source
    if not HasWhitelistedJob(src) then return end

    if RemoveItem(src, 'plateflipper', 1) then
        MySQL.query("UPDATE "..VEHICLE_TABLE.." SET flipper_installed = 1 WHERE plate = ?", { plate })
        vehicles_plate[plate] = plateIndex
        vehicles[plate] = true
        TriggerClientEvent('no1-plateflipper:notify', src, { description = "Plate flipper installed successfully!", type = 'success' } )
    end
end)

RegisterNetEvent('no1-plateflipper:SetVehicleDoorsLocked', function(netid, state)
    local src = source
    if not HasWhitelistedJob(src) then return end
    local entity = NetworkGetEntityFromNetworkId(netid)
    SetVehicleDoorsLocked(entity, state)
    FreezeEntityPosition(entity, state == 2)
end)

RegisterNetEvent('no1-plateflipper:TogglePlate', function(netid, state)
    local entity = NetworkGetEntityFromNetworkId(netid)
    local plate = GetVehicleNumberPlateText(entity)
    if not vehicles_plate[plate] then return end

    if state == true then
        Entity(entity).state.flipper_enabled = 1
    else
        Entity(entity).state.flipper_enabled = 0
    end
end)

RegisterUseableItem('plateflipper', function(source, item)
    if HasWhitelistedJob(source) then
        TriggerClientEvent('no1-plateflipper:InstallPlateFlipper', source)
    else
        TriggerClientEvent('no1-plateflipper:notify', source, { type = 'error', description = "You do not have the required job to install the plate flipper!"})
    end
end)