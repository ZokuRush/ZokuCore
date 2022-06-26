-- Binoculars
ESX.RegisterUsableItem('binoculars', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('ZokuCore:binoculars', source)
end)

-- O2 Tank
ESX.RegisterUsableItem('oxygentank', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('ZokuCore:oxygentank', source)
end)