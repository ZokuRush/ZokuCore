-- 3D Text (Dont Touch)
function DrawText3D(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.002+ factor, 0.03, 0, 0, 0, 100)
end

-- Animation Loader
local function ensureAnimDict(animDict)
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(0)
        end
    end
    return animDict
end

-- Disable Hud Components
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        HideHudComponentThisFrame(1)
        --HideHudComponentThisFrame(2)
        HideHudComponentThisFrame(3)
        HideHudComponentThisFrame(4)
        HideHudComponentThisFrame(6)
        HideHudComponentThisFrame(7)
        HideHudComponentThisFrame(8)
        HideHudComponentThisFrame(9)
        HideHudComponentThisFrame(13)
        HideHudComponentThisFrame(17)
        HideHudComponentThisFrame(20)
    end
end)

-- Surpress Vehicle Models
Citizen.CreateThread(function()
	while true do
		SetVehicleModelIsSuppressed(GetHashKey("blimp"), true)
		SetVehicleModelIsSuppressed(GetHashKey("blimp2"), true)
		SetVehicleModelIsSuppressed(GetHashKey("blimp3"), true)
		SetVehicleModelIsSuppressed(GetHashKey("turismor"), true)
		SetVehicleModelIsSuppressed(GetHashKey("zentorno"), true)
		SetVehicleModelIsSuppressed(GetHashKey("frogger"), true)
		SetVehicleModelIsSuppressed(GetHashKey("maverick"), true)
		SetVehicleModelIsSuppressed(GetHashKey("buzzard"), true)
		SetVehicleModelIsSuppressed(GetHashKey("duster"), true)
		SetVehicleModelIsSuppressed(GetHashKey("buzzard"), true)
		SetVehicleModelIsSuppressed(GetHashKey("buzzard2"), true)
		SetVehicleModelIsSuppressed(GetHashKey("cargobob"), true)
		SetVehicleModelIsSuppressed(GetHashKey("cargobob2"), true)
		SetVehicleModelIsSuppressed(GetHashKey("cargobob3"), true)
		SetVehicleModelIsSuppressed(GetHashKey("cargobob4"), true)
		SetVehicleModelIsSuppressed(GetHashKey("besra"), true)
		SetVehicleModelIsSuppressed(GetHashKey("cargoplane"), true)
		SetVehicleModelIsSuppressed(GetHashKey("cuban800"), true)
		SetVehicleModelIsSuppressed(GetHashKey("hydra"), true)
		SetVehicleModelIsSuppressed(GetHashKey("jet"), true)
		SetVehicleModelIsSuppressed(GetHashKey("lazer"), true)
		SetVehicleModelIsSuppressed(GetHashKey("luxor"), true)
		SetVehicleModelIsSuppressed(GetHashKey("mammatus"), true)
		SetVehicleModelIsSuppressed(GetHashKey("jester"), true)
		SetVehicleModelIsSuppressed(GetHashKey("jester2"), true)
		SetVehicleModelIsSuppressed(GetHashKey("firetruk"), true)
		SetVehicleModelIsSuppressed(GetHashKey("ambulance"), true)
		SetVehicleModelIsSuppressed(GetHashKey("barracks"), true)
		SetVehicleModelIsSuppressed(GetHashKey("barracks2"), true)
		SetVehicleModelIsSuppressed(GetHashKey("barracks3"), true)
		SetVehicleModelIsSuppressed(GetHashKey("crusader"), true)
		SetVehicleModelIsSuppressed(GetHashKey("rhino"), true)
	end
end)

-- Enable Friendly Fire (PVP)
Citizen.CreateThread(function()
	while true do
        Citizen.Wait(0)
        local Player = PlayerPedId()

		SetCanAttackFriendly(Player, true, false)
		NetworkSetFriendlyFireOption(true)
	end
end)

