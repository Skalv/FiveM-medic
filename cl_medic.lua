local isDev = true -- Set to false to unassign control key
local isMedic = nil

local inIntervention = false
local inJob = false

local callTaken = false

local medicGarage = {
  {x=-491.044, y=-342.608, z=34.366}
}
local takingService = {
  {x=-496.176, y=-329.616, z=34.501}
}
local victimPos = {}

function isNearMedicGarage()
	for i = 1, #medicGarage do
		local ply = GetPlayerPed(-1)
		local plyCoords = GetEntityCoords(ply, 0)
		local distance = GetDistanceBetweenCoords(medicGarage[i].x, medicGarage[i].y, medicGarage[i].z, plyCoords["x"], plyCoords["y"], plyCoords["z"], true)
		if(distance < 30) then
			DrawMarker(1, medicGarage[i].x, medicGarage[i].y, medicGarage[i].z-1, 0, 0, 0, 0, 0, 0, 2.0, 2.0, 1.5, 0, 0, 255, 155, 0, 0, 2, 0, 0, 0, 0)
		end
		if(distance < 2) then
			return true
		end
	end
end

function isNearTakeService()
	for i = 1, #takingService do
		local ply = GetPlayerPed(-1)
		local plyCoords = GetEntityCoords(ply, 0)
		local distance = GetDistanceBetweenCoords(takingService[i].x, takingService[i].y, takingService[i].z, plyCoords["x"], plyCoords["y"], plyCoords["z"], true)
		if(distance < 30) then
			DrawMarker(1, takingService[i].x, takingService[i].y, takingService[i].z-1, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.5, 0, 0, 255, 155, 0, 0, 2, 0, 0, 0, 0)
		end
		if(distance < 2) then
			return true
		end
	end
end

function isNearVictim()
    local ply = GetPlayerPed(-1)
    local plyCoords = GetEntityCoords(ply, 0)
    local distance = GetDistanceBetweenCoords(victimPos.x, victimPos.y, victimPos.z, plyCoords["x"], plyCoords["y"], plyCoords["z"], true)
    if (distance < 3) then
      return true
    end
end

function spawnAmbulance()
  local car = GetHashKey("ambulance");
  RequestModel(car)
  while not HasModelLoaded(car) do
    Citizen.Wait(0)
  end
  veh = CreateVehicle(car, -491.044, -342.608, 34.366, -90.0, true, false)
  SetVehicleOnGroundProperly(veh)
  SetEntityInvincible(veh, false)
end

function initNewIntervention(victimPosX, victimPosY, victimPosZ, victimSid)
  DisplayNotification("Le lieu de l'accident à été transféré à votre GPS")
  local blip1 = AddBlipForCoord(tonumber(victimPosX), tonumber(victimPosY), tonumber(victimPosZ))
  printConsole(blip1)
  SetBlipSprite(blip1, 61)
  SetBlipRoute(blip1, true)
  inIntervention = true
  victimPos = {
    x=victimPosX,
    y=victimPosY,
    z=victimPosZ,
    sid=victimSid,
    blip=blip1
  }
end

-- Check if player is medic
AddEventHandler('playerSpawned', function(spawn)
  TriggerServerEvent("medics:isMedic")

	Citizen.CreateThread(function()
		while isMedic == nil do
			Citizen.Wait(1)
			RegisterNetEvent('medics:setPlayerMedic')
			AddEventHandler('medics:setPlayerMedic', function(medic)
        isMedic = medic
			end)
		end
  end)
end)

-- Quand on reçoit un appel d'urgence
RegisterNetEvent('medics:emergencyCall')
AddEventHandler('medics:emergencyCall', function(victimSId, victimId)
  local playerSId = GetPlayerServerId(PlayerId())
  local callAt = GetGameTimer()
  local itsMeTheVictim = false
  if (playerSId == victimSId) then itsMeTheVictim = true end

  if isMedic and inJob and not inIntervention and not itsMeTheVictim then
    DisplayNotification("Nouvelle victime ! Appuyer sur ~g~Y~w~ pour la prendre en charge")
    -- Wait medics take call
    Citizen.CreateThread(function()
      callTaken = false
      local playerSId = GetPlayerServerId(PlayerId())

      while not callTaken do
        Citizen.Wait(1)
        if GetTimeDifference(GetGameTimer(), callAt) > 15000 then
          callTaken = true -- call Expires
          DisplayNotification("Vous n'avez pas répondu à l'intervention")
          TriggerServerEvent("medics:callExpires", victimId, victimSId)
        end
        -- I take the call
        if IsControlJustPressed(1,Keys["Y"]) then
          callTaken = true
          TriggerServerEvent("medics:takeCall", victimId)
        end
      end
    end)
  end
end)

