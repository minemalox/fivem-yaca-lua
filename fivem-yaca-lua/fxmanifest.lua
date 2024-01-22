shared_script '@WaveShield/resource/waveshield.lua' --this line was automatically written by WaveShield

fx_version "adamant"
game "gta5"
lua54 "yes"

ui_page 'web/index.html'

files {
    'client/*.lua',
    'web/index.html',
    'web/script.js',
}

shared_scripts {
    '@ox_lib/init.lua',
    "config.lua",
}

client_scripts {
    "client/*.lua"
}

server_scripts {
    "server/*.lua"
}