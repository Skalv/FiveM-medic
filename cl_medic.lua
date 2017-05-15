local isDev = true -- Set to false to unassign control key
local isMedic = nil

local inIntervention = false
local inJob = false

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
  for i = 1, #victimPos do
    local ply = GetPlayerPed(-1)
    local plyCoords = GetEntityCoords(ply, 0)
    local distance = GetDistanceBetweenCoords(victimPos[i].x, victimPos[i].y, victimPos[i].z, plyCoords["x"], plyCoords["y"], plyCoords["z"], true)
    if (distance < 3) then
      return true
    end
  end
end

function initWay(x, y, z)
	SetNewWaypoint(x, y)
end

function initMedicsMission()
  if not isDev then
    Menu.hidden = not Menu.hidden
  end
  TriggerServerEvent('medics:newIntervention')
end

function refuseMedicsMission()
  drawNotification("~r~Mission refusée")
  Menu.hidden = not Menu.hidden
end

function emergencyCallMenu()
  ClearMenu()
  Menu.addTitle("Nouvelle victime !")
  Menu.addButton("Y aller","initMedicsMission",nil)
	Menu.addButton("Osef","refuseMedicsMission",nil)
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
  local victimSID = victimSId
  local itsMeTheVictim = false
  if (playerSId == victimSID) then itsMeTheVictim = true end

  if isMedic and inJob and not itsMeTheVictim and not inIntervention then
    local callTaken = false

    DisplayNotification("Nouvelle victime ! Appuyer sur ~g~E~w~ pour la prendre en charge")
    -- Wait medics take call
    Citizen.CreateThread(function()
      while (not callTaken) do
        Citizen.Wait(1)
        -- I take the call
        if IsControlJustPressed(1,Keys["E"]) then
          TriggerServerEvent("medics:takeCall", victimId, playerSId)
        end
        -- When call is taken by me or other
        RegisterServerEvent("medics:callTaken")
        AddEventHandler("medics:callTaken", function(victimPosX, victimPosY, victimPosZ, victimSid, medicSId)
          callTaken = true
          if (playerSId == medicSId) then
            DisplayNotification("Le lieu de l'accident à été transféré à votre GPS")
            local blip1 = AddBlipForCoord(tonumber(victimPosX), tonumber(victimPosY), tonumber(victimPosZ))
            SetBlipSprite(blip1, 61)
            SetBlipRoute(blip1, true)
            inIntervention = true
            victimPos = {
              {x=victimPosX, y=victimPosY, z=victimPosZ}
            }
          else
            DisplayNotification("Victime prise en charge par un autre ambulancier")
          end
        end)
      end
    end)
  end

    -- if IsPedSittingInAnyVehicle(GetPlayerPed(-1)) and IsVehicleModel(GetVehiclePedIsUsing(GetPlayerPed(-1)), GetHashKey("ambulance", _r)) then
    --   emergencyCallMenu()
    --   Menu.hidden = not Menu.hidden
    -- else
    --   PrintChatMessage("vous devez être dans une ambulance !")
    -- end
end)

-- render emergencyCallMenu
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    Menu.renderGUI()
  end
end)

-- Medic thread
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    -- Job takker
    if (isMedic and isNearTakeService()) then
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
    if (inJob and isMedic and isNearMedicGarage()) then
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

    if (inIntervention and isNearVictim()) then
      drawTxt("Appuyer sur ~g~E~s~ pour soigner la victime.",0,1,0.5,0.8,0.6,255,255,255,255)
    end
  end
end)

-- Control trigger, Only for dev
Citizen.CreateThread(function()
	while isDev do
		Citizen.Wait(0)
    if IsControlJustPressed(1,Keys["F1"]) then
			SetEntityHealth(GetPlayerPed(-1), 99)
		end
    if IsControlJustPressed(1,Keys["F3"]) then
      -- local pos = GetEntityCoords(GetPlayerPed(-1))
      -- PrintChatMessage(pos.x .. " " .. pos.y .. " " .. pos.z)
      isMedic = not isMedic
      if isMedic then
        DisplayNotification("Vous êtes Ambulancier")
      else
        DisplayNotification("Vous n'êtes plus Ambulancier")
      end
    end
	end
end)
