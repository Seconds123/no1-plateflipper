# no1-plateflipper

## Installation

1. Import SQL according to your framework version.
2. Add Item from below according to your inventory.
3. Set up the config for default keys, flipper install duration and jobs which are allowed to install stealth flipper.
4. Start the script and enjoy!

# Dependencies
- ox_lib

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