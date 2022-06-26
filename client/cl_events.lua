-- ESX Core (Dont Touch)
ESX              = nil
local PlayerData = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

  	PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

-- Disable Controller Aim Assist
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        letSleep = true
        if IsPedArmed(PlayerPedId(), 4) then
            letSleep = false
            SetPlayerLockonRangeOverride(PlayerPedId(), 2.0)
        end
        if letSleep then
            Wait(500)
        end
    end
end)

-- Disable Local Police (AI Cops)
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local Player = GetEntityCoords(PlayerPedId())

		ClearAreaOfCops(Player.x, Player.y, Player.z, 200.0)

		Citizen.Wait(300)
	end
end)

-- Disable GTA Dispatch
Citizen.CreateThread(function()
    while true do
		Citizen.Wait(0)
        DistantCopCarSirens(false)
        Citizen.Wait(400)
    end
end)

Citizen.CreateThread(function()
    SetCreateRandomCops(false)
    SetCreateRandomCopsNotOnScenarios(false)
    SetCreateRandomCopsOnScenarios(false)
    SetScenarioTypeEnabled("WORLD_HUMAN_COP_IDLES", false)
    SetScenarioTypeEnabled("WORLD_VEHICLE_POLICE_BIKE", false)
    SetScenarioTypeEnabled("WORLD_VEHICLE_POLICE_CAR", false)
    SetScenarioTypeEnabled("WORLD_VEHICLE_POLICE_NEXT_TO_CAR", false)
    SetScenarioTypeEnabled("CODE_HUMAN_POLICE_CROWD_CONTROL", false)
    SetScenarioTypeEnabled("CODE_HUMAN_POLICE_INVESTIGATE", false)
    SetScenarioTypeEnabled("WORLD_VEHICLE_AMBULANCE", false)
    SetScenarioTypeEnabled("WORLD_VEHICLE_FIRE_TRUCK", false)
end)

Citizen.CreateThread(function()
    for dispatchService=1, 25 do
        EnableDispatchService(dispatchService, false)
        Citizen.Wait(1)
    end
end)

-- Disable Vehicle Rewards
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local Player = PlayerPedId()
		DisablePlayerVehicleRewards(Player)	
	end
end)

-- Disable Gun Drops
function RemoveWeaponDrops()
    local pickupList = {}
    for a = 1, #pickupList do
        N_0x616093ec6b139dd9(PlayerPedId(), GetHashKey(pickupList[a]), false)
    end
end

Citizen.CreateThread(function()     
    RemoveWeaponDrops()
end)

-- Disable Weapon Pickups
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		RemoveAllPickupsOfType(GetHashKey('PICKUP_WEAPON_CARBINERIFLE'))
		RemoveAllPickupsOfType(GetHashKey('PICKUP_WEAPON_PISTOL'))
		RemoveAllPickupsOfType(GetHashKey('PICKUP_WEAPON_PUMPSHOTGUN'))
	end
end)

-- Binoculars
local fov_max = 70.0
local fov_min = 5.0
local zoomspeed = 10.0
local speed_lr = 8.0
local speed_ud = 8.0
local binoculars = false
local fov = (fov_max+fov_min)*0.5

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = GetPlayerPed(-1)
		local vehicle = GetVehiclePedIsIn(playerPed)

		if binoculars then
			binoculars = true
			if not (IsPedSittingInAnyVehicle(playerPed)) then
				Citizen.CreateThread(function()
					TaskStartScenarioInPlace(GetPlayerPed(-1), 'WORLD_HUMAN_BINOCULARS', 0, 1)
					PlayAmbientSpeech1(GetPlayerPed(-1), 'GENERIC_CURSE_MED', 'SPEECH_PARAMS_FORCE')
				end)
			end

			Wait(2000)

			SetTimecycleModifier('default')
			SetTimecycleModifierStrength(0.3)

			local scaleform = RequestScaleformMovie('BINOCULARS')

			while not HasScaleformMovieLoaded(scaleform) do
				Citizen.Wait(10)
			end

			local playerPed = GetPlayerPed(-1)
			local vehicle = GetVehiclePedIsIn(playerPed)
			local cam = CreateCam('DEFAULT_SCRIPTED_FLY_CAMERA', true)

			AttachCamToEntity(cam, playerPed, 0.0,0.0,1.0, true)
			SetCamRot(cam, 0.0,0.0,GetEntityHeading(playerPed))
			SetCamFov(cam, fov)
			RenderScriptCams(true, false, 0, 1, 0)
			PushScaleformMovieFunction(scaleform, 'SET_CAM_LOGO')
			PushScaleformMovieFunctionParameterInt(0) -- 0 for nothing, 1 for LSPD logo
			PopScaleformMovieFunctionVoid()

			while binoculars and not IsEntityDead(playerPed) and (GetVehiclePedIsIn(playerPed) == vehicle) and true do
				if IsControlJustPressed(0, 177) then -- Toggle binoculars
					PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
					ClearPedTasks(GetPlayerPed(-1))
					binoculars = false
				end

				local zoomvalue = (1.0/(fov_max-fov_min))*(fov-fov_min)
				CheckInputRotation(cam, zoomvalue)

				HandleZoom(cam)
				HideHUDThisFrame()

				DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
				Citizen.Wait(5)
			end

			binoculars = false
			ClearTimecycleModifier()
			fov = (fov_max+fov_min)*0.5
			RenderScriptCams(false, false, 0, 1, 0)
			SetScaleformMovieAsNoLongerNeeded(scaleform)
			DestroyCam(cam, false)
			SetNightvision(false)
			SetSeethrough(false)
		end
	end
