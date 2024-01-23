shared_script '@WaveShield/resource/waveshield.lua' --this line was automatically written by WaveShield

fx_version "adamant"
game "gta5"
lua54 "yes"

ui_page 'web/index.html'

files {
    'client/modules/*.lua',
    'web/index.html',
    'web/script.js',
    'locales/*.json',
}

shared_scripts {
    '@ox_lib/init.lua',
    "shared/config.lua",
}

client_scripts {
    "client/enums.lua",
    "client/client.lua"
}

server_scripts {
    "server/config.lua",
    "server/server.lua"
}