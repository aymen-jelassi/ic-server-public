resource_manifest_version '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

ui_page 'nui/ui.html'

files {
	"nui/ui.html",
	"nui/pricedown.ttf",
	"nui/default.png",
	"nui/background.png",
	"nui/weight-hanging-solid.png",
	"nui/hand-holding-solid.png",
	"nui/search-solid.png",
	"nui/invbg.png",
	"nui/styles.css",
	"nui/scripts.js",
	"nui/debounce.min.js",
	"nui/loading.gif",
	"nui/loading.svg",
	"nui/icons/*"
  }


shared_script 'shared_list.js'
client_script 'client.js'
client_script 'functions.lua'
server_script 'sv_functions.lua'
server_script 'server_shops.js'
client_script 'client_shops.lua'
server_script 'server.js'
client_script "@np-remotecalls/client/cl_main.lua"



exports{
	'hasEnoughOfItem',
	'getQuantity',
	'GetCurrentWeapons',
	'GetItemInfo'
}
