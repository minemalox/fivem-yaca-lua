fx_version 'cerulean'
game 'gta5'

description 'Yaca Voice System'
author 'Yaca Voice Development Team'
version '0.0.1'
lua54 'yes'

ui_page {
	'web/index.html'
}

files{
    'web/style.css',
    'web/yaca_system.js',
    'web/index.html'
}

shared_scripts {
    '/shared/configuration.lua',
}


server_scripts{
    '/server/*.lua',
    '/server/handler/*.lua',
    '/server/yaca_entitys/*.lua',
    '/server/threads/*.lua'
}


client_scripts {
    '/client/*.lua',
    '/client/handler/*.lua'
}