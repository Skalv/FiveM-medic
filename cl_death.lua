local isDead = false
local isKO = false
local isRes = false

function OnPlayerDied(playerId)
	local pos = GetEntityCoords(GetPlayerPed(-1))
  local dieAt = GetGameTimer()
	local isDocConnected = nil
  isRes = false

	TriggerServerEvent('medics:getMedicConnected')

	Citizen.CreateThread(function()
		while isDocConnected == nil do
			Citizen.Wait(1)

			RegisterNetEvent('medics:MedicConnected')
			AddEventHandler('medics:MedicConnected',function(docConnected)
        isDocConnected = docConnected
				if isDocConnected then
					DisplayNotification('Appuyez sur ~g~E~s~ pour appeler une ambulance')
				end
			end)
		end
  end)

	DisplayNotification('Appuyez sur ~r~X~s~ pour respawn')
	TriggerEvent('es_em:playerInComa')

	Citizen.CreateThread(function()
		local emergencyCalled = false
		while not isRes do
			Citizen.Wait(1)
			if IsControlJustReleased(1, Keys['E']) and not emergencyCalled then
				if not isDocConnected then
					ResPlayer()
				else
          DisplayNotification("Ambulance appelée !")
					TriggerServerEvent('medics:callAmb', pos.x, pos.y, pos.z, dieAt, GetPlayerServerId(PlayerId()))
				end

				emergencyCalled = true
			elseif IsControlJustReleased(1, Keys['X']) then
				ResPlayer()
			end
		end
	end)
end

function SetPlayerKO(playerID, playerPed)
  isKO = true
  SendNotification(txt[lang]['ko'])
  SetPedToRagdoll(playerPed, 6000, 6000, 0, 0, 0, 0)
end

function ResPlayer()
	isRes = true
	-- TriggerServerEvent('es_em:sv_removeMoney')
	-- TriggerServerEvent("item:reset")
	NetworkResurrectLocalPlayer(-449.985, -341.048, 34.5017, true, true, false)
end

-- Triggered when player died by environment
AddEventHandler('baseevents:onPlayerDied', function(playerId, reasonID)
  local reason = 'Un accident s\'est produit'
	OnPlayerDied(playerId, reasonID, reason)
end)

-- Triggered when player died by an another player
AddEventHandler('baseevents:onPlayerKilled', function(playerId, playerKill, reasonID)
  local reason = 'Tentative de meurtre'
	OnPlayerDied(playerId, reasonID, reason)
end)

RegisterNetEvent('medics:resYou')
AddEventHandler('medics:resYou', function()
	isRes = true
	DisplayNotification('Vous avez été réanimé')
	local playerPed = GetPlayerPed(-1)
	ResurrectPed(playerPed)
	SetEntityHealth(playerPed, GetPedMaxHealth(playerPed)/2)
	ClearPedTasksImmediately(playerPed)
end)

RegisterNetEvent('medics:expire')
AddEventHandler('medics:expire', function()
	DisplayNotification("Aucun médecin n'a répondu à votre appel")
	ResPlayer()
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(1)
    local playerPed = GetPlayerPed(-1)
    local playerID = PlayerId()
    local currentPos = GetEntityCoords(playerPed, true)
    local previousPos

    isDead = IsEntityDead(playerPed)

    if isKO and previousPos ~= currentPos then
      isKO = false
    end

    if (GetEntityHealth(playerPed) < 120 and not isDead and not isKO) then
      if (IsPedInMeleeCombat(playerPed)) then
        SetPlayerKO(playerID, playerPed)
      end
    end

    previousPos = currentPos

    if IsControlJustReleased(1, Keys['F9']) then
      ResPlayer()
    end
  end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
  	if IsEntityDead(PlayerPedId()) then
			StartScreenEffect("DeathFailOut", 0, 0)
			ShakeGameplayCam("DEATH_FAIL_IN_EFFECT_SHAKE", 1.0)

			local scaleform = RequestScaleformMovie("MP_BIG_MESSAGE_FREEMODE")

			if HasScaleformMovieLoaded(scaleform) then
				Citizen.Wait(0)

				PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
				BeginTextComponent("STRING")
				AddTextComponentString("~r~Vous êtes dans le coma")
				EndTextComponent()
				PopScaleformMovieFunctionVoid()

		  	Citizen.Wait(500)

		    while IsEntityDead(PlayerPedId()) do
					DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
			 		Citizen.Wait(0)
		    end

		  	StopScreenEffect("DeathFailOut")
			end
		end
	end
end)