end)

RegisterNetEvent('ZokuCore:binoculars')
AddEventHandler('ZokuCore:binoculars', function()
	binoculars = not binoculars
end)

function HideHUDThisFrame()
	HideHelpTextThisFrame()
	HideHudAndRadarThisFrame()
	HideHudComponentThisFrame(1) -- Wanted Stars
	HideHudComponentThisFrame(2) -- Weapon icon
	HideHudComponentThisFrame(3) -- Cash
	HideHudComponentThisFrame(4) -- MP CASH
	HideHudComponentThisFrame(6)
	HideHudComponentThisFrame(7)
	HideHudComponentThisFrame(8)
	HideHudComponentThisFrame(9)
	HideHudComponentThisFrame(13) -- Cash Change
	HideHudComponentThisFrame(11) -- Floating Help Text
	HideHudComponentThisFrame(12) -- more floating help text
	HideHudComponentThisFrame(15) -- Subtitle Text
	HideHudComponentThisFrame(18) -- Game Stream
	HideHudComponentThisFrame(19) -- weapon wheel
end

function CheckInputRotation(cam, zoomvalue)
	local rightAxisX = GetDisabledControlNormal(0, 220)
	local rightAxisY = GetDisabledControlNormal(0, 221)
	local rotation = GetCamRot(cam, 2)

	if rightAxisX ~= 0.0 or rightAxisY ~= 0.0 then
		new_z = rotation.z + rightAxisX*-1.0*(speed_ud)*(zoomvalue+0.1)
		new_x = math.max(math.min(20.0, rotation.x + rightAxisY*-1.0*(speed_lr)*(zoomvalue+0.1)), -89.5)
		SetCamRot(cam, new_x, 0.0, new_z, 2)
	end
end

function HandleZoom(cam)
	local playerPed = GetPlayerPed(-1)

	if not (IsPedSittingInAnyVehicle(playerPed)) then
		if IsControlJustPressed(0,241) then -- Scrollup
			fov = math.max(fov - zoomspeed, fov_min)
		end

		if IsControlJustPressed(0,242) then
			fov = math.min(fov + zoomspeed, fov_max) -- ScrollDown
		end

		local current_fov = GetCamFov(cam)
		if math.abs(fov-current_fov) < 0.1 then
			fov = current_fov
		end

		SetCamFov(cam, current_fov + (fov - current_fov)*0.05)
	else
		if IsControlJustPressed(0,17) then -- Scrollup
			fov = math.max(fov - zoomspeed, fov_min)
		end

		if IsControlJustPressed(0,16) then
			fov = math.min(fov + zoomspeed, fov_max) -- ScrollDown
		end

		local current_fov = GetCamFov(cam)

		if math.abs(fov-current_fov) < 0.1 then -- the difference is too small, just set the value directly to avoid unneeded updates to FOV of order 10^-5
			fov = current_fov
		end

		SetCamFov(cam, current_fov + (fov - current_fov)*0.05) -- Smoothing of camera zoom
	end
end

-- Disable Motorcycle Helmet
Citizen.CreateThread( function()
    while true do
		Citizen.Wait(0)
        SetPedConfigFlag(PlayerPedId(), 35, false)
    end
end)

-- Unflip Car Command
RegisterCommand("unflip", function()
    TriggerEvent('ZokuCore:flipcheck')
end, false)

RegisterNetEvent('ZokuCore:flipcheck')
AddEventHandler('ZokuCore:flipcheck', function()
	local playerPed = GetPlayerPed(-1)
	local coords = GetEntityCoords(playerPed)
	local vehicle = ESX.Game.GetVehicleInDirection()
	local sleep = 1000

	if IsPedSittingInAnyVehicle(playerPed) then
		exports['mythic_notify']:DoHudText('error', 'Unable to flip the vehicle!')
	else
		if DoesEntityExist(vehicle) and IsPedOnFoot(playerPed) then
			TriggerEvent('ZokuCore:unflip')
		end
	end
	Citizen.Wait(sleep)
end)

