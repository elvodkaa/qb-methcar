QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('qb-methcar:start')
AddEventHandler('qb-methcar:start', function()
	local src   = source
    local Player = QBCore.Functions.GetPlayer(src)

	if Player.Functions.GetItemByName('acetone') and Player.Functions.GetItemByName('hydrochloricacid') and Player.Functions.GetItemByName('ephedrine') then
		TriggerClientEvent('qb-methcar:start', src)
		Player.Functions.RemoveItem('acetone', 1)
	    Player.Functions.RemoveItem('hydrochloricacid', 1)
	   TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['acetone'], "remove")
	   TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['hydrochloricacid'], "remove")
	   TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['ephedrine'], "remove")
	   TriggerClientEvent("QBCore:Notify", src, "Meth producing started sucessfully", "success", 7500)
	else
		TriggerClientEvent("QBCore:Notify", src, "You don\'t have enough supplies", "error", 7500)
	end
end)



RegisterServerEvent('qb-methcar:stop')
AddEventHandler('qb-methcar:stop', function()
    local src   = source
    local Player = QBCore.Functions.GetPlayer(src)
    local xPlayers   = QBCore.Functions.GetPlayers()
	for i=1, #xPlayers, 1 do
		TriggerClientEvent('qb-methcar:stop', xPlayers[i], id)
	end	
end)

RegisterServerEvent('qb-methcar:make')
AddEventHandler('qb-methcar:make', function(posx,posy,posz)
	local src   = source
    local Player = QBCore.Functions.GetPlayer(src)
	local xPlayers   = QBCore.Functions.GetPlayers(Player)
	for i=1, #xPlayers, 1 do
		TriggerClientEvent('qb-methcar:smoke',xPlayers[i],posx,posy,posz, 'a') 
	end
end)

RegisterServerEvent('qb-methcar:finish')
AddEventHandler('qb-methcar:finish', function(qualtiy)
	local src   = source
    local Player = QBCore.Functions.GetPlayer(src)
	print(qualtiy)
	local rnd = math.random(-7, 5)
	local qualitynew = qualtiy - 4
	Player.Functions.AddItem('meth', math.floor(qualitynew / 2) + rnd)
	TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['meth'], "add")
	Player.Functions.AddItem('meth', math.floor(qualitynew / 2) + rnd)
	TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['meth'], "add")
	Player.Functions.AddItem('meth', math.floor(qualitynew / 2) + rnd)
	TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['meth'], "add")
	
end)

RegisterServerEvent('qb-methcar:blow')
AddEventHandler('qb-methcar:blow', function(posx, posy, posz)
	local src   = source
    local Player = QBCore.Functions.GetPlayer(src)
    local xPlayers   = QBCore.Functions.GetPlayers()
	for i=1, #xPlayers, 1 do
		TriggerClientEvent('qb-methcar:blowup', xPlayers[i],posx, posy, posz)
	end
end)

