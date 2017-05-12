RegisterNetEvent('medics:callMedics')
RegisterNetEvent('medics:emergencyCall')
RegisterNetEvent('medics:setMedicDashboard')
RegisterNetEvent('medics:newEmergencyWay')

isDev = true -- Set to false to unassign control key
isDie = 0
timerkoma = 10000 -- 600000 -- 10 minutes
timerDeath = 20000 -- 1200000 -- 20 minutes
inIntervention = false

function DisplayNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

function DrawMissionText(m_text, showtime)
    ClearPrints()
	SetTextEntry_2("STRING")
	AddTextComponentString(m_text)
	DrawSubtitleTimed(showtime, 1)
end

function PrintChatMessage(text)
  TriggerEvent('chatMessage', "system", { 255, 0, 0 }, text)
end

function printConsole(data)
  TriggerServerEvent('medics:printConsole', data)
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

AddEventHandler('medics:emergencyCall', function()
  PrintChatMessage("Nouvelle victime !")
  emergencyCallMenu()
  Menu.hidden = not Menu.hidden
end)

AddEventHandler('medics:newEmergencyWay',function(posX, posY, posZ, victimServerId)
  local blip1 = AddBlipForCoord(tonumber(posX), tonumber(posY), tonumber(posZ))
  SetBlipSprite(blip1, 61)
  SetBlipRoute(blip1, true)
  inIntervention = true
  victimPed = GetPlayerFromServerId(victimServerId)
end)

-- Show medics dashboard
AddEventHandler('medics:setMedicDashboard', function(victimes)
  SendNUIMessage({
    type = "medicDashboard",
    victimes = victimes
  })
end)

-- Death event trigger
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    playerPos = GetEntityCoords(GetPlayerPed(-1),  true)
    if IsEntityDead(GetPlayerPed(-1)) then
      DisplayNotification("Vous avez eu un accident, les secours sont prévenus.")
      isDie = true
      accidentTime = GetGameTimer()
      local komaNotif = false
      Citizen.Wait(1000)

      NetworkResurrectLocalPlayer(playerPos, true, true, false)
      ClearPedTasks(GetPlayerPed(-1))

    	LastPosX, LastPosY, LastPosZ = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
      PrintChatMessage("Mort ici ".. LastPosX ..  " " .. LastPosY .. " " .. LastPosZ)
      TriggerServerEvent("medics:playerDie", LastPosX , LastPosY , LastPosZ, accidentTime)

      while isDie do
        Citizen.Wait(0)
        deathSince = GetGameTimer() - accidentTime
        if deathSince > timerkoma and deathSince < timerDeath and not komaNotif then
          DisplayNotification("Vous entrez dans le coma")
          komaNotif = true
        end
        if deathSince > timerDeath then
          DisplayNotification("Vous êtes mort.")
          NetworkResurrectLocalPlayer(295.83, -1446.94, 29.97, true, true, false)
          isDie = false;
        end
        SetEntityHealth(GetPlayerPed(-1), 100)
        SetPedToRagdoll(GetPlayerPed(-1), 1000, 1000, 0, 0, 0, 0)
      end
    end
  end
end)

-- render emergencyCallMenu
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    Menu.renderGUI()
  end
end)

-- inIntervention trigger
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    if (inIntervention and DoesEntityExist(victimPed)) then
      if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), GetEntityCoords(victimPed), true) < 30.0001 then
        DrawMissionText("peu rez", 1000)
      else
        DrawMissionText("En intervention", 1000)
      end
    end
  end
end)

-- Control trigger, Only for dev
Citizen.CreateThread(function()
	while isDev do
		Citizen.Wait(0)
		if IsControlJustPressed(1,Keys["F3"]) then
			-- Request victim list.
      -- TriggerServerEvent("medics:getMedicDashboard")
      initMedicsMission()
		end
    if IsControlJustPressed(1,Keys["F2"]) then
			isDie = false
      SetEntityHealth(GetPlayerPed(-1), 200)
		end
    if IsControlJustPressed(1,Keys["F1"]) then
			SetEntityHealth(GetPlayerPed(-1), 99)
		end
	end
end)
