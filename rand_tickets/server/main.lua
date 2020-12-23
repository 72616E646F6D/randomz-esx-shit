ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local openTickets = {}
local tNum = 0

Citizen.CreateThread(function()
  while true do
    local count = 0
    for i=1,#openTickets do
      count = count + 1
    end

    if count > 0 then
      local xAll = ESX.GetPlayers()
      for i=1, #xAll, 1 do
        local xTarget = ESX.GetPlayerFromId(xAll[i])
        local group = xTarget.getGroup()

        if group == 'admin' or group == 'superadmin' or group == 'moderator' then
          TriggerClientEvent('chat:addMessage', -1, {
            template = '<div class="chat-message advert">SYSTEM :: There\'s currently ' .. count .. ' open tickets. ( /tickets )</div>',
            args = {}
          })
        end
      end
    end

    Citizen.Wait(80000)
  end
end)

RegisterCommand("ticket", function(source, args, rawCmd)
  
  TriggerClientEvent('chat:addMessage', source, {
    template = '<div class="chat-message success">SYSTEM :: You have successfully opened a new ticket.</div>',
    args = {}
  })

  if openTickets[source] ~= nil then
    TriggerClientEvent('chat:addMessage', source, {
      template = '<div class="chat-message advert">SYSTEM :: Your previous ticket is now closed.</div>',
      args = {}
    })
  end

  tNum = tNum + 1

  rawCmd = rawCmd:sub(8)
  openTickets[source] = {sig = tNum, msg = rawCmd, time = os.date('%H:%M:%S')}

  -- ako modovi ne resavaju kazi im da resavaju
  local count = 0
  for i=1,#openTickets do
    count = count + 1
  end

  if count >= 7 then
    local xAll = ESX.GetPlayers()
    for i=1, #xAll, 1 do
      local xTarget = ESX.GetPlayerFromId(xAll[i])
      local group = xTarget.getGroup()

      if group == 'admin' or group == 'superadmin' or group == 'moderator' then
        TriggerClientEvent('chat:addMessage', -1, {
          template = '<div class="chat-message error">SYSTEM :: There\'s over 7 open tickets. Use /tickets to see them.</div>',
          args = {}
        })
      end
    end
  end
end)

RegisterCommand("tickets", function(source, args, rawCmd)
  local xMe = ESX.GetPlayerFromId(source)
  local group = xMe.getGroup()
  if group ~= 'user' then
    local next = next 
    if next(openTickets) == nil then
      TriggerClientEvent('notify', source, { type = 'error', text = 'There\'s currently no open tickets' })
      return
    end
    TriggerClientEvent('tickets:list', source, openTickets)
  end
end)

RegisterNetEvent('tickets:close')
AddEventHandler('tickets:close', function(openedBy, number)
  openTickets[openedBy] = nil
  TriggerClientEvent('chat:addMessage', source, {
    template = '<div class="chat-message nonemergency">SYSTEM :: Ticket #' .. number .. ' successfully closed.</div>',
    args = {}
  })
end)