-- When call is taken by me or other
RegisterNetEvent("medics:callTaken")
AddEventHandler("medics:callTaken", function(victimPosX, victimPosY, victimPosZ, victimSid, medicSId)
  local playerSId = GetPlayerServerId(PlayerId())
  callTaken = true
  if (playerSId == medicSId) then
    initNewIntervention(victimPosX, victimPosY, victimPosZ, victimSid)
  else
    DisplayNotification("Victime prise en charge par un autre ambulancier")
  end
end)

-- Medic thread
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    -- Job takker
    if isMedic and isNearTakeService() then
			if(inJob) then
				drawTxt("Appuyer sur ~g~E~s~ pour terminer votre service.",0,1,0.5,0.8,0.6,255,255,255,255)
			else
				drawTxt("Appuyer sur ~g~E~s~ pour prendre votre service.",0,1,0.5,0.8,0.6,255,255,255,255)
			end
			if IsControlJustPressed(1, 38)  then
				inJob = not inJob
				if(inJob) then
          SetPedComponentVariation(GetPlayerPed(-1), 11, 13, 3, 2)
        	SetPedComponentVariation(GetPlayerPed(-1), 8, 15, 0, 2)
        	SetPedComponentVariation(GetPlayerPed(-1), 4, 9, 3, 2)
        	SetPedComponentVariation(GetPlayerPed(-1), 3, 92, 0, 2)
        	SetPedComponentVariation(GetPlayerPed(-1), 6, 25, 0, 2)

          TriggerServerEvent("medics:inJob", 1)
				else
					local playerPed = GetPlayerPed(-1)

					TriggerServerEvent("skin_customization:SpawnPlayer")
					RemoveAllPedWeapons(playerPed)

          TriggerServerEvent("medics:inJob", 0)
				end
			end
    end
    -- Spawn Ambulance
    if inJob and isMedic and isNearMedicGarage() then
      if(existingVeh ~= nil) then
        drawTxt("Appyyez sur ~g~E~s~ pour rentrer l'ambulance.",0,1,0.5,0.8,0.6,255,255,255,255)
      else
        drawTxt("Appuyez sur ~g~E~s~ pour sortir une ambulance.",0,1,0.5,0.8,0.6,255,255,255,255)
      end

      if IsControlJustPressed(1, 38)  then
        if(existingVeh ~= nil) then
          SetEntityAsMissionEntity(existingVeh, true, true)
          Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(existingVeh))
          existingVeh = nil
        else
          local car = GetHashKey("ambulance")
          local ply = GetPlayerPed(-1)
          local plyCoords = GetEntityCoords(ply, 0)

          RequestModel(car)
          while not HasModelLoaded(car) do
            Citizen.Wait(0)
          end

          existingVeh = CreateVehicle(car, plyCoords["x"], plyCoords["y"], plyCoords["z"], -90.0, true, false)
          local id = NetworkGetNetworkIdFromEntity(existingVeh)
          SetNetworkIdCanMigrate(id, true)
          TaskWarpPedIntoVehicle(ply, existingVeh, -1)
        end
      end
    end
    -- Rez player when is near
    local inVehicle = IsPedSittingInAnyVehicle(GetPlayerPed(-1))
    if inIntervention and isNearVictim() and not inVehicle then
      drawTxt("Appuyer sur ~g~E~s~ pour soigner la victime.",0,1,0.5,0.8,0.6,255,255,255,255)
      if (IsControlJustReleased(1, Keys['E'])) then
        TaskStartScenarioInPlace(GetPlayerPed(-1), 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
        Citizen.Wait(8000)
        ClearPedTasks(GetPlayerPed(-1));
        TriggerServerEvent('medics:resPlayer', victimPos.sid)
        DisplayNotification("Victime sauvée !")
        RemoveBlip(victimPos.blip)
        victimPos = {}
        inIntervention = false
      end
    end
  end
end)

-- Memo
-- IsPedSittingInAnyVehicle(GetPlayerPed(-1))
-- IsVehicleModel(GetVehiclePedIsUsing(GetPlayerPed(-1)), GetHashKey("ambulance", _r))
