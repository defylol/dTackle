SetConvarReplicated("TackleKey", config.TackleKey)
SetConvarReplicated("TackleTime", config.TackleTime)
SetConvarReplicated("TackleAntiCheatDistanceLimit", config.TackleAntiCheatDistanceLimit)

RegisterServerEvent('Tackle:Server:TacklePlayer')
AddEventHandler('Tackle:Server:TacklePlayer', function(src, targ)
	TriggerClientEvent("Tackle:Client:TacklePlayer", targ, src)
	print(GetPlayerName(src).." has tackled "..GetPlayerName(targ))
end)