-- Fix MP Female Health Bug
Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(0)
		if GetEntityMaxHealth(GetPlayerPed(-1)) ~= 200 then
			SetEntityMaxHealth(GetPlayerPed(-1), 200)
			SetEntityHealth(GetPlayerPed(-1), 200)
		end
	end
end)

-- Hands Up
Citizen.CreateThread(function()
    local dict = "missminuteman_1ig_2"
    
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(100)
	end
    local handsup = false
	while true do
		Citizen.Wait(0)
		if IsControlJustPressed(1, 323) then --Start holding X
            if not handsup then
                TaskPlayAnim(GetPlayerPed(-1), dict, "handsup_enter", 8.0, 8.0, -1, 50, 0, false, false, false)
                handsup = true
            else
                handsup = false
                ClearPedTasks(GetPlayerPed(-1))
            end
        end
    end
end)

-- Carry
local carry = {
	InProgress = false,
	targetSrc = -1,
	type = "",
	personCarrying = {
		animDict = "missfinale_c2mcs_1",
		anim = "fin_c2_mcs_1_camman",
		flag = 49,
	},
	personCarried = {
		animDict = "nm",
		anim = "firemans_carry",
		attachX = 0.27,
		attachY = 0.15,
		attachZ = 0.63,
		flag = 33,
	}
}

local function GetClosestPlayer(radius)
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _,PlayerPedId in ipairs(players) do
        local targetPed = GetPlayerPed(PlayerPedId)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(targetCoords-playerCoords)
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = PlayerPedId
                closestDistance = distance
            end
        end
    end
	if closestDistance ~= -1 and closestDistance <= radius then
		return closestPlayer
	else
		return nil
	end
end

RegisterNetEvent("CarryPeople:syncTarget")
AddEventHandler("CarryPeople:syncTarget", function(targetSrc)
	local targetPed = GetPlayerPed(GetPlayerFromServerId(targetSrc))
	carry.InProgress = true
	ensureAnimDict(carry.personCarried.animDict)
	AttachEntityToEntity(PlayerPedId(), targetPed, 0, carry.personCarried.attachX, carry.personCarried.attachY, carry.personCarried.attachZ, 0.5, 0.5, 180, false, false, false, false, 2, false)
	carry.type = "beingcarried"
end)

RegisterNetEvent("CarryPeople:cl_stop")
AddEventHandler("CarryPeople:cl_stop", function()
	carry.InProgress = false
	ClearPedSecondaryTask(PlayerPedId())
	DetachEntity(PlayerPedId(), true, false)
end)

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(0)
		if carry.InProgress then
			if carry.type == "beingcarried" then
				if not IsEntityPlayingAnim(PlayerPedId(), carry.personCarried.animDict, carry.personCarried.anim, 3) then
					TaskPlayAnim(PlayerPedId(), carry.personCarried.animDict, carry.personCarried.anim, 8.0, -8.0, 100000, carry.personCarried.flag, 0, false, false, false)
				end
			elseif carry.type == "carrying" then
				if not IsEntityPlayingAnim(PlayerPedId(), carry.personCarrying.animDict, carry.personCarrying.anim, 3) then
					TaskPlayAnim(PlayerPedId(), carry.personCarrying.animDict, carry.personCarrying.anim, 8.0, -8.0, 100000, carry.personCarrying.flag, 0, false, false, false)
				end
			end
		end
		Wait(0)
	end
end)

