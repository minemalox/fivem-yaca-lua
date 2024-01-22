shared_script '@WaveShield/resource/waveshield.lua' --this line was automatically written by WaveShield

fx_version "adamant"
game "gta5"
lua54 "yes"

ui_page 'web/index.html'

files {
    'client/modules/*.lua',
    'web/index.html',
    'web/script.js',
}

shared_scripts {
    '@ox_lib/init.lua',
    "config.lua",
}

client_scripts {
    "client/cl_main.lua"
}

server_scripts {
    "server/sv_main.lua"
}