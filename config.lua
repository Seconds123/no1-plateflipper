Config = {}

-- Key to toggle the plate flipper if it's installed in the vehicle
Config.FlipKey = 'J'

-- Cooldown after toggling the plate flipper
Config.SwitchCooldown = 30 

-- Duration to install the plate flipper by mechanic
Config.InstallDuration = 5000

-- Enable this to make anyone install the plate flipper as long as they have the item
Config.UseJobCheck = true

-- Jobs which are allowed to install plate flipper
Config.JobsAllowed = {
    'mechanic'
}