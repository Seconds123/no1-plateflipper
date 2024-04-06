# no1-plateflipper

## Installation

1. Import SQL according to your framework version.
2. Add Item from below according to your inventory.
3. Set up the config for default keys, flipper install duration and jobs which are allowed to install stealth flipper.
4. Start the script and enjoy!

# Dependencies
- ox_lib

## Exports

# isPlateHidden(vehicle)
Returns if the vehicle plate is hidden.

# Wraith ARS 2X Integration

1. Find line 270
```lua
if ( self:GetPlate( cam ) ~= plate ) thenif ( self:GetPlate( cam ) ~= plate ) then
```

2. Replace line 270 to 297 with the code below

```lua
						if ( index ~= 5 ) then
							if ( self:GetPlate( cam ) ~= plate ) then
								-- Set the plate for the current reader
								self:SetPlate( cam, plate )

								-- Set the plate index for the current reader
								self:SetIndex( cam, index )

								-- Automatically lock the plate if the scanned plate matches the BOLO
								if ( plate == self:GetBoloPlate() ) then
									self:LockCam( cam, false, true )

									SYNC:LockReaderCam( cam, READER:GetCameraDataPacket( cam ) )
								end

								-- Send the plate information to the NUI side to update the UI
								SendNUIMessage( { _type = "changePlate", cam = cam, plate = plate, index = index } )

								-- If we use Sonoran CAD, reduce the plate events to just player's vehicle, otherwise life as normal
								if ( ( CONFIG.use_sonorancad and ( UTIL:IsPlayerInVeh( veh ) or IsVehiclePreviouslyOwnedByPlayer( veh ) ) and GetVehicleClass( veh ) ~= 18 ) or not CONFIG.use_sonorancad ) then
									-- Trigger the event so developers can hook into the scanner every time a plate is scanned
									TriggerServerEvent( "wk:onPlateScanned", cam, plate, index )
							end
						end
					end
				end
			end
		end
	end
end
```

## Extra Information

# Item to be added to the inventory.

# ox_inventory
["plateflipper"] = {
	label = "Plate Flipper",
	weight = 1000,
	stack = false,
	close = true,
},

# qb-inventory
plateflipper                 = { name = 'plateflipper', label = 'Plate Flipper', weight = 1000, type = 'item', image = 'plateflipper.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = '...'}

## wk_wars2x

If you want the plate radar script to integrate with the flipper script, all you have to do is go to wk_wars2x/cl_plate_reader.lua -> Search for line 261 and find this code. It should exactly like this.
```
if ( dir > 0 ) then
	-- Get the licence plate text from the vehicle
	local plate = GetVehicleNumberPlateText( veh )
	-- Get the licence plate index from the vehicle
	local index = GetVehicleNumberPlateTextIndex( veh )
	-- Only update the stored plate if it's different, otherwise we'd keep sending a NUI message to update the displayed
	-- plate and image even though they're the same
	if ( self:GetPlate( cam ) ~= plate ) then
		-- Set the plate for the current reader
		self:SetPlate( cam, plate )
		-- Set the plate index for the current reader
		self:SetIndex( cam, index )
		-- Automatically lock the plate if the scanned plate matches the BOLO
		if ( plate == self:GetBoloPlate() ) then
			self:LockCam( cam, false, true )
			SYNC:LockReaderCam( cam, READER:GetCameraDataPacket( cam ) )
		end
		-- Send the plate information to the NUI side to update the UI
		SendNUIMessage( { _type = "changePlate", cam = cam, plate = plate, index = index } )
		-- If we use Sonoran CAD, reduce the plate events to just player's vehicle, otherwise life as normal
		if ( ( CONFIG.use_sonorancad and ( UTIL:IsPlayerInVeh( veh ) or IsVehiclePreviouslyOwnedByPlayer( veh ) ) and GetVehicleClass( veh ) ~= 18 ) or not CONFIG.use_sonorancad ) then
			-- Trigger the event so developers can hook into the scanner every time a plate is scanned
			TriggerServerEvent( "wk:onPlateScanned", cam, plate, index )
		end
	end
end
```
Replace that above code with the one right below.
```
if ( dir > 0 ) then
	-- Get the licence plate text from the vehicle
	local plate = GetVehicleNumberPlateText( veh )

	-- Get the licence plate index from the vehicle
	local index = GetVehicleNumberPlateTextIndex( veh )

	-- Check if the plate index is not equal to hidden index (if using plate flipper script)
	if ( index ~= 5) then
		-- Only update the stored plate if it's different, otherwise we'd keep sending a NUI message to update the displayed
		-- plate and image even though they're the same
		if ( self:GetPlate( cam ) ~= plate ) then
			-- Set the plate for the current reader
			self:SetPlate( cam, plate )

			-- Set the plate index for the current reader
			self:SetIndex( cam, index )

			-- Automatically lock the plate if the scanned plate matches the BOLO
			if ( plate == self:GetBoloPlate() ) then
				self:LockCam( cam, false, true )

				SYNC:LockReaderCam( cam, READER:GetCameraDataPacket( cam ) )
			end

			-- Send the plate information to the NUI side to update the UI
			SendNUIMessage( { _type = "changePlate", cam = cam, plate = plate, index = index } )

			-- If we use Sonoran CAD, reduce the plate events to just player's vehicle, otherwise life as normal
			if ( ( CONFIG.use_sonorancad and ( UTIL:IsPlayerInVeh( veh ) or IsVehiclePreviouslyOwnedByPlayer( veh ) ) and GetVehicleClass( veh ) ~= 18 ) or not CONFIG.use_sonorancad ) then
				-- Trigger the event so developers can hook into the scanner every time a plate is scanned
				TriggerServerEvent( "wk:onPlateScanned", cam, plate, index )
			end
		end
	end
end
```
