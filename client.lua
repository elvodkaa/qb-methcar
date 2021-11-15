local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}
local started = false
local displayed = false
local progress = 0
local CurrentVehicle 
local pause = true
local selection = 0
local quality = 0
QBCore = exports['qb-core']:GetCoreObject()

local LastCar
local requiredItemsShowed = false

RegisterNetEvent('qb-methcar:stop')
AddEventHandler('qb-methcar:stop', function()
	QBCore.Functions.Notify('Production stopped', 'error')
	pause = true
	started = false
	FreezeEntityPosition(LastCar, false)
	SetPedIntoVehicle(GetPlayerPed(-1), CurrentVehicle, -1)
	SetVehicleDoorShut(CurrentVehicle, 2)
end)

RegisterNetEvent('qb-methcar:notify')
AddEventHandler('qb-methcar:notify', function(message)
	QBCore.Functions.Notify(message)
end)

RegisterNetEvent('qb-methcar:start')
AddEventHandler('qb-methcar:start', function()
	QBCore.Functions.Notify('Starting production...', 'success')
	started = true
	FreezeEntityPosition(CurrentVehicle,true)
	displayed = false
	QBCore.Functions.Notify('Meth Production has started', 'success')
	SetPedIntoVehicle(GetPlayerPed(-1), CurrentVehicle, 3)
	SetVehicleDoorOpen(CurrentVehicle, 2)
end)

RegisterNetEvent('qb-methcar:blowup')
AddEventHandler('qb-methcar:blowup', function(posx, posy, posz)
	AddExplosion(posx, posy, posz + 2,23, 20.0, true, false, 1.0, true)
	if not HasNamedPtfxAssetLoaded("core") then
		RequestNamedPtfxAsset("core")
		while not HasNamedPtfxAssetLoaded("core") do
			Citizen.Wait(1)
		end
	end
	SetPtfxAssetNextCall("core")
	local fire = StartParticleFxLoopedAtCoord("en_ray_heli_aprtmnt_l_fire", posx, posy, posz-0.8 , 0.0, 0.0, 0.0, 0.8, false, false, false, false)
	Citizen.Wait(6000)
	StopParticleFxLooped(fire, 0)	
end)


RegisterNetEvent('qb-methcar:smoke')
AddEventHandler('qb-methcar:smoke', function(posx, posy, posz, bool)

	if bool == 'a' then
		if not HasNamedPtfxAssetLoaded("core") then
			RequestNamedPtfxAsset("core")
			while not HasNamedPtfxAssetLoaded("core") do
				Citizen.Wait(1)
			end
		end
		SetPtfxAssetNextCall("core")
		local smoke = StartParticleFxLoopedAtCoord("exp_grd_flare", posx, posy, posz + 1.7, 0.0, 0.0, 0.0, 2.0, false, false, false, false)
		SetParticleFxLoopedAlpha(smoke, 0.8)
		SetParticleFxLoopedColour(smoke, 0.0, 0.0, 0.0, 0)
		Citizen.Wait(22000)
		StopParticleFxLooped(smoke, 0)
	else
		StopParticleFxLooped(smoke, 0)
	end
end)

