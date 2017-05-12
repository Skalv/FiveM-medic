--Version 1.4
require "resources/essentialmode/lib/MySQL"

--Configuration de la connexion vers la DB MySQL
MySQL:open("127.0.0.1", "fivem", "root", "")

RegisterServerEvent("es:chatMessage")
RegisterServerEvent("medics:playerDie")
RegisterServerEvent("medics:getMedicDashboard")
RegisterServerEvent("medics:newIntervention")
RegisterServerEvent("medics:printConsole")

AddEventHandler('medics:printConsole', function(data)
  print("from client :", data)
end)

AddEventHandler('medics:playerDie', function(LastPosX , LastPosY , LastPosZ , accidentTime)
  TriggerEvent('es:getPlayerFromId', source, function(user)
		local player = user.identifier
    local LastPos = "{" .. LastPosX .. ", " .. LastPosY .. ",  " .. LastPosZ .. "}"
    local executed_query = MySQL:executeQuery("INSERT INTO medic (`victimPos`, `victimId`, `victimServerId`, `accidentTime`) VALUES ('@victimPos', '@victimId', '@victimServerId', '@accidentTime')",
    {['@victimPos'] = LastPos, ['@victimId'] = player, ['@victimServerId'] = source, ['@accidentTime'] = accidentTime})

    TriggerClientEvent('medics:emergencyCall', -1)
  end)
end)

AddEventHandler('medics:newIntervention', function()
  TriggerEvent('es:getPlayerFromId', source, function(user)
    local medicId = user.identifier
    local query = MySQL:executeQuery("SELECT * FROM medic WHERE victimState = 'waiting' ORDER BY accidentTime LIMIT 1")
    local result = MySQL:getResults(query, {'id', 'victimPos', 'victimServerId', 'accidentTime'}, "id")
    if (result and result[1]) then
      for k,v in ipairs(result) do
        local missionID = v.id
        MySQL:executeQuery("UPDATE medic SET victimState = 'rescued', medicId = '@medicId', medicServerId = '@medicServerId' WHERE id = '@id'", {["@id"] = missionID, ["@medicId"] = medicId, ["@medicServerId"] = source})
        local victimPos = json.decode(v.victimPos)
        TriggerClientEvent("medics:newEmergencyWay", source, victimPos[1], victimPos[2], victimPos[3], v.victimServerId)
      end
    end
  end)
end)

AddEventHandler('medics:getMedicDashboard', function()
  local query = MySQL:executeQuery("SELECT * FROM medic WHERE victimState = 'waiting'")
  local result = MySQL:getResults(query, {'id', 'victimPos', 'victimId', 'victimState'}, "id")
  local victimes = {}
  if (result and result[1]) then
    for k,v in ipairs(result) do
      table.insert(victimes, v)
      posDecoded = json.decode(victimes[k].victimPos)
      victimes[k].victimPosX = posDecoded[1]
      victimes[k].victimPosY = posDecoded[2]
      victimes[k].victimPosZ = posDecoded[3]
    end
     print(victimes)
    TriggerClientEvent('medics:setMedicDashboard', source, victimes)
  end
end)
