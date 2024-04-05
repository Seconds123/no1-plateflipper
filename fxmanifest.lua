fx_version 'cerulean'
game 'gta5'

author 'PlayerNo1'
description 'Stealth plate flipper script'
version '1.0.2'

shared_scripts {
    '@ox_lib/init.lua',
    'framework/*.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'inventory/*.lua',
    'server.lua'
}

client_script 'client.lua'

files {
    'black.png'
} 

lua54 'yes'