RegisterNetEvent('qb-methcar:drug')
AddEventHandler('qb-methcar:drug', function()
	SetTimecycleModifier("drug_drive_blend01")
	SetPedMotionBlur(GetPlayerPed(-1), true)
	SetPedMovementClipset(GetPlayerPed(-1), "MOV_M@DRUNK@SLIGHTLYDRUNK", true)
	SetPedIsDrunk(GetPlayerPed(-1), true)

	Citizen.Wait(300000)
	ClearTimecycleModifier()
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		
		playerPed = GetPlayerPed(-1)
		local pos = GetEntityCoords(GetPlayerPed(-1))
		if IsPedInAnyVehicle(playerPed) then
			CurrentVehicle = GetVehiclePedIsUsing(PlayerPedId())
			car = GetVehiclePedIsIn(playerPed, false)
			LastCar = GetVehiclePedIsUsing(playerPed)
			local model = GetEntityModel(CurrentVehicle)
			local modelName = GetDisplayNameFromVehicleModel(model)
			local chance = math.random(1,80)
			if modelName == 'JOURNEY' and car then
					if GetPedInVehicleSeat(car, -1) == playerPed then
						if started == false then
							if displayed == false then
								QBCore.Functions.Notify('Press Y to start making drugs', 'primary', 5000)
								displayed = true
							end
						end
						if IsControlJustReleased(0, Keys['Y']) and GetLastInputMethod( 0 ) then
							if pos.y >= 3500 then
								if GetClockHours() >= 20 and GetClockHours() <= 23 then

									if IsVehicleSeatFree(CurrentVehicle, 3) then
										if chance <= 50 then
											TriggerEvent('dispatch:methalert')
										end
										TriggerServerEvent('qb-methcar:start')
										TriggerEvent('qb-methcar:make')
										progress = 0
										pause = false
										selection = 0
										quality = 0
									else
										QBCore.Functions.Notify('The car is already occupied..', 'error', 5000)
									end
								else
									QBCore.Functions.Notify('Time should be between 20:00 to 23:00 ..', 'error', 5000)
								end
							else
								QBCore.Functions.Notify('You are too close to the city, Head further up north to begin meth production', 'error', 5000)
							end
						end
					end
			    end	
		    else
				if started then
					pause = true
					displayed = false
					FreezeEntityPosition(LastCar,false)
					TriggerEvent('qb-methcar:stop')
				end
		    end
		if started == true then
			
			if progress < 98 then
				Citizen.Wait(6000)
				if IsPedInAnyVehicle(playerPed) then
					progress = progress +  1
					QBCore.Functions.Notify('Meth production: ' ..progress.. '%', 'success')
					Citizen.Wait(6000) 
				end
				if progress > 22 and progress < 24 then
					pause = true
					if selection == 0 then
						QBCore.Functions.Notify('The propane pipe is leaking, What do you do?', 'primary', 10000)
						QBCore.Functions.Notify('N7. Fix using tape', 'success', 10000)
						QBCore.Functions.Notify('N8. Leave it be', 'success', 10000)
						QBCore.Functions.Notify('N9. Replace it', 'success', 10000)
						QBCore.Functions.Notify('Press the number of the option you want to do?', 'primary', 10000)
					end
					if selection == 1 then
						QBCore.Functions.Notify('The tape kinda stopped the leak?', 'success', 10000)
						quality = quality - 3
						pause = false
						selection = 0
					end
					if selection == 2 then
						QBCore.Functions.Notify('The propane tank blew up, you messed up...', 'success', 10000)
						TriggerServerEvent('qb-methcar:blow', pos.x, pos.y, pos.z)
						SetVehicleEngineHealth(CurrentVehicle, 0.0)
						quality = 0
						started = false
						displayed = false
						ApplyDamageToPed(GetPlayerPed(-1), 10, false)
					end
					if selection == 3 then
						QBCore.Functions.Notify('Good job, the pipe wasn\'t in a good condition', 'success', 10000)
						pause = false
						quality = quality + 5
						selection = 0
					end
				end
				if progress > 30 and progress < 32 then
					pause = true
					if selection == 0 then
						QBCore.Functions.Notify('You spilled a bottle of acetone on the ground, what do you do?', 'primary' , 10000)	
						QBCore.Functions.Notify('Num7. Open the windows to get rid of the smell', 'success' , 10000)
						QBCore.Functions.Notify('Num8. Leave it be', 'success' , 10000)
						QBCore.Functions.Notify('Num9. Put on a mask with airfilter', 'success' , 10000)
						QBCore.Functions.Notify('Press the number of the option you want to do..', 'primary' , 10000)
					end
					if selection == 1 then
						QBCore.Functions.Notify('You opened the windows to get rid of the smell', 'success' , 10000)
						quality = quality - 1
						pause = false
						selection = 0
					end
					if selection == 2 then
						QBCore.Functions.Notify('You got high from inhaling acetone too much', 'success' , 10000)
						pause = false
						TriggerEvent('qb-methcar:drugged')
						selection = 0
					end
					if selection == 3 then
						QBCore.Functions.Notify('Thats an easy way to fix the issue.. I guess', 'success' , 10000)
						SetPedPropIndex(playerPed, 1, 26, 7, true)
						pause = false
						selection = 0
					end
				end
				if progress > 38 and progress < 40 then
					pause = true
					if selection == 0 then
						QBCore.Functions.Notify('Meth becomes solid too fast, what do you do?', 'primary' , 10000)
						QBCore.Functions.Notify('N7. Raise the pressure', 'success' , 10000)
						QBCore.Functions.Notify('N8. Raise the temperature', 'success' , 10000)
						QBCore.Functions.Notify('N9. Lower the pressure', 'success' , 10000)
						QBCore.Functions.Notify('Press the number of the option you want to do', 'success' , 10000)
					end
					if selection == 1 then
						QBCore.Functions.Notify('You raised the pressure and the propane started escaping, you lowered it and its okay for now', 'primary' , 10000)
						pause = false
						selection = 0
					end
					if selection == 2 then
						QBCore.Functions.Notify('Raising the temperature helped...', 'success' , 10000)
						quality = quality + 5
						pause = false
						selection = 0
					end
					if selection == 3 then
						QBCore.Functions.Notify('Lowering the pressure just made it worse...', 'success' , 10000)
						pause = false
						quality = quality -4
						selection = 0
					end
				end
				if progress > 41 and progress < 43 then
					pause = true
					if selection == 0 then
                        QBCore.Functions.Notify('You accidentally pour too much acetone, what do you do?', 'primary' , 10000)
						QBCore.Functions.Notify('N7. Do nothing', 'success' , 10000)
						QBCore.Functions.Notify('N8. Try to sucking it out using syringe', 'success' , 10000)
						QBCore.Functions.Notify('N9. Add more lithium to balance it out', 'success' , 10000)
						QBCore.Functions.Notify('Press the number of the option you want to do', 'primary' , 10000)
					end
					if selection == 1 then
						QBCore.Functions.Notify('The meth is not smelling like acetone a lot', 'success' , 10000)
						quality = quality - 3
						pause = false
						selection = 0
					end
					if selection == 2 then
						QBCore.Functions.Notify('It kind of worked but its still too much', 'success' , 10000)
						pause = false
						quality = quality - 1
						selection = 0
					end
					if selection == 3 then
						QBCore.Functions.Notify('You successfully balanced both chemicals out and its good again', 'success' , 10000)
						pause = false
						quality = quality + 3
						selection = 0
					end
				end
				if progress > 46 and progress < 49 then
					pause = true
					if selection == 0 then
						QBCore.Functions.Notify('You found some water coloring, what do you do?', 'primary' , 10000)
						QBCore.Functions.Notify('N7. Add it in', 'success' , 10000)
						QBCore.Functions.Notify('N8. Put it away', 'success' , 10000)
						QBCore.Functions.Notify('N9. Drink it', 'success' , 10000)
						QBCore.Functions.Notify('Press the number of the option you want to do', 'primary' , 10000)
					end
					if selection == 1 then
						QBCore.Functions.Notify('Good idea, people like colors', 'success' , 10000)
						quality = quality + 4
						pause = false
						selection = 0
					end
					if selection == 2 then
						QBCore.Functions.Notify('Yeah it might destroy the taste of meth', 'success' , 10000)
						pause = false
						selection = 0
					end
					if selection == 3 then
						QBCore.Functions.Notify('You are a bit weird and feel dizzy but its all good', 'success' , 10000)
						pause = false
						selection = 0
					end
				end
				if progress > 55 and progress < 58 then
					pause = true
					if selection == 0 then
						QBCore.Functions.Notify('The filter is clogged, what do you do?', 'primary' , 10000)	
						QBCore.Functions.Notify('N7. Clean it using compressed air', 'success' , 10000)
						QBCore.Functions.Notify('N8. Replace the filter', 'success' , 10000)
						QBCore.Functions.Notify('N9. Clean it using a tooth brush', 'success' , 10000)
						QBCore.Functions.Notify('Press the number of the option you want to do', 'primary' , 10000)
					end
					if selection == 1 then
						QBCore.Functions.Notify('Compressed air sprayed the liquid meth all over you', 'success' , 10000)
						quality = quality - 2
						pause = false
						selection = 0
					end
					if selection == 2 then
						QBCore.Functions.Notify('Replacing it was probably the best option', 'success' , 10000)
						pause = false
						quality = quality + 3
						selection = 0
					end
					if selection == 3 then
						QBCore.Functions.Notify('This worked quite well but its still kinda dirty', 'success' , 10000)
						pause = false
						quality = quality - 1
						selection = 0
					end
				end
				if progress > 58 and progress < 60 then
					pause = true
					if selection == 0 then
						QBCore.Functions.Notify('You spilled a bottle of acetone on the ground, what do you do?', 'primary' , 10000)
						QBCore.Functions.Notify('N7. Open the windows to get rid of the smell', 'success' , 10000)
						QBCore.Functions.Notify('N8. Leave it be', 'success' , 10000)
						QBCore.Functions.Notify('NN9. Put on a mask with airfilter', 'success' , 10000)
						QBCore.Functions.Notify('Press the number of the option you want to do', 'success' , 10000)
					end
					if selection == 1 then
						QBCore.Functions.Notify('You opened the windows to get rid of the smell', 'primary' , 10000)
						quality = quality - 1
						pause = false
						selection = 0
					end
					if selection == 2 then
						QBCore.Functions.Notify('You got high from inhaling acetone too much', 'success' , 10000)
						pause = false
						TriggerEvent('qb-methcar:drugged')
						selection = 0
					end
					if selection == 3 then
						QBCore.Functions.Notify('Thats an easy way to fix the issue.. I guess', 'success' , 10000)
						SetPedPropIndex(playerPed, 1, 26, 7, true)
						pause = false
						selection = 0
					end
				end
				if progress > 63 and progress < 65 then
					pause = true
					if selection == 0 then
						QBCore.Functions.Notify('The propane pipe is leaking, What do you do?', 'primary' , 10000)
						QBCore.Functions.Notify('N7. Fix using tape', 'success' , 10000)
						QBCore.Functions.Notify('N8. Leave it be', 'success' , 10000)
						QBCore.Functions.Notify('N9. Replace it', 'success' , 10000)
						QBCore.Functions.Notify('Press the number of the option you want to do', 'primary' , 10000)
					end
					if selection == 1 then
						QBCore.Functions.Notify('The tape kinda stopped the leak', 'success' , 10000)
						quality = quality - 3
						pause = false
						selection = 0
					end
					if selection == 2 then
						QBCore.Functions.Notify('The propane tank blew up, you messed up...', 'success' , 10000)
						TriggerServerEvent('qb-methcar:blow', pos.x, pos.y, pos.z)
						SetVehicleEngineHealth(CurrentVehicle, 0.0)
						quality = 0
						started = false
						displayed = false
						ApplyDamageToPed(GetPlayerPed(-1), 10, false)
					end
					if selection == 3 then
						QBCore.Functions.Notify('Good job, the pipe wasnt in a good condition', 'success' , 10000)
						pause = false
						quality = quality + 5
						selection = 0
					end
				end
				if progress > 71 and progress < 73 then
					pause = true
					if selection == 0 then
						QBCore.Functions.Notify('The filter is clogged, what do you do?', 'primary' , 10000)
						QBCore.Functions.Notify('N7. Clean it using compressed air', 'success' , 10000)
						QBCore.Functions.Notify('N8. Replace the filter', 'success' , 10000)
						QBCore.Functions.Notify('N9. Clean it using a tooth brush', 'primary' , 10000)
						QBCore.Functions.Notify('Press the number of the option you want to do', 'success' , 10000)
					end
					if selection == 1 then
						QBCore.Functions.Notify('Compressed air sprayed the liquid meth all over you', 'success' , 10000)
						quality = quality - 2
						pause = false
						selection = 0
					end
					if selection == 2 then
						QBCore.Functions.Notify('Replacing it was probably the best option', 'success' , 10000)
						pause = false
						quality = quality + 3
						selection = 0
					end
					if selection == 3 then
						QBCore.Functions.Notify('This worked quite well but its still kinda dirty', 'success' , 10000)
						pause = false
						quality = quality - 1
						selection = 0
					end
				end
				if progress > 76 and progress < 78 then
					pause = true
					if selection == 0 then
						QBCore.Functions.Notify('You accidentally pour too much acetone, what do you do?', 'primary' , 10000)
						QBCore.Functions.Notify('N7. Do nothing', 'success' , 10000)
						QBCore.Functions.Notify('N8. Try to sucking it out using syringe', 'success' , 10000)
						QBCore.Functions.Notify('N9. Add more lithium to balance it out', 'success' , 10000)
						QBCore.Functions.Notify('Press the number of the option you want to do', 'primary' , 10000)
					end
					if selection == 1 then
						QBCore.Functions.Notify('The meth is not smelling like acetone a lot', 'success' , 10000)
						quality = quality - 3
						pause = false
						selection = 0
					end
					if selection == 2 then
						QBCore.Functions.Notify('It kind of worked but its still too much', 'success' , 10000)
						pause = false
						quality = quality - 1
						selection = 0
					end
					if selection == 3 then
						QBCore.Functions.Notify('You successfully balanced both chemicals out and its good again', 'success' , 10000)
						pause = false
						quality = quality + 3
						selection = 0
					end
				end
				if progress > 82 and progress < 84 then
					pause = true
					if selection == 0 then
						QBCore.Functions.Notify('You need to take a shit, what do you do?', 'primary' , 10000)
						QBCore.Functions.Notify('N7. Try to hold it', 'success' , 10000)
						QBCore.Functions.Notify('N8. Go outside and take a shit', 'success' , 10000)
						QBCore.Functions.Notify('N9. Shit inside', 'success' , 10000)
						QBCore.Functions.Notify('Press the number of the option you want to do', 'success' , 10000)
					end
					if selection == 1 then
						QBCore.Functions.Notify('Good job, you need to work first, shit later', 'primary' , 10000)
						quality = quality + 1
						pause = false
						selection = 0
					end
					if selection == 2 then
						QBCore.Functions.Notify('While you were outside the glass fell off the table and spilled all over the floor...', 'success' , 10000)
						pause = false
						quality = quality - 2
						selection = 0
					end
					if selection == 3 then
						QBCore.Functions.Notify('The air smells like shit now, the meth smells like shit now', 'success' , 10000)
						pause = false
						quality = quality - 1
						selection = 0
					end
				end
				if progress > 88 and progress < 90 then
					pause = true
					if selection == 0 then
						QBCore.Functions.Notify('Do you add some glass pieces to the meth so it looks like you have more of it?', 'success' , 10000)
						QBCore.Functions.Notify('N7. Yes!', 'success' , 10000)
						QBCore.Functions.Notify('N8. No', 'success' , 10000)
						QBCore.Functions.Notify('N9. What if I add meth to glass instead', 'primary' , 10000)
						QBCore.Functions.Notify('Press the number of the option you want to do', 'success' , 10000)
					end
					if selection == 1 then
						QBCore.Functions.Notify('Now you got few more baggies out of it', 'primary' , 10000)
						quality = quality + 1
						pause = false
						selection = 0
					end
					if selection == 2 then
						QBCore.Functions.Notify('You are a good drug maker, your product is high quality', 'success' , 10000)
						pause = false
						quality = quality + 1
						selection = 0
					end
					if selection == 3 then
						QBCore.Functions.Notify('Thats a bit too much, its more glass than meth but ok.', 'success' , 10000)
						pause = false
						quality = quality - 1
						selection = 0
					end
				end
				if IsPedInAnyVehicle(playerPed) then
					TriggerServerEvent('qb-methcar:make', pos.x,pos.y,pos.z)
					if pause == false then
						selection = 0
						quality = quality + 1
						progress = progress +  math.random(1, 2)
						QBCore.Functions.Notify('Chemical production: ' .. progress .. '%', 'success' , 10000)
					end
				else
					TriggerEvent('qb-methcar:stop')
				end
			else 
				progress = 100
				pause = true
				started = false
				QBCore.Functions.Notify('Meth chemical Production: ' ..progress.. '%', 'success' , 10000)
				QBCore.Functions.Notify('Meth chemical Production finished', 'success' , 10000)
				TriggerServerEvent('qb-methcar:finish', quality)
				TriggerEvent('qb-methcar:stop')
				FreezeEntityPosition(LastCar, false)
				progress = 0
			end	
		end	
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
			if IsPedInAnyVehicle(GetPlayerPed(-1)) then
			else
				if started then
					started = true
					displayed = false
					FreezeEntityPosition(LastCar,false)
				end		
			end
		end
	end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)		
		if pause == true and started == true then
			if IsControlJustReleased(0, Keys['N7']) then
				selection = 1
				QBCore.Functions.Notify('Selected option number 7', 'success')
			end
			if IsControlJustReleased(0, Keys['N8']) then
				selection = 2
				QBCore.Functions.Notify('Selected option number 8', 'success')
			end
			if IsControlJustReleased(0, Keys['N9']) then
				selection = 3
				QBCore.Functions.Notify('Selected option number 9', 'success')
			end
		end
	end
end)
