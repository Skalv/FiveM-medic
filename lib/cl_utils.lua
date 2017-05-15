function getPlayers()
  local playerList = {}
  for i = 0, 32 do
    local player = GetPlayerFromServerId(i)
    if NetworkIsPlayerActive(player) then
      table.insert(playerList, player)
    end
  end
  return playerList
end

function getNearPlayer(checkZone)
  local players = getPlayers()
  local pos = GetEntityCoords(GetPlayerPed(-1))
  local pos2
  local distance
  local minDistance = checkZone
  local playerNear
  for _, player in pairs(players) do
    pos2 = GetEntityCoords(GetPlayerPed(player))
    distance = GetDistanceBetweenCoords(pos["x"], pos["y"], pos["z"], pos2["x"], pos2["y"], pos2["z"], true)
    if (pos ~= pos2 and distance < minDistance) then
      playerNear = player
      minDistance = distance
    end
  end
  if (minDistance < checkZone) then
    return playerNear
  end
end

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

function drawTxt(text,font,centre,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(centre)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x , y)
end

List = {}
function List.new()
  return {first = 0, last = -1}
end
function List.pushleft(list, value)
  local first = list.first - 1
  list.first = first
  list[first] = value
end
function List.pushright(list, value)
  local last = list.last + 1
  list.last = last
  list[last] = value
end
function List.popleft(list)
  local first = list.first
  if first > list.last then
    local value = nil
  else
    local value = list[first]
  end
  list[first] = nil        -- to allow garbage collection
  list.first = first + 1
  return value
end

function List.getfirst(list)
  return list[list.first]
end

function List.popright(list)
  local last = list.last
  if list.first > last then
    local value = nil
  else
    local value = list[last]
  end
  list[last] = nil         -- to allow garbage collection
  list.last = last - 1
  return value
end
function List.getlast(list)
  local last = list.last
  if list.first > last then
    local value = nil
  else
    local value = list[last]
  end
  return value
end
