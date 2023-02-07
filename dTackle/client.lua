--local TackleKey <const> = GetConvar("TackleKey", 'e') 
--local TackleTime <const> = GetConvar("TackleTime", 3000)
-- local TackleAntiCheatDistanceLimit <const> = GetConvar("TackleAntiCheatDistanceLimit", 8.0)

local function showNotification(msg)
	BeginTextCommandThefeedPost('STRING')
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandThefeedPostTicker(false, true)
end

-- Main TackleKey Registration
RegisterCommand('-tackle', function()
	if IsPedJumping(PlayerPedId()) then
		if IsPedInAnyVehicle(PlayerPedId()) then
			showNotification('~r~You cannot tackle someone in a vehicle')
		else
			local ForwardVector = GetEntityForwardVector(PlayerPedId())
			local Tackled = {}

			SetPedToRagdollWithFall(PlayerPedId(), 1500, 2000, 0, ForwardVector, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

			while IsPedRagdoll(PlayerPedId()) do
				Citizen.Wait(0)
				for Key, Value in ipairs(GetTouchedPlayers()) do
					if not Tackled[Value] then
						Tackled[Value] = true
						TriggerServerEvent('Tackle:Server:TacklePlayer', source,  GetPlayerServerId(Value))
					end
				end
			end
		end
	end
end, false)
-- keybind uses parameter id
RegisterKeyMapping('+tackle', 'Tackle', 'keyboard', GetConvar("TackleKey", 'e'))


function GetPlayers()
	local Players = {}

	for i = 0, 31 do
		if NetworkIsPlayerActive(i) then
			table.insert(Players, i)
		end
	end

	return Players
end

function GetTouchedPlayers()
	local TouchedPlayer = {}
	for Key, Value in ipairs(GetPlayers()) do
		if IsEntityTouchingEntity(PlayerPedId(), GetPlayerPed(Value)) then
			table.insert(TouchedPlayer, Value)
		end
	end
	return TouchedPlayer
end


RegisterCommand("getloc", function(source, args, rawCommand)
	local playerid = tonumber(args[1])
	if GetPlayerServerId(playerid) then
		TriggerServerEvent('Tackle:Server:TacklePlayer', source, playerid)
		print(source)
		showNotification("Event fired")
	else
		showNotification("Invalid Target")
	end
end, false) 


RegisterNetEvent('Tackle:Client:TacklePlayer')
AddEventHandler('Tackle:Client:TacklePlayer', function(Tackler)
	local plrcrds = GetEntityCoords(GetPlayerPed())
	local tacklercoords = GetEntityCoords(GetPlayerPed(Tackler))
	local ForwardVector = GetEntityForwardVector(Tackler)
	
	local distBetween = GetDistanceBetweenCoords(plrcrds.x, plrcrds.y, plrcrds.z, tacklercoords.x, tacklercoords.y, tacklercoords.z, true)
	if distBetween <= tonumber(GetConvar("TackleAntiCheatDistanceLimit", 8.0)) then
		showNotification('~r~' .. GetPlayerName(Tackler) .. ' ~r~tackled you!')
		local TackleTime = GetConvar("TackleTime", 3000)
		SetPedToRagdollWithFall(PlayerPedId(), TackleTime, TackleTime, 0, ForwardVector.x, ForwardVector.y, ForwardVector.z, 10.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
	else
		print(GetPlayerName(Tackler).." provided a false packet, possible cheater")
	end
end)
