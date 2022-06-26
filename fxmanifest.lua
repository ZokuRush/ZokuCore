fx_version 'bodacious'
game 'gta5'

dependencies {
	'es_extended',
	'mythic_notify'
}

shared_scripts {
	'sh_config.lua'
}

server_scripts {
    'sh_config.lua',
    'server/sv_blockvpn,lua',
	'server/sv_core.lua',
    'server/sv_items.lua',
    'server/sv_commands.lua'
}

client_scripts {
    'sh_config.lua',
	'client/cl_circlemap.lua',
	'client/cl_core.lua',
    'client/cl_events.lua',
    'client/cl_commands.lua'
}