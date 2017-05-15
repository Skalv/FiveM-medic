-- Check if player is medic or not
RegisterServerEvent("medics:isMedic")
AddEventHandler('medics:isMedic', function()
  TriggerEvent('es:getPlayerFromId', source, function(user)
    local isMedic = false
    local executed_query = MySQL:executeQuery("SELECT * FROM users LEFT JOIN jobs ON jobs.job_id = users.job WHERE identifier = '@identifier' AND jobs.job_name = 'Ambulancier'", {['@identifier'] = user.identifier})
    local result = MySQL:getResults(executed_query, {'job'}, "identifier")
    if (result[1] ~= nil) then
      isMedic = true
    end
    TriggerClientEvent('medics:setPlayerMedic', source, isMedic)
  end)
end)

-- Check medic is in service
RegisterServerEvent("medics:inJob")
AddEventHandler("medics:inJob", function(inJob)
  TriggerEvent('es:getPlayerFromId', source, function(user)
    local player = user.identifier
    local query = MySQL:executeQuery("UPDATE users SET inJob = '@inJob' WHERE identifier = '@identifier'",
    {['@identifier'] = player, ['@inJob'] = inJob})
  end)
end)
-- When player call ambulance
RegisterServerEvent("medics:callAmb")
AddEventHandler('medics:callAmb', function(LastPosX , LastPosY , LastPosZ , accidentTime, playerSID)
  TriggerEvent('es:getPlayerFromId', source, function(user)
		local player = user.identifier
    local LastPos = "{" .. LastPosX .. ", " .. LastPosY .. ",  " .. LastPosZ .. "}"
    local executed_query = MySQL:executeQuery("INSERT INTO medic (`victimPos`, `victimId`, `victimServerId`, `accidentTime`) VALUES ('@victimPos', '@victimId', '@victimServerId', '@accidentTime')",
    {['@victimPos'] = LastPos, ['@victimId'] = player, ['@victimServerId'] = source, ['@accidentTime'] = accidentTime})

    TriggerClientEvent('medics:emergencyCall', -1, playerSID, player)
  end)
end)
-- When medic take a call
RegisterServerEvent("medics:takeCall")
AddEventHandler("medics:takeCall", function(victimId)
  TriggerEvent("es:getPlayerFromId", source, function(medic)
    local medicId = medic.identifier
    local medicSId = source

    local query = MySQL:executeQuery("SELECT * FROM medic WHERE victimId = '@victimId'",
    {['@victimId'] = victimId})
    local result = MySQL:getResults(query, {'id', 'victimPos', 'victimServerId', 'accidentTime'}, "id")
    if (result and result[1]) then
      for k,v in ipairs(result) do
        local missionID = v.id
        MySQL:executeQuery("UPDATE medic SET victimState = 'rescued', medicId = '@medicId', medicServerId = '@medicServerId' WHERE id = '@id'",
        {["@id"] = missionID, ["@medicId"] = medicId, ["@medicServerId"] = medicSId})
        local victimPos = json.decode(v.victimPos)

        TriggerClientEvent("medics:callTaken", source, victimPos[1], victimPos[2], victimPos[3], v.victimServerId, medicSId)
      end
    end
  end)
end)

RegisterServerEvent("medics:newIntervention")
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

-- Return if medic are connected
RegisterServerEvent("medics:getMedicConnected")
AddEventHandler('medics:getMedicConnected', function()
  TriggerEvent("es:getPlayers", function(players)
    local identifier
    local table = {}
    local isConnected = false

    for i,v in pairs(players) do
      identifier = GetPlayerIdentifiers(i)
      if (identifier ~= nil) then
        local query = MySQL:executeQuery("SELECT identifier, job_id, job_name FROM users LEFT JOIN jobs ON jobs.job_id = users.job WHERE users.identifier = '@identifier' AND job_name = 'Ambulancier' AND users.inJob = 1",
        {['@identifier'] = identifier[1]})
        local result = MySQL:getResults(query, {'job_id'}, "identifier")

        if (result[1] ~= nil) then
          isConnected = true
        end
      end
    end
    TriggerClientEvent('medics:MedicConnected', source, isConnected)
  end)
end)
