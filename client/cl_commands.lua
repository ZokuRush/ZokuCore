-- Check Job/Rank
RegisterCommand("job", function(source, args)
    ShowJob()
end, false)

function ShowJob()
	exports['mythic_notify']:SendAlert('inform', 'Job: <span style="font-weight:500;">' .. PlayerData.job.label .. '</span> | Rank: <span style="font-weight:500;">' .. PlayerData.job.grade_label, 8000)
end

TriggerEvent('chat:addSuggestion', '/job', 'Shows your current job', {})

-- Carry
RegisterCommand("carry",function(source, args)
	if not carry.InProgress then
		local closestPlayer = GetClosestPlayer(3)
		if closestPlayer then
			local targetSrc = GetPlayerServerId(closestPlayer)
			if targetSrc ~= -1 then
				carry.InProgress = true
				carry.targetSrc = targetSrc
				TriggerServerEvent("CarryPeople:sync",targetSrc)
				ensureAnimDict(carry.personCarrying.animDict)
				carry.type = "carrying"
			else
				exports['mythic_notify']:DoHudText('error', 'There is no player(s) nearby!')
			end
		else
			exports['mythic_notify']:DoHudText('error', 'There is no player(s) nearby!')
		end
	else
		carry.InProgress = false
		ClearPedSecondaryTask(PlayerPedId())
		DetachEntity(PlayerPedId(), true, false)
		TriggerServerEvent("CarryPeople:stop",carry.targetSrc)
		carry.targetSrc = 0
	end
end, false)

-- Tackle
RegisterCommand('+Tackle', Tackle, false)
RegisterCommand('-Tackle', function() end, false)
RegisterKeyMapping('+Tackle', 'Tackle another player', 'keyboard', 'E')