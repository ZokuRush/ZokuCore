-- Bank Balance Check
RegisterCommand('bank', function(source, args)
	local xPlayer = ESX.GetPlayerFromId(source)
	local balance = xPlayer.getAccount('bank').money
	if balance < 0 then
		local debt = balance * -1
		TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = "You have an unpaid loan of <span style='font-weight:500;'>$".. debt, length = 10000 })
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = "You have <span style='font-weight:500;'>$".. balance .."</span> on your bank account", length = 10000 })
	end
end)