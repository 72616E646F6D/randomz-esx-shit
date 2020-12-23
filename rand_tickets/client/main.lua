ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
    end
end)

RegisterNetEvent('tickets:list')
AddEventHandler('tickets:list', function(list)
    local otvoreni = {}

    for i = 1, #list do
        table.insert(otvoreni, {label = 'Ticket #' .. list[i].sig .. ' | Player: ' .. GetPlayerName(GetPlayerFromServerId(i)) .. ' | ID: ' .. i .. ' >>', value = i, msg = list[i].msg, num = list[i].sig, time = list[i].time})
    end

    ESX.UI.Menu.CloseAll() -- close otvorene menije

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'main_menu', {
		title    = 'TICKET SYSTEM',
		align    = 'left',
		elements = otvoreni
	}, function(data, menu)

		if data.current.value ~= nil then
			ShowTicket(data.current)
		end

	end, function(data, menu)
		menu.close()
	end)
end)

function ShowTicket(info)
    local elements = {}

    local Player = GetPlayerFromServerId(info.value)
    local PlayerName = GetPlayerName(Player)
    local PlayerID = info.value
    local TicketSig = info.num

    table.insert(elements, {label = 'Opened by: ' .. PlayerName .. ' [' .. PlayerID .. ']', value = nil})
    table.insert(elements, {label = 'Timestamp: ' .. info.time, value = nil})
    table.insert(elements, {label = '> Ticket message', value = 'msg'})
    table.insert(elements, {label = '> Go to the player',  value = 'tpto'})
    table.insert(elements, {label = '> Bring the player',  value = 'tptome'})
    table.insert(elements, {label = '<span style="color:red;">> Close this ticket</span>',  value = 'close'})


	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'ticket_menu', {
		title    = 'TICKET: #' .. TicketSig,
		align    = 'left',
		elements = elements
	}, function(data, menu)

        if data.current.value == 'msg' then
            ESX.ShowNotification('~r~Ticket message: ~s~' .. info.msg) -- be creative :)
        elseif data.current.value == 'tptome' then
            local whereami = GetEntityCoords(PlayerPedId())
            local x, y, z = table.unpack(whereami)
            SetEntityCoords(GetPlayerPed(Player), x, y, z + 1.0, 0.0, 0.0, 0.0, false)
        elseif data.current.value == 'tpto' then
            local whereishe = GetEntityCoords(GetPlayerPed(Player))
            local x, y, z = table.unpack(whereishe)
            SetEntityCoords(PlayerPedId(), x, y, z + 1.0, 0.0, 0.0, 0.0, false)
        elseif data.current.value == 'close' then
            TriggerEvent('rand:choice', closeTicket, {PlayerID, TicketSig})
        end

	end, function(data, menu)
		menu.close()
	end)
end

function closeTicket(id, num)
    TriggerServerEvent('tickets:close', id, num)
end


--------------------------------
--???????????????????????????
--------------------------------
RegisterNetEvent('rand:choice')
AddEventHandler('rand:choice', function(fja,params)
    local elements = {
        {label = 'No', value = 'no'},
        {label = 'Yes', value = 'yes'},
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'u_sure', {
		title    = 'Are you sure?',
		align    = 'left',
		elements = elements
	}, function(data, menu)

        if data.current.value == 'yes' then
            ESX.UI.Menu.CloseAll()
            fja(table.unpack(params))
        else -- no
            menu.close()
        end

	end, function(data, menu)
		menu.close()
	end)
end)