-- Hide In Trunk
local inTrunk = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if inTrunk then
            local vehicle = GetEntityAttachedTo(PlayerPedId())
            if DoesEntityExist(vehicle) or not IsPedDeadOrDying(PlayerPedId()) or not IsPedFatallyInjured(PlayerPedId()) then
                local coords = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, 'boot'))
                SetEntityCollision(PlayerPedId(), false, false)
                DrawText3D(coords, '[~o~H~s~] - Exit')

                if GetVehicleDoorAngleRatio(vehicle, 5) < 0.9 then
                    SetEntityVisible(PlayerPedId(), false, false)
                else
                    if not IsEntityPlayingAnim(PlayerPedId(), 'timetable@floyd@cryingonbed@base', 3) then
                        loadDict('timetable@floyd@cryingonbed@base')
                        TaskPlayAnim(PlayerPedId(), 'timetable@floyd@cryingonbed@base', 'base', 8.0, -8.0, -1, 1, 0, false, false, false)

                        SetEntityVisible(PlayerPedId(), true, false)
                    end
                end
                if IsControlJustReleased(0, 74) and inTrunk then
                    SetCarBootOpen(vehicle)
                    SetEntityCollision(PlayerPedId(), true, true)
                    Wait(750)
                    inTrunk = false
                    DetachEntity(PlayerPedId(), true, true)
                    SetEntityVisible(PlayerPedId(), true, false)
                    ClearPedTasks(PlayerPedId())
                    SetEntityCoords(PlayerPedId(), GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, -0.5, -0.75))
                    Wait(250)
                    SetVehicleDoorShut(vehicle, 5)
                end
            else
                SetEntityCollision(PlayerPedId(), true, true)
                DetachEntity(PlayerPedId(), true, true)
                SetEntityVisible(PlayerPedId(), true, false)
                ClearPedTasks(PlayerPedId())
                SetEntityCoords(PlayerPedId(), GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, -0.5, -0.75))
            end
        end
    end
end)   

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local vehicle = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 10.0, 0, 70)
		--Lockstatus
		local lockStatus = GetVehicleDoorLockStatus(vehicle)
		--Lockstatus End
        if DoesEntityExist(vehicle) and IsVehicleSeatFree(vehicle,-1)--GetPedInVehicleSeat(vehicle, false)
		then
            local trunk = GetEntityBoneIndexByName(vehicle, 'boot')
            if trunk ~= -1 then
                local coords = GetWorldPositionOfEntityBone(vehicle, trunk)
                if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), coords, true) <= 1.5 then
                    if not inTrunk then
                        if GetVehicleDoorAngleRatio(vehicle, 5) < 0.9 then
                            DrawText3D(coords, '[~o~H~s~] - Hide')
								if IsControlJustReleased(0, 74)then
									if lockStatus == 1 then --unlocked
										SetCarBootOpen(vehicle)
									elseif lockStatus == 2 then -- locked
										exports['mythic_notify']:DoHudText('error', 'Vehicle Locked!')
									end
								end
                        else
                            DrawText3D(coords, '[~o~H~s~] - Hide')
                            if IsControlJustReleased(0, 9999) then
                                SetVehicleDoorShut(vehicle, 5)
                            end
                        end
                    end
                    if IsControlJustReleased(0, 74) and not inTrunk then
                        local player = ESX.Game.GetClosestPlayer()
                        local playerPed = GetPlayerPed(player)
						local playerPed2 = GetPlayerPed(-1)
						if lockStatus == 1 then --unlocked
							if DoesEntityExist(playerPed) then
								if not IsEntityAttached(playerPed) or GetDistanceBetweenCoords(GetEntityCoords(playerPed), GetEntityCoords(PlayerPedId()), true) >= 5.0 then
									SetCarBootOpen(vehicle)
									Wait(350)
									AttachEntityToEntity(PlayerPedId(), vehicle, -1, 0.0, -2.2, 0.5, 0.0, 0.0, 0.0, false, false, false, false, 20, true)	
									loadDict('timetable@floyd@cryingonbed@base')
									TaskPlayAnim(PlayerPedId(), 'timetable@floyd@cryingonbed@base', 'base', 8.0, -8.0, -1, 1, 0, false, false, false)
									Wait(50)
									inTrunk = true

									Wait(1500)
									SetVehicleDoorShut(vehicle, 5)
								else
									exports['mythic_notify']:DoHudText('error', 'Someone is in the trunk!')
								end
							end
						elseif lockStatus == 2 then -- locked
							exports['mythic_notify']:DoHudText('error', 'Vehicle Locked!')
						end
                    end
                end
            end
        end
        Wait(0)
    end
end)

loadDict = function(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) RequestAnimDict(dict) end
end

-- Fingerpoint
local mp_pointing = false
local keyPressed = false

local function startPointing()
	local ped = PlayerPedId()

	RequestAnimDict("anim@mp_point")
	while not HasAnimDictLoaded("anim@mp_point") do
		Citizen.Wait(1)
	end

	SetPedCurrentWeaponVisible(ped, 0, 1, 1, 1)
	SetPedConfigFlag(ped, 36, 1)
	TaskMoveNetwork(ped, "task_mp_pointing", 0.5, 0, "anim@mp_point", 24)
	RemoveAnimDict("anim@mp_point")
end

local function stopPointing()
	local ped = PlayerPedId()
	Citizen.InvokeNative(0xD01015C7316AE176, ped, "Stop")

	if not IsPedInjured(ped) then
		ClearPedSecondaryTask(ped)
	end

	if not IsPedInAnyVehicle(ped, 1) then
		SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
	end

	SetPedConfigFlag(ped, 36, 0)
	ClearPedSecondaryTask(PlayerPedId())
end

local once = true

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if once then
			once = false
		end

		if not keyPressed then
			if IsControlPressed(0, 29) and not mp_pointing and IsPedOnFoot(PlayerPedId()) then
				Wait(200)
				if not IsControlPressed(0, 29) then
					keyPressed = true
					startPointing()
					mp_pointing = true
				else
					keyPressed = true
					while IsControlPressed(0, 29) do
						Wait(50)
					end
				end
			elseif (IsControlPressed(0, 29) and mp_pointing) or (not IsPedOnFoot(PlayerPedId()) and mp_pointing) then
				keyPressed = true
				mp_pointing = false
				stopPointing()
			end
		end

		if keyPressed then
			if not IsControlPressed(0, 29) then
				keyPressed = false
			end
		end
		if Citizen.InvokeNative(0x921CE12C489C4C41, PlayerPedId()) and not mp_pointing then
			stopPointing()
		end
		if Citizen.InvokeNative(0x921CE12C489C4C41, PlayerPedId()) then
			if not IsPedOnFoot(PlayerPedId()) then
				stopPointing()
			else
				local ped = PlayerPedId()
				local camPitch = GetGameplayCamRelativePitch()
				if camPitch < -70.0 then
					camPitch = -70.0
				elseif camPitch > 42.0 then
					camPitch = 42.0
				end
				camPitch = (camPitch + 70.0) / 112.0

				local camHeading = GetGameplayCamRelativeHeading()
				local cosCamHeading = Cos(camHeading)
				local sinCamHeading = Sin(camHeading)
				if camHeading < -180.0 then
					camHeading = -180.0
				elseif camHeading > 180.0 then
					camHeading = 180.0
				end
				camHeading = (camHeading + 180.0) / 360.0

				local blocked = 0
				local nn = 0

				local coords = GetOffsetFromEntityInWorldCoords(ped, (cosCamHeading * -0.2) - (sinCamHeading * (0.5 * camHeading + 0.3)), (sinCamHeading * -0.2) + (cosCamHeading * (0.5 * camHeading + 0.3)), 0.6)
				local ray = Cast_3dRayPointToPoint(coords.x, coords.y, coords.z - 0.2, coords.x, coords.y, coords.z + 0.2, 0.5, 95, ped, 7);
				nn,blocked,coords,coords = GetRaycastResult(ray)

				Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Pitch", camPitch)
				Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Heading", camHeading * -1.0 + 1.0)
				Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isBlocked", blocked)
				Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isFirstPerson", Citizen.InvokeNative(0xEE778F8C7E1142E2, Citizen.InvokeNative(0x19CAFA3C87F7C2FF)) == 4)

			end
		end
	end
end)
