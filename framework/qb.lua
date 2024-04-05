if GetResourceState('qb-core') ~= "started" then return end

local QBCore = exports['qb-core']:GetCoreObject()

VEHICLE_TABLE = 'player_vehicles'
VEHICLE_COLUMN = 'mods'

if IsDuplicityVersion() then
    function GetPlayerJob(playerId) 
        return QBCore.Functions.GetPlayer(playerId).PlayerData.job.name or 'unemployed'
    end

    function RegisterUseableItem(itemName, data)
        QBCore.Functions.CreateUseableItem(itemName, data)
    end

    function IsVehicleOwned(plate)
        local isOwned = MySQL.scalar.await('SELECT 1 FROM ' .. VEHICLE_TABLE .. ' WHERE plate = ?', { plate })
        return isOwned and true or false
    end

    function GetItem(itemName)
        return QBCore.Shared.Items[itemName]
    end
else
    function GetPlayerJob()
        return QBCore.Functions.GetPlayerData().job.name or 'unemployed'
    end

    function GetClosestVehicle()
        return QBCore.Functions.GetClosestVehicle()
    end
end