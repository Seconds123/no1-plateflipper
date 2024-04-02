local runtimeTexture = "customPlates"
local vehShare = "vehshare"
local plateTxd = CreateRuntimeTxd(runtimeTexture)
local installingFlipper = false

CreateRuntimeTextureFromImage(plateTxd, "yankton_plate", "black.png")
AddReplaceTexture(vehShare, "yankton_plate", runtimeTexture, "yankton_plate")
AddReplaceTexture(vehShare, "yankton_plate_n", runtimeTexture, "yankton_plate")

-- Flip installed
local flipinstalled = false 
local cooldown = 0

-- Return if plate is hidden
local function isPlateHidden(vehicle)
    return GetVehicleNumberPlateTextIndex(vehicle) == 5
end
exports('isPlateHidden', isPlateHidden)

lib.onCache('vehicle', function(vehicle)
    if vehicle == nil then
        flipinstalled = false
    else
        local ped = GetPedInVehicleSeat(vehicle, -1)

        if ped == PlayerPedId() then
            flipinstalled = lib.callback.await('no1-plateflipper:IsFlippedInstalled', 500, GetVehicleNumberPlateText(vehicle))
        end
    end
end)

RegisterCommand('plateflip', function()
    if not flipinstalled then
        return
    end

    if (GetGameTimer() - cooldown) < Config.SwitchCooldown * 1000 then return lib.notify({ type = 'error', description = "Cooldown! Wait a few seconds before trying to hit switch..."}) end

    local playerPed = PlayerPedId()

    if not IsPedInAnyVehicle(playerPed, false) then
        return
    end

    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle == 0 then
        return
    end

    if GetPedInVehicleSeat(vehicle, -1) ~= playerPed then
        return
    end

    local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)

    if not isPlateHidden(vehicle) then
        TriggerServerEvent('no1-plateflipper:TogglePlate', vehicleNetId, true)
        SetVehicleNumberPlateTextIndex(vehicle, 5) -- change it to server setter
    else
        if Entity(vehicle).state.plate_index ~= nil then
            SetVehicleNumberPlateTextIndex(vehicle, Entity(vehicle).state.plate_index)
        else
            lib.callback('no1-plateflipper:GetPlateIndex', false, function(plateIndex)
                SetVehicleNumberPlateTextIndex(vehicle, plateIndex)
            end, GetVehicleNumberPlateText(vehicle), vehicleNetId)
        end

        TriggerServerEvent('no1-plateflipper:TogglePlate', vehicleNetId, false)
    end

    cooldown = GetGameTimer()
end, false)
RegisterKeyMapping('plateflip', 'Flip plate to stealth if installed', 'keyboard', Config.FlipKey)

AddStateBagChangeHandler('flipper_enabled', nil, function(bagName, key, value) 
    Wait(500)
    local entity = GetEntityFromStateBagName(bagName)
    local ped = PlayerPedId()

    if not DoesEntityExist(entity) then return end
    if GetVehiclePedIsIn(ped, false) == entity and GetPedInVehicleSeat(entity, -1) then return end

    SetVehicleNumberPlateTextIndex(entity, Entity(entity).state.plate_index)
end)

RegisterNetEvent('no1-plateflipper:InstallPlateFlipper', function()
    if installingFlipper then return lib.notify({ type = 'error', description = "You are already installing the flipper!"}) end

    local vehicle, distance = GetClosestVehicle()

    if not vehicle or not DoesEntityExist(vehicle) then return lib.notify({ type = 'error', description = "There's no vehicle nearby!"}) end
    if distance > 5 then return lib.notify({ type = 'error', description = "There's no vehicle nearby!"}) end

    local isPeopleInVehicle = false
    for i = -1, GetVehicleNumberOfPassengers(vehicle) do
        local ped = GetPedInVehicleSeat(vehicle, i)
        if ped ~= 0 then
            isPeopleInVehicle = true
            break
        end
    end

    if isPeopleInVehicle then return lib.notify({ type = 'error', description = "The vehicle is occupied!"}) end

    local controlTimeout = 0
    if not NetworkHasControlOfEntity(vehicle) then
        repeat
            NetworkRequestControlOfEntity(vehicle)
            controlTimeout += 100
            Wait(100)
        until NetworkHasControlOfEntity(vehicle) or controlTimeout >= 500
    end

    if controlTimeout >= 500 then return lib.notify({ type = 'error', description = "Try to enter the vehicle and exit before trying to install again!"}) end

    local plate = GetVehicleNumberPlateText(vehicle)
    local isVehicleOwned = lib.callback.await('no1-plateflipper:callback:IsVehicleOwned', false, plate)

    if not isVehicleOwned then return lib.notify({ type = 'error', description = "You can not install plate flipper onto an un-owned vehicle!" }) end

    TriggerServerEvent('no1-plateflipper:SetVehicleDoorsLocked', NetworkGetNetworkIdFromEntity(vehicle), 2)
    local boneid = GetEntityBoneIndexByName(vehicle, 'platelight')
    local position = GetEntityBonePosition_2(vehicle, boneid)
    local ped = PlayerPedId()

    if #(GetEntityCoords(ped) - position) > 2 then return lib.notify({ type = 'error', description = "You are far away from the number plate!" }) end

    if lib.progressBar({
        duration = Config.InstallDuration,
        label = 'Installing plate flipper...',
        useWhileDead = false,
        canCancel = true,
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_player'
        },
        disable = {
            move = true,
            mouse = true,
            car = true,
            combat = true
        }
    }) then
        TriggerServerEvent('no1-plateflipper:InstallPlateFlipper', plate, GetVehicleNumberPlateTextIndex(vehicle))
        TriggerServerEvent('no1-plateflipper:SetVehicleDoorsLocked', NetworkGetNetworkIdFromEntity(vehicle), 1)
    else
        lib.notify({ type = 'error', description = "Cancelled."})
        TriggerServerEvent('no1-plateflipper:SetVehicleDoorsLocked', NetworkGetNetworkIdFromEntity(vehicle), 1)
    end
end)

RegisterNetEvent('no1-plateflipper:notify', function (...)
    lib.notify(...)
end)