RegisterNetEvent('ZokuCore:unflip')
AddEventHandler('ZokuCore:unflip', function()
	local playerPed = GetPlayerPed(-1)
	local coords = GetEntityCoords(playerPed)
	local vehicle = ESX.Game.GetVehicleInDirection()

	if IsPedSittingInAnyVehicle(playerPed) then
		exports['mythic_notify']:DoHudText('error', 'Unable to flip the vehicle!')
	else
		if DoesEntityExist(vehicle) and IsPedOnFoot(playerPed) then
			TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)
			TriggerEvent("mythic_progbar:client:progress", {
				name = "progbar",
				duration = 15000,
				label = "Flipping...",
				useWhileDead = false,
				canCancel = false,
				controlDisables = {
					disableMovement = true,
					disableCarMovement = true,
					disableMouse = false,
					disableCombat = true,
				}
			}, function(status)
				if not status then
					-- Do Something If Event Wasn't Cancelled
				end
			end)
			Citizen.CreateThread(function()
				Citizen.Wait(Config.Wait.Flip)
				VehicleData = ESX.Game.GetClosestVehicle()
				local dist = #(coords - GetEntityCoords(VehicleData))
				local carCoords = GetEntityRotation(VehicleData, 2)
				SetEntityRotation(VehicleData, carCoords[1], 0, carCoords[3], 2, true)
				SetVehicleOnGroundProperly(VehicleData)
				ClearPedTasksImmediately(playerPed)
			end)
		else
			exports['mythic_notify']:DoHudText('error', 'There is no vehicle(s) nearby!')
		end
	end
end)

-- Disable Police Radio Chatter
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		SetAudioFlag("PoliceScannerDisabled", true)
		SetAudioFlag("DisableFlightMusic", true)
	end
end)

-- O2 Tank
local oxygenMask = false

RegisterNetEvent('ZokuCore:oxygentank')
AddEventHandler('ZokuCore:oxygentank', function()
	local playerPed = GetPlayerPed(-1)
	local coords = GetEntityCoords(playerPed)
	local boneIndex = GetPedBoneIndex(playerPed, 12844)
	local boneIndex2 = GetPedBoneIndex(playerPed, 24818)

	if not oxygenMask then
		TriggerServerEvent('ZokuCore:removeoxygentank')
		oxygenMask = true
		ExecuteCommand("e adjusttie")
		TriggerEvent("mythic_progbar:client:progress", {
			name = "progbar",
			duration = 5000,
			label = "Masking up...",
			useWhileDead = false,
			canCancel = false,
			controlDisables = {
				disableMovement = false,
				disableCarMovement = false,
				disableMouse = false,
				disableCombat = true,
			}
		}, function(status)
			if not status then
				-- Do Something If Event Wasn't Cancelled
			end
		end)
		Citizen.Wait(5000)
		ESX.Game.SpawnObject('p_s_scuba_mask_s', {
			x = coords.x,
			y = coords.y,
			z = coords.z - 3
		}, function(object)
			ESX.Game.SpawnObject('p_s_scuba_tank_s', {
				x = coords.x,
				y = coords.y,
				z = coords.z - 3
			}, function(object2)
				AttachEntityToEntity(object2, playerPed, boneIndex2, -0.30, -0.22, 0.0, 0.0, 90.0, 180.0, true, true, false, true, 1, true)
				AttachEntityToEntity(object, playerPed, boneIndex, 0.0, 0.0, 0.0, 0.0, 90.0, 180.0, true, true, false, true, 1, true)
				SetPedDiesInWater(playerPed, false)

				exports['mythic_notify']:DoHudText('success', 'You put on the diving mask & secure the oxygen tank! Oxygen level 100%')

				Citizen.Wait(Config.O2Tank.Phase1 * 60000)
				exports['mythic_notify']:DoHudText('success', 'Your oxygen tank has 75% left!')

				Citizen.Wait(Config.O2Tank.Phase2 * 60000)
				exports['mythic_notify']:DoHudText('success', 'Your oxygen tank has 50% left!')

				Citizen.Wait(Config.O2Tank.Phase3 * 60000)
				exports['mythic_notify']:DoHudText('error', 'Your oxygen tank has 25% left!')

				Citizen.Wait(Config.O2Tank.Phase4 * 60000)
				exports['mythic_notify']:DoHudText('error', 'Your oxygen tank has 0% left!')

				SetPedDiesInWater(playerPed, true)
				DeleteObject(object)
				DeleteObject(object2)
				ClearPedSecondaryTask(playerPed)
				oxygenMask = false
			end)
		end)
	else
		exports['mythic_notify']:DoHudText('error', 'You are already wearing an oxygen tank!')
	end
end)