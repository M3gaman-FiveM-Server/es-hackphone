Framework = nil
Framework = GetFramework()

Citizen.CreateThread(function()
    while Framework == nil do Citizen.Wait(750) end
    Citizen.Wait(2500)
end)

Callback = Config.Framework == "ESX" or Config.Framework == "NewESX" and Framework.TriggerServerCallback or Framework.Functions.TriggerCallback


RegisterKeyMapping('eyestore', 'Open Eyes Menu', 'keyboard', Config.OpenKey or 'J')

local isPhoneOpen = false
local phoneProp = nil
local phoneModel = `prop_npc_phone_02`
local currentAnimDict = "cellphone@"
local currentAnim = "cellphone_text_read_base"

local currentWaypoint = nil

local atmModels = {
    `prop_atm_01`,
    `prop_atm_02`,
    `prop_atm_03`,
    `prop_fleeca_atm`
}

local robbedATMs = {}

local activeHackMarker = nil
local activeHackBlip = nil

local activeRobberyMarkers = {}

local moneyPropModels = {
    `prop_anim_cash_pile_01`,
    `prop_cash_pile_01`,
    `prop_cash_pile_02`
}

local activeMoneyProps = {}

_G.activeMoneyProps = {}
_G.robbedATMs = {}
_G.activeRobberyMarkers = {}

local alternativeMoneyProps = {
    `prop_money_bag_01`,
    `prop_cash_case_01`,
    `prop_cash_case_02`,
    `prop_cash_crate_01`,
    `bkr_prop_money_wrapped_01`,
    `bkr_prop_moneypack_01a`,
    `bkr_prop_moneypack_03a`
}

local function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(5)
    end
end

local function deletePhone()
    if phoneProp ~= nil then
        DeleteObject(phoneProp)
        phoneProp = nil
    end
end

local function createPhone()
    deletePhone()
    local ped = PlayerPedId()
    local x,y,z = table.unpack(GetEntityCoords(ped))
    
    RequestModel(phoneModel)
    while not HasModelLoaded(phoneModel) do
        Wait(1)
    end
    
    phoneProp = CreateObject(phoneModel, x, y, z + 0.2, true, true, true)
    local bone = GetPedBoneIndex(ped, 28422)
    AttachEntityToEntity(phoneProp, ped, bone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(phoneModel)
end

local function phoneAnim()
    local ped = PlayerPedId()
    loadAnimDict(currentAnimDict)
    TaskPlayAnim(ped, currentAnimDict, currentAnim, 3.0, -1, -1, 50, 0, false, false, false)
end

local function removePhoneAnim()
    local ped = PlayerPedId()
    StopAnimTask(ped, currentAnimDict, currentAnim, 1.0)
end

RegisterCommand('eyestore', function()
    if not isPhoneOpen then
        if Config.UseItem then
            local hasItem = false
            
            if Config.Framework == "QBCore" then
                Framework.Functions.TriggerCallback('hackphone:checkItem', function(result)
                    hasItem = result
                end, Config.ItemName)
            elseif Config.Framework == "ESX" or Config.Framework == "NewESX" then
                Framework.TriggerServerCallback('hackphone:checkItem', function(result)
                    hasItem = result
                end, Config.ItemName)
            end
            
            Citizen.Wait(500)
            
            if not hasItem then
                TriggerEvent("chatMessage", "TELEFON", {255, 0, 0}, "Bu özelliği kullanmak için " .. Config.ItemName .. " itemine ihtiyacınız var!")
                return
            end
        end

        isPhoneOpen = true
        createPhone()
        phoneAnim()

        Callback('BlackMarket', function(items)
            Config['Black Market Items'] = items.items

            SendNUIMessage({
                data = 'PHONE',
                open = true,
                shared = Config
            })
            
            SetNuiFocus(true, true)
            SetNuiFocusKeepInput(true)
        end)

        Citizen.CreateThread(function()
            while isPhoneOpen do
                -- Her frame başında tüm kontrolleri devre dışı bırak
                DisableAllControlActions(0)       -- Grup 0 (ana kontroller)
                DisableAllControlActions(1)       -- Grup 1
                DisableAllControlActions(2)       -- Grup 2
                
                -- HAREKET KONTROLÜ - Bu kontroller kesinlikle aktif kalacak
                -- W, A, S, D tuşları (yürüme)
                EnableControlAction(0, 32, true)  -- W tuşu
                EnableControlAction(0, 34, true)  -- A tuşu
                EnableControlAction(0, 33, true)  -- S tuşu
                EnableControlAction(0, 35, true)  -- D tuşu
                
                -- Koşma, zıplama, eğilme
                EnableControlAction(0, 21, true)  -- SHIFT tuşu (koşma)
                EnableControlAction(0, 22, true)  -- SPACE tuşu (zıplama)
                
                -- Kamera kontrolleri
                EnableControlAction(0, 1, true)   -- Kamera sağ/sol bakma
                EnableControlAction(0, 2, true)   -- Kamera yukarı/aşağı bakma
                EnableControlAction(0, 3, true)   -- Zoom
                EnableControlAction(0, 4, true)   -- Kamera ek kontrol
                EnableControlAction(0, 5, true)   -- Kamera ek kontrol
                EnableControlAction(0, 6, true)   -- Kamera ek kontrol
                
                -- Karakter dönme kontrolleri
                EnableControlAction(0, 30, true)  -- Karakter sağa sola hareketi için
                EnableControlAction(0, 31, true)  -- Karakter ileri geri hareketi için
                
                -- Alternatif hareket kontrolleri
                EnableControlAction(0, 71, true)  -- W - araç içi
                EnableControlAction(0, 72, true)  -- S - araç içi
                EnableControlAction(0, 63, true)  -- A - araç içi
                EnableControlAction(0, 64, true)  -- D - araç içi

                -- Bazı ek hareket tuşları
                EnableControlAction(0, 23, true)  -- Araç/kapı giriş tuşu (Enter vehicle)
                EnableControlAction(0, 75, true)  -- Araçtan çıkış (Exit vehicle)
                EnableControlAction(0, 23, true)  -- Enter/F
                
                -- FiveM kontrolü
                SetNuiFocus(true, true)           -- Telefon NUI'sine odaklan
                SetNuiFocusKeepInput(true)        -- Input tutmayı sürdür
                
                -- Tüm F tuşlarını devre dışı bırak
                local f_keys = {
                    288, -- F1
                    289, -- F2
                    170, -- F3
                    166, -- F5
                    167, -- F6
                    168, -- F7
                    169, -- F8
                    56,  -- F9
                    57,  -- F10
                    344  -- F11
                }
                
                -- CTRL tuşunu tamamen devre dışı bırak (diz çökmeyi engelle)
                DisableControlAction(0, 36, true)  -- CTRL (grup 0)
                DisableControlAction(1, 36, true)  -- CTRL (grup 1)
                DisableControlAction(2, 36, true)  -- CTRL (grup 2)
                SetInputExclusive(0, 36)           -- CTRL tuşunu sistemden ayır
                ResetPedRagdollBlockingFlags(PlayerPedId(), 2)
                
                -- F tuşlarını devre dışı bırak
                for _, key in ipairs(f_keys) do
                    DisableControlAction(0, key, true)
                    DisableControlAction(1, key, true)
                    DisableControlAction(2, key, true)
                    SetInputExclusive(0, key)
                    
                    -- F tuşları için ilave kontrol
                    if IsDisabledControlJustPressed(0, key) then
                        SetPauseMenuActive(false)
                    end
                end
                
                -- UI tuşlarını devre dışı bırak
                local ui_keys = {
                    199, -- P tuşu (pause menu)
                    200, -- ESC tuşu
                    202, -- ESC/Back
                    322, -- ESC key
                    244  -- M tuşu (harita)
                }
                
                for _, key in ipairs(ui_keys) do
                    DisableControlAction(0, key, true)
                    DisableControlAction(1, key, true)
                    DisableControlAction(2, key, true)
                    SetInputExclusive(0, key)
                    
                    -- ESC veya pause menu kontrolleri için ilave işlem
                    if IsDisabledControlJustPressed(0, key) then
                        if key == 200 or key == 202 or key == 322 then
                            TriggerEvent("eyestore:closePhone")
                        end
                        SetPauseMenuActive(false)
                    end
                end
                
                -- Diğer oyun kontrollerini engelle
                BlockWeaponWheelThisFrame()            -- Silah tekerleğini engelle
                HudWeaponWheelIgnoreSelection()        -- Silah tekerleği seçimlerini yoksay
                DisablePlayerFiring(PlayerId(), true)  -- Ateş etmeyi engelle

                if IsPauseMenuActive() then
                    SetPauseMenuActive(false)
                end
                
                Citizen.Wait(0)
            end
        end)
    end
end)

RegisterNUICallback('Close', function()
    if isPhoneOpen then
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        removePhoneAnim()
        Wait(500)
        deletePhone()
        SendNUIMessage({
            data = 'PHONE',
            open = false,
        })
        BeginScaleformMovieMethodOnFrontend("DISPLAY_MENU")
        ScaleformMovieMethodAddParamBool(false)
        EndScaleformMovieMethod()
        isPhoneOpen = false
        EnableAllControlActions(0)
        EnableAllControlActions(1)
        EnableAllControlActions(2)
        Citizen.CreateThread(function()
            local cooldownTime = GetGameTimer() + 500
            
            while GetGameTimer() < cooldownTime do
                DisableControlAction(0, 200, true) -- ESC menu
                DisableControlAction(0, 202, true) -- ESC/Back
                DisableControlAction(0, 322, true) -- ESC key
                DisableControlAction(0, 199, true) -- Pause menu (P)
                if IsPauseMenuActive() then
                    SetPauseMenuActive(false)
                end
                
                Citizen.Wait(0)
            end
            EnableAllControlActions(0)
            EnableAllControlActions(1)
            EnableAllControlActions(2)
        end)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    
    if isPhoneOpen then
        removePhoneAnim()
        deletePhone()
    end
    
    for id, markerData in pairs(activeRobberyMarkers) do
        if markerData.blip then
            RemoveBlip(markerData.blip)
        end
        clearMoneyProps(id)
    end
    activeRobberyMarkers = {}
end)

AddEventHandler('gameEventTriggered', function(name, args)
    if name == 'CEventNetworkEntityDamage' then
        local victim = args[1]
        local isDead = args[4] == 1
        
        if victim == PlayerPedId() and isDead and isPhoneOpen then
            removePhoneAnim()
            deletePhone()
            SetNuiFocus(false, false)
            SendNUIMessage({
                data = 'PHONE',
                open = false,
            })
            isPhoneOpen = false
        end
    end
end)

RegisterNUICallback('Robery', function(data, cb)
    if not data or not data.amount or data.amount <= 0 then
        print("Invalid robbery data!")
        cb({ success = false, message = 'Invalid robbery data!' })
        return
    end
    
    print("Robbery data received:", json.encode(data))
    print("Amount:", data.amount)
    print("ATM ID:", data.atmId)
    
    TriggerServerEvent('hackphone:giveATMMoney', data)
    
    cb({ success = true, message = 'Robbery completed! You earned $' .. data.amount .. '!' })
end)

_G.EnumerateVehicles = function()
    return coroutine.wrap(function()
        local handle, vehicle = FindFirstVehicle()
        local success = (handle ~= nil and vehicle ~= nil)
        
        if not success then
            if handle then EndFindVehicle(handle) end
            return
        end
        
        local hasNext = true
        repeat
            coroutine.yield(vehicle)
            hasNext, vehicle = FindNextVehicle(handle)
        until not hasNext
        
        EndFindVehicle(handle)
    end)
end

function GetVehicleByPlate(plate)
    if not plate then
        print("No plate specified!")
        return nil
    end
    local cleanPlate = string.gsub(plate, "%s+", "")
    local vehicles = GetGamePool('CVehicle')
    for _, vehicle in ipairs(vehicles) do
        local vehiclePlate = GetVehicleNumberPlateText(vehicle)
        vehiclePlate = string.gsub(vehiclePlate, "%s+", "")
        if string.lower(vehiclePlate) == string.lower(cleanPlate) then
            print("Vehicle found: " .. vehicle)
            return vehicle
        end
    end
    
    for vehicle in EnumerateVehicles() do
        if DoesEntityExist(vehicle) then
            local vehiclePlate = GetVehicleNumberPlateText(vehicle)
            vehiclePlate = string.gsub(vehiclePlate, "%s+", "")
            
            if string.lower(vehiclePlate) == string.lower(cleanPlate) then
                print("Vehicle found with alternative method: " .. vehicle)
                return vehicle
            end
        end
    end
    print("Vehicle not found: " .. cleanPlate)
    return nil
end

RegisterNUICallback('vehicleAction', function(data, cb)
    local action = data.action
    local playerPed = PlayerPedId()
    
    if action == 'scan' then
        local playerCoords = GetEntityCoords(playerPed)
        local vehicles = {}
        local handle, vehicle = FindFirstVehicle()
        local success = true
        
        repeat
            if DoesEntityExist(vehicle) then
                local vehicleCoords = GetEntityCoords(vehicle)
                local distance = #(playerCoords - vehicleCoords)
                
                if distance <= 20.0 then
                    local vehicleModel = GetEntityModel(vehicle)
                    local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(vehicleModel))
                    if vehicleName == "NULL" or vehicleName == "" then 
                        vehicleName = GetDisplayNameFromVehicleModel(vehicleModel)
                    end
                    local vehiclePlate = GetVehicleNumberPlateText(vehicle)
                    local doorStatus = GetVehicleDoorLockStatus(vehicle) == 2 and "Locked" or "Unlocked"
                    
                    local vehicleHealth = GetVehicleBodyHealth(vehicle)
                    local engineHealth = GetVehicleEngineHealth(vehicle)
                    local isDestroyed = vehicleHealth < 100 or engineHealth < 100
                    
                    local engineRunning = GetIsVehicleEngineRunning(vehicle)
                    local lightsState = GetVehicleLightsState(vehicle)
                    local lightsOn = lightsState == 2
                    
                    table.insert(vehicles, {
                        id = tostring(NetworkGetNetworkIdFromEntity(vehicle)),
                        name = vehicleName,
                        plate = vehiclePlate,
                        model = string.lower(vehicleName),
                        status = doorStatus,
                        distance = math.floor(distance) .. "m",
                        health = vehicleHealth,
                        engineHealth = engineHealth,
                        isDestroyed = isDestroyed,
                        engineRunning = engineRunning,
                        lightsOn = lightsOn
                    })
                end
            end
            
            success, vehicle = FindNextVehicle(handle)
        until not success
        
        EndFindVehicle(handle)
        
        print("Number of vehicles found: " .. #vehicles)
        for _, v in ipairs(vehicles) do
            print(string.format("Vehicle: %s, Plate: %s, Distance: %s, Engine: %s, Lights: %s", 
                v.name, v.plate, v.distance, tostring(v.engineRunning), tostring(v.lightsOn)))
        end
        
        cb({vehicles = vehicles})
    
    elseif action == 'getVehicleLocation' then
        local vehicle = GetVehicleByPlate(data.plate)
        
        if DoesEntityExist(vehicle) then
            local vehicleCoords = GetEntityCoords(vehicle)
            local streetHash = GetStreetNameAtCoord(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z)
            local streetName = GetStreetNameFromHashKey(streetHash)
            
            local coordsString = string.format("%.1f, %.1f, %.1f", vehicleCoords.x, vehicleCoords.y, vehicleCoords.z)
            
            cb({
                success = true,
                coords = coordsString,
                location = streetName
            })
        else
            cb({success = false})
        end
    
    elseif action == 'markLocation' then
        local coords = data.coords
        local remove = data.remove or false
        
        if remove then
            if currentBlip and DoesBlipExist(currentBlip) then
                RemoveBlip(currentBlip)
                currentBlip = nil
                cb({status = 'removed'})
                return
            end
            cb({status = 'error', message = 'No marker to remove'})
            return
        end
        
        if coords then
            local x, y, z = string.match(coords, "([^,]+), ([^,]+), ([^,]+)")
            x, y, z = tonumber(x), tonumber(y), tonumber(z)
            
            if x and y and z then
                if currentBlip and DoesBlipExist(currentBlip) then
                    RemoveBlip(currentBlip)
                    currentBlip = nil
                end
                
                currentBlip = AddBlipForCoord(x, y, z)
                SetBlipSprite(currentBlip, 161)
                SetBlipColour(currentBlip, 5)
                SetBlipScale(currentBlip, 1.0)
                SetBlipAsShortRange(currentBlip, false)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Tracked Location")
                EndTextCommandSetBlipName(currentBlip)
                
                SetBlipRoute(currentBlip, true)
                SetBlipRouteColour(currentBlip, 5)
                
                cb({status = 'marked'})
            else
                print("Koordinat dönüşüm hatası:", coords)
                cb({status = 'error', message = 'Invalid coordinates format'})
            end
        else
            cb({status = 'error', message = 'No coordinates provided'})
        end
    
    elseif action == 'door' then
        local vehicle = nil
        local handle, veh = FindFirstVehicle()
        local success = true
        
        repeat
            if DoesEntityExist(veh) and GetVehicleNumberPlateText(veh) == data.plate then
                vehicle = veh
                break
            end
            success, veh = FindNextVehicle(handle)
        until not success
        
        EndFindVehicle(handle)
        
        if DoesEntityExist(vehicle) then
            local doorIndex = tonumber(data.doorIndex)
            if doorIndex and doorIndex >= 0 and doorIndex <= 5 then
                local currentDoorState = GetVehicleDoorAngleRatio(vehicle, doorIndex) > 0.0
                
                if data.state then
                    if not currentDoorState then
                        SetVehicleDoorOpen(vehicle, doorIndex, false, false)
                    end
                else
                    if currentDoorState then
                        SetVehicleDoorShut(vehicle, doorIndex, false)
                    end
                end
                
                local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
                TriggerServerEvent('hackphone:syncVehicleDoor', vehicleNetId, doorIndex, data.state)
                
                cb({status = 'success'})
            else
                cb({status = 'error', message = 'Invalid door index'})
            end
        else
            cb({status = 'error', message = 'Vehicle not found'})
        end
    
    elseif action == 'lock' or action == 'unlock' then
        local vehicle = GetVehicleByPlate(data.plate)
        
        if DoesEntityExist(vehicle) then
            local lockState = action == 'lock' and 2 or 1
            
            SetVehicleDoorsLocked(vehicle, lockState)
            
            local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
            TriggerServerEvent('hackphone:syncVehicleLock', vehicleNetId, lockState)
            
            PlayVehicleDoorCloseSound(vehicle, 1)
            
            SendNUIMessage({
                data = 'addTerminalOutput',
                text = action == 'lock' and 'Vehicle locked.' or 'Vehicle unlocked.',
                type = 'success'
            })
            
            cb({status = 'ok'})
        else
            cb({status = 'error', message = 'Vehicle not found'})
        end
    
    elseif action == 'engine' then
        local vehicle = GetVehicleByPlate(data.plate)
        
        if DoesEntityExist(vehicle) then
            local isEngineRunning = GetIsVehicleEngineRunning(vehicle)
            
            local newEngineState = data.state
            
            SetVehicleEngineOn(vehicle, newEngineState, true, true)
            SetVehicleUndriveable(vehicle, not newEngineState)
            
            local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
            TriggerServerEvent('hackphone:syncVehicleEngine', vehicleNetId, newEngineState)
            
            print("Engine state changed: " .. tostring(isEngineRunning) .. " -> " .. tostring(newEngineState))
            print("Vehicle: " .. vehicle .. ", Plate: " .. data.plate)
            
            SendNUIMessage({
                data = 'addTerminalOutput',
                text = newEngineState and "Engine started." or "Engine stopped.",
                type = 'success'
            })
            
            cb({status = 'ok'})
        else
            print("Vehicle not found: " .. data.plate)
            cb({status = 'error', message = 'Vehicle not found'})
        end
    
    elseif action == 'lights' then
        local vehicle = GetVehicleByPlate(data.plate)
        
        if DoesEntityExist(vehicle) then
            local newLightsState = data.state
            
            SetVehicleLights(vehicle, newLightsState and 2 or 1)
            
            if newLightsState then
                SetVehicleLightMultiplier(vehicle, 1.0)
            end
            
            local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
            TriggerServerEvent('hackphone:syncVehicleLights', vehicleNetId, newLightsState)
            
            print("Lights state changed: " .. tostring(newLightsState))
            print("Vehicle: " .. vehicle .. ", Plate: " .. data.plate)
            
            SendNUIMessage({
                data = 'addTerminalOutput',
                text = newLightsState and "Lights turned on." or "Lights turned off.",
                type = 'success'
            })
            
            cb({status = 'ok'})
        else
            print("Vehicle not found: " .. data.plate)
            cb({status = 'error', message = 'Vehicle not found'})
        end
    
    elseif action == 'plantBomb' then
        local vehicle = nil
        local handle, veh = FindFirstVehicle()
        local success = true
        
        repeat
            if DoesEntityExist(veh) and GetVehicleNumberPlateText(veh) == data.plate then
                vehicle = veh
                break
            end
            success, veh = FindNextVehicle(handle)
        until not success
        
        EndFindVehicle(handle)
        
        if DoesEntityExist(vehicle) then
            local playerPed = PlayerPedId()
            local animDict = "anim@heists@ornate_bank@thermal_charge"
            
            RequestAnimDict(animDict)
            while not HasAnimDictLoaded(animDict) do
                Citizen.Wait(10)
            end
            
            TaskPlayAnim(playerPed, animDict, "thermal_charge", 8.0, 1.0, -1, 1, 0, false, false, false)
            Citizen.Wait(5000)
            ClearPedTasks(playerPed)
            
            SendNUIMessage({
                data = 'bombPlanted',
                plate = data.plate
            })
            
            local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
            TriggerServerEvent('hackphone:syncBombPlanted', vehicleNetId, 10000)
            
            cb({status = 'ok', message = 'Bomb planted. It will explode in 10 seconds!'})
        else
            cb({status = 'error', message = 'Vehicle not found'})
        end
    end
end)

RegisterNetEvent('hackphone:explosion')
AddEventHandler('hackphone:explosion', function(vehicleNetId, coords)
    local vehicle = NetToVeh(vehicleNetId)
    
    if DoesEntityExist(vehicle) then
        NetworkExplodeVehicle(vehicle, true, false, false)
        
        if coords then
            AddExplosion(coords.x, coords.y, coords.z, 7, 1.0, true, false, 1.0)
        end
        
        SetVehicleBodyHealth(vehicle, 0.0)
        SetVehicleEngineHealth(vehicle, 0.0)
        
        local playerCoords = GetEntityCoords(PlayerPedId())
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(playerCoords - vehicleCoords)
        
        if distance <= 50.0 then
            SendNUIMessage({
                data = 'addTerminalOutput',
                text = "A vehicle exploded nearby!",
                type = 'error'
            })
        end
    end
end)

RegisterNetEvent('hackphone:updateVehicleEngine')
AddEventHandler('hackphone:updateVehicleEngine', function(vehicleNetId, state)
    local vehicle = NetToVeh(vehicleNetId)
    
    if DoesEntityExist(vehicle) then
        SetVehicleEngineOn(vehicle, state, true, true)
        SetVehicleUndriveable(vehicle, not state)
    end
end)

RegisterNetEvent('hackphone:updateVehicleLights')
AddEventHandler('hackphone:updateVehicleLights', function(vehicleNetId, state)
    local vehicle = NetToVeh(vehicleNetId)
    
    if DoesEntityExist(vehicle) then
        SetVehicleLights(vehicle, state and 2 or 1)
        
        if state then
            SetVehicleLightMultiplier(vehicle, 1.0)
        end
    end
end)

RegisterNetEvent('hackphone:updateVehicleDoor')
AddEventHandler('hackphone:updateVehicleDoor', function(vehicleNetId, doorIndex, state)
    local vehicle = NetToVeh(vehicleNetId)
    
    if DoesEntityExist(vehicle) then
        if state then
            SetVehicleDoorOpen(vehicle, doorIndex, false, false)
        else
            SetVehicleDoorShut(vehicle, doorIndex, false)
        end
    end
end)

RegisterNetEvent('hackphone:updateVehicleLock')
AddEventHandler('hackphone:updateVehicleLock', function(vehicleNetId, lockState)
    local vehicle = NetToVeh(vehicleNetId)
    
    if DoesEntityExist(vehicle) then
        SetVehicleDoorsLocked(vehicle, lockState)
        
        local playerCoords = GetEntityCoords(PlayerPedId())
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(playerCoords - vehicleCoords)
        
        if distance <= 20.0 then
            PlayVehicleDoorCloseSound(vehicle, 1)
        end
    end
end)

RegisterNetEvent('hackphone:createMoneyProps')
AddEventHandler('hackphone:createMoneyProps', function(atmId, coords, count)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = #(playerCoords - vector3(coords.x, coords.y, coords.z))
    
    if distance <= 50.0 then
        if not activeMoneyProps[atmId] then
            activeMoneyProps[atmId] = {}
        end
        
        PlaySoundFrontend(-1, "ROBBERY_MONEY_TOTAL", "HUD_FRONTEND_CUSTOM_SOUNDSET", true)
        
        for i = 1, count do
            local prop = CreateMoneyProp(vector3(coords.x, coords.y, coords.z))
            if prop and DoesEntityExist(prop) then
                table.insert(activeMoneyProps[atmId], prop)
            end
            Citizen.Wait(50)
        end
    end
end)

RegisterNetEvent('hackphone:bombPlanted')
AddEventHandler('hackphone:bombPlanted', function(vehicleNetId, explosionTime)
    local vehicle = NetToVeh(vehicleNetId)
    
    if DoesEntityExist(vehicle) then
        local playerCoords = GetEntityCoords(PlayerPedId())
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(playerCoords - vehicleCoords)
        
        if distance <= 50.0 then
            SendNUIMessage({
                data = 'addTerminalOutput',
                text = "A bomb has been planted on a vehicle nearby!",
                type = 'warning'
            })
            
            if explosionTime then
                Citizen.CreateThread(function()
                    local startTime = GetGameTimer()
                    local endTime = startTime + explosionTime
                    
                    while GetGameTimer() < endTime and DoesEntityExist(vehicle) do
                        Citizen.Wait(1000)
                    end
                    
                    if DoesEntityExist(vehicle) then
                        local coords = GetEntityCoords(vehicle)
                        TriggerServerEvent('hackphone:syncExplosion', NetworkGetNetworkIdFromEntity(vehicle), coords)
                    end
                end)
            end
        end
    end
end)

RegisterNetEvent('hackphone:updateATMRobbery')
AddEventHandler('hackphone:updateATMRobbery', function(atmId, progress, isActive)
    if isActive then
        if activeRobberyMarkers[atmId] then
            activeRobberyMarkers[atmId].progress = progress
        else
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            for _, model in ipairs(atmModels) do
                local atms = GetGamePool('CObject')
                for _, atm in ipairs(atms) do
                    if GetEntityModel(atm) == model then
                        local atmCoords = GetEntityCoords(atm)
                        local atmIdCheck = tostring(atmCoords.x) .. tostring(atmCoords.y)
                        
                        if atmIdCheck == atmId then
                            activeRobberyMarkers[atmId] = {
                                id = atmId,
                                coords = atmCoords,
                                handle = atm,
                                blip = AddBlipForCoord(atmCoords.x, atmCoords.y, atmCoords.z),
                                progress = progress,
                                isActive = true
                            }
                            
                            SetBlipSprite(activeRobberyMarkers[atmId].blip, 500)
                            SetBlipColour(activeRobberyMarkers[atmId].blip, 1)
                            SetBlipScale(activeRobberyMarkers[atmId].blip, 0.8)
                            SetBlipAsShortRange(activeRobberyMarkers[atmId].blip, true)
                            BeginTextCommandSetBlipName("STRING")
                            AddTextComponentString("ATM Robbery in Progress")
                            EndTextCommandSetBlipName(activeRobberyMarkers[atmId].blip)
                            
                            break
                        end
                    end
                end
            end
        end
    else
        if activeRobberyMarkers[atmId] then
            if activeRobberyMarkers[atmId].blip then
                RemoveBlip(activeRobberyMarkers[atmId].blip)
            end
            activeRobberyMarkers[atmId] = nil
        end
    end
end)

local function getNearestATM()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local nearestATM = nil
    local minDistance = 2.0
    
    for _, model in ipairs(atmModels) do
        local atm = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, minDistance, model, false, false, false)
        if DoesEntityExist(atm) then
            local atmCoords = GetEntityCoords(atm)
            local distance = #(playerCoords - atmCoords)
            
            if distance < minDistance then
                local streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(atmCoords.x, atmCoords.y, atmCoords.z))
                nearestATM = {
                    handle = atm,
                    coords = atmCoords,
                    model = model,
                    distance = distance,
                    id = tostring(atmCoords.x) .. tostring(atmCoords.y),
                    location = streetName,
                    loot = math.random(30000, 90000)
                }
                minDistance = distance
            end
        end
    end
    
    return nearestATM
end

local function drawSkullMarker(coords)
    DrawMarker(
        1,
        coords.x, coords.y, coords.z + 1.0,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        0.5, 0.5, 0.5,
        255, 0, 0, 150,
        false,
        false,
        2,
        false,
        nil,
        nil,
        false
    )
end

function CreateMoneyProp(coords)
    local propModels = {
        `prop_money_bag_01`,
        `prop_cash_pile_02`,
        `hei_prop_heist_cash_pile`
    }
    
    local propModel = propModels[math.random(#propModels)]
    
    if not HasModelLoaded(propModel) then
        RequestModel(propModel)
        local timeout = GetGameTimer() + 3000
        while not HasModelLoaded(propModel) and GetGameTimer() < timeout do
            Citizen.Wait(0)
        end
    end
    
    if not HasModelLoaded(propModel) then
        print("Model could not be loaded: " .. propModel)
        return nil
    end
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    local atmObject = nil
    for _, model in ipairs(atmModels) do
        atmObject = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.0, model, false, false, false)
        if DoesEntityExist(atmObject) then
            break
        end
    end
    
    local spawnX, spawnY, spawnZ
    
    if DoesEntityExist(atmObject) then
        local atmHeading = GetEntityHeading(atmObject)
        
        spawnX = coords.x + math.sin(math.rad(atmHeading)) * 1.0 + math.random(-50, 50) / 100.0
        spawnY = coords.y - math.cos(math.rad(atmHeading)) * 1.0 + math.random(-50, 50) / 100.0
        spawnZ = coords.z + 0.2 + math.random(-20, 20) / 100.0
    else
        local radius = 1.5
        local angle = math.random() * 2 * math.pi
        spawnX = playerCoords.x + radius * math.cos(angle)
        spawnY = playerCoords.y + radius * math.sin(angle)
        spawnZ = playerCoords.z + 0.2
    end
    
    local prop = nil
    
    prop = CreateObjectNoOffset(propModel, spawnX, spawnY, spawnZ, true, false, false)
    
    if not DoesEntityExist(prop) then
        prop = CreateObject(propModel, spawnX, spawnY, spawnZ, true, true, false)
    end
    
    if not DoesEntityExist(prop) then
        print("Prop could not be created!")
        return nil
    end
    
    print("Money prop created: " .. prop .. " - Location: " .. spawnX .. ", " .. spawnY .. ", " .. spawnZ)
    
    SetEntityVisible(prop, true, false)
    SetEntityAlpha(prop, 255, false)
    SetEntityDynamic(prop, true)
    SetEntityHasGravity(prop, true)
    SetEntityCollision(prop, true, true)
    SetEntityCoordsNoOffset(prop, spawnX, spawnY, spawnZ, false, false, false)
    
    SetEntityRotation(prop, math.random(0, 360) + 0.0, math.random(0, 360) + 0.0, math.random(0, 360) + 0.0, 2, true)
    
    local force = 2.0
    ApplyForceToEntity(
        prop,
        1,
        math.random(-10, 10) / 10.0 * force,
        math.random(-10, 10) / 10.0 * force,
        math.random(5, 10) / 10.0 * force,
        0.0, 0.0, 0.0,
        0,
        false, true, true, false, true
    )
    
    SetModelAsNoLongerNeeded(propModel)
    
    Citizen.SetTimeout(30000, function()
        if DoesEntityExist(prop) then
            DeleteObject(prop)
        end
    end)
    
    return prop
end

RegisterNUICallback('robATM', function(data, cb)
    local atm = getNearestATM()
    
    if not atm then
        cb({ success = false, message = 'ATM not found!' })
        return
    end
    
    local atmIdStr = tostring(atm.id)
    if robbedATMs[atmIdStr] then
        cb({ success = false, message = 'This ATM has already been robbed!' })
        return
    end

    local amount = data.estimatedLoot or math.random(30000, 90000)
    local hackingTime = 30000
    local progress = 0
    local markerId = atmIdStr
    
    robbedATMs[atmIdStr] = true
    
    TriggerServerEvent('hackphone:markATMRobbed', atmIdStr)
    
    activeRobberyMarkers[markerId] = {
        id = markerId,
        coords = atm.coords,
        handle = atm.handle,
        blip = AddBlipForCoord(atm.coords.x, atm.coords.y, atm.coords.z),
        progress = 0,
        isActive = true
    }
    
    activeMoneyProps[markerId] = {}
    
    local propStages = {
        { level = 25, count = 4, message = "First money started dropping from the ATM!" },
        { level = 50, count = 7, message = "Money flow is accelerating!" },
        { level = 75, count = 10, message = "Large amount of money is pouring from the ATM!" },
        { level = 100, count = 15, message = "Robbery completed! All money has been seized!" }
    }
    local completedStages = {}

    SendNUIMessage({
        data = 'atmTransferUpdate',
        progress = 0,
        transferAmount = 0,
        remainingLoot = amount
    })
    
    SendNUIMessage({
        data = 'addTerminalOutput',
        text = "ATM Robbery Progress: 0%",
        type = 'info'
    })

    SendNUIMessage({
        data = 'addTerminalOutput',
        text = "Transferred: $0 - Remaining: $" .. amount,
        type = 'info'
    })

    Citizen.CreateThread(function()
        local updateInterval = 300
        local totalUpdates = hackingTime / updateInterval
        local progressPerUpdate = 100 / totalUpdates
        
        while progress < 100 and activeRobberyMarkers[markerId] do
            Citizen.Wait(updateInterval)
            
            progress = progress + progressPerUpdate
            if progress > 100 then progress = 100 end
            
            print("ATM Robbery Progress: " .. progress .. "%")
            
            local transferAmount = math.floor((progress / 100) * amount)
            local remainingLoot = amount - transferAmount
            
            SendNUIMessage({
                data = 'atmTransferUpdate',
                progress = progress,
                transferAmount = transferAmount,
                remainingLoot = remainingLoot
            })
            
            if math.floor(progress) % 10 == 0 then
                TriggerServerEvent('hackphone:syncATMRobbery', markerId, progress, true)
            end
            
            for _, stage in ipairs(propStages) do
                if progress >= stage.level and not completedStages[stage.level] then
                    completedStages[stage.level] = true
                    
                    PlaySoundFrontend(-1, "ROBBERY_MONEY_TOTAL", "HUD_FRONTEND_CUSTOM_SOUNDSET", true)
                    
                    SendNUIMessage({
                        data = 'addTerminalOutput',
                        text = stage.message,
                        type = 'info'
                    })
                    
                    TriggerServerEvent('hackphone:syncMoneyProps', markerId, atm.coords, stage.count)
                    
                    break
                end
            end
        end

        if progress >= 100 then
            SendNUIMessage({
                data = 'atmTransferUpdate',
                progress = 100,
                transferAmount = amount,
                remainingLoot = 0
            })
            
            SendNUIMessage({
                data = 'atmRobComplete',
                amount = amount,
                atmId = atm.id
            })
            
            TriggerServerEvent('hackphone:syncATMRobbery', markerId, 100, false)
            
            print("Sending money directly to the server: " .. amount)
            TriggerServerEvent('hackphone:giveATMMoney', {
                amount = amount,
                atmId = atm.id
            })
        end
    end)

    cb({ 
        success = true, 
        message = 'ATM hack initiated...',
        time = hackingTime / 1000,
        coords = atm.coords
    })
end)

RegisterNetEvent('hackphone:syncRobbedATMs')
AddEventHandler('hackphone:syncRobbedATMs', function(robbedList)
    if not robbedList then
        robbedATMs = {}
        return
    end
    
    robbedATMs = robbedList
    
    local count = 0
    for _ in pairs(robbedATMs) do count = count + 1 end
    print("Soyulan ATM listesi güncellendi: " .. count .. " adet ATM")
    
    SendNUIMessage({
        data = 'syncRobbedATMs',
        robbedATMs = robbedATMs
    })
end)

RegisterNUICallback('getNearestATM', function(data, cb)
    local atm = getNearestATM()
    cb({
        success = true,
        atm = atm
    })
end)

RegisterNUICallback('scanATMs', function(data, cb)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local nearbyATMs = {}
    
    for _, model in ipairs(atmModels) do
        local atms = GetGamePool('CObject')
        for _, atm in ipairs(atms) do
            if GetEntityModel(atm) == model then
                local atmCoords = GetEntityCoords(atm)
                local distance = #(playerCoords - atmCoords)
                
                if distance <= 20.0 then
                    local atmId = tostring(atmCoords.x) .. tostring(atmCoords.y)
                    local atmData = {
                        id = atmId,
                        name = "ATM",
                        location = GetStreetNameFromHashKey(GetStreetNameAtCoord(atmCoords.x, atmCoords.y, atmCoords.z)),
                        coords = atmCoords,
                        distance = distance,
                        loot = math.random(30000, 90000),
                        isRobbed = robbedATMs[atmId] or false
                    }
                    table.insert(nearbyATMs, atmData)
                end
            end
        end
    end
    
    cb({
        success = true,
        atms = nearbyATMs
    })
end)

function clearMoneyProps(markerId)
    if activeMoneyProps[markerId] then
        for _, prop in ipairs(activeMoneyProps[markerId]) do
            if DoesEntityExist(prop) then
                DeleteObject(prop)
            end
        end
        activeMoneyProps[markerId] = nil
    end
end

_G.clearMoneyProps = clearMoneyProps

RegisterNUICallback('clearMoneyProps', function(data, cb)
    local markerId = data.markerId
    clearMoneyProps(markerId)
    cb({success = true})
end)

RegisterNUICallback('createMoneyProp', function(data, cb)
    local atmId = data.atmId
    local coords = data.coords
    
    if coords then
        local prop = CreateMoneyProp(vector3(coords.x, coords.y, coords.z))
        if prop and DoesEntityExist(prop) then
            if not activeMoneyProps[atmId] then
                activeMoneyProps[atmId] = {}
            end
            table.insert(activeMoneyProps[atmId], prop)
        end
    end
    
    cb({success = true})
end)

RegisterNUICallback('createMoneyPropBurst', function(data, cb)
    local atmId = data.atmId
    local burstCount = data.count or 10
    
    local atmCoords = nil
    
    for markerId, marker in pairs(activeRobberyMarkers) do
        if markerId == atmId then
            atmCoords = marker.coords
            break
        end
    end
    
    if not atmCoords then
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        for _, model in ipairs(atmModels) do
            local atm = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 50.0, model, false, false, false)
            if DoesEntityExist(atm) then
                local coords = GetEntityCoords(atm)
                local id = tostring(coords.x) .. tostring(coords.y)
                if id == atmId then
                    atmCoords = coords
                    break
                end
            end
        end
    end
    
    if atmCoords then
        if not activeMoneyProps[atmId] then
            activeMoneyProps[atmId] = {}
        end
        
        PlaySoundFrontend(-1, "ROBBERY_MONEY_TOTAL", "HUD_FRONTEND_CUSTOM_SOUNDSET", true)
        
        for i = 1, burstCount do
            local prop = CreateMoneyProp(atmCoords)
            if prop and DoesEntityExist(prop) then
                table.insert(activeMoneyProps[atmId], prop)
            end
            Citizen.Wait(50)
        end
        
        cb({success = true, count = #activeMoneyProps[atmId]})
    else
        print("ATM coordinates not found: " .. atmId)
        cb({success = false, error = "ATM coordinates not found"})
    end
end)

RegisterNUICallback('addTerminalMessage', function(data, cb)
    local message = data.message
    local type = data.type or 'info'
    
    if message then
        SendNUIMessage({
            data = 'terminalUpdate',
            message = message,
            type = type
        })
    end
    
    cb({success = true})
end)

RegisterNUICallback('playSound', function(data, cb)
    local sound = data.sound
    local soundSet = data.soundSet
    
    if sound and soundSet then
        PlaySoundFrontend(-1, sound, soundSet, true)
    end
    
    cb({success = true})
end)

RegisterNUICallback('forceCreateMoneyProps', function(data, cb)
    local atmId = data.atmId
    local count = data.count or 5
    local coords = data.coords
    
    if not coords then
        cb({success = false, message = "No coordinates provided"})
        return
    end
    
    if not activeMoneyProps[atmId] then
        activeMoneyProps[atmId] = {}
    end
    
    PlaySoundFrontend(-1, "ROBBERY_MONEY_TOTAL", "HUD_FRONTEND_CUSTOM_SOUNDSET", true)
    
    local createdProps = 0
    for i = 1, count do
        local prop = CreateMoneyProp(vector3(coords.x, coords.y, coords.z))
        if prop and DoesEntityExist(prop) then
            table.insert(activeMoneyProps[atmId], prop)
            createdProps = createdProps + 1
        end
        Citizen.Wait(10)
    end
    
    print("Number of props created: " .. createdProps)
    
    cb({success = true, count = createdProps})
end)

function CreateMoneyPropAlternative(coords)
    local propModel = `hei_prop_heist_cash_pile`
    
    RequestModel(propModel)
    while not HasModelLoaded(propModel) do
        Citizen.Wait(0)
    end
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    local radius = 1.5
    local angle = math.random() * 2 * math.pi
    local spawnX = playerCoords.x + radius * math.cos(angle)
    local spawnY = playerCoords.y + radius * math.sin(angle)
    local spawnZ = playerCoords.z
    
    local prop = CreateObject(propModel, spawnX, spawnY, spawnZ, true, true, true)
    
    if not DoesEntityExist(prop) then
        print("Prop could not be created!")
        return nil
    end
    
    SetEntityVisible(prop, true, false)
    SetEntityAlpha(prop, 255, false)
    SetEntityDynamic(prop, true)
    SetEntityHasGravity(prop, true)
    SetEntityCollision(prop, true, true)
    
    SetEntityRotation(prop, math.random(0, 360) + 0.0, math.random(0, 360) + 0.0, math.random(0, 360) + 0.0, 2, true)
    
    local force = 1.5
    ApplyForceToEntity(
        prop,
        1,
        math.random(-10, 10) / 10.0 * force,
        math.random(-10, 10) / 10.0 * force,
        math.random(5, 10) / 10.0 * force,
        0.0, 0.0, 0.0,
        0,
        false, true, true, false, true
    )
    
    SetModelAsNoLongerNeeded(propModel)
    
    Citizen.SetTimeout(30000, function()
        if DoesEntityExist(prop) then
            DeleteObject(prop)
        end
    end)
    
    return prop
end

RegisterCommand('testmoneybag', function(source, args)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    local forward = GetEntityForwardVector(playerPed)
    local testCoords = vector3(
        playerCoords.x + forward.x * 2.0,
        playerCoords.y + forward.y * 2.0,
        playerCoords.z
    )
    
    local propModel = `prop_money_bag_01`
    RequestModel(propModel)
    while not HasModelLoaded(propModel) do
        Citizen.Wait(0)
    end
    
    local prop = CreateObject(propModel, testCoords.x, testCoords.y, testCoords.z, true, true, true)
    
    if DoesEntityExist(prop) then
        print("Test money bag created: " .. prop)
    else
        print("Test money bag could not be created!")
    end
end, false)

function CreateMoneyPropV3(coords)
    local propModel = `hei_prop_heist_cash_pile`
    
    RequestModel(propModel)
    while not HasModelLoaded(propModel) do
        Citizen.Wait(0)
    end
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    local radius = 2.0
    local angle = math.random() * 2 * math.pi
    local spawnX = playerCoords.x + radius * math.cos(angle)
    local spawnY = playerCoords.y + radius * math.sin(angle)
    local spawnZ = playerCoords.z - 0.5
    
    local prop = CreateObject(propModel, spawnX, spawnY, spawnZ, true, true, true)
    
    if not DoesEntityExist(prop) then
        print("Prop could not be created!")
        return nil
    end
    
    print("Money prop created (V3): " .. prop)
    
    SetEntityDynamic(prop, true)
    SetEntityHasGravity(prop, true)
    
    Citizen.SetTimeout(30000, function()
        if DoesEntityExist(prop) then
            DeleteObject(prop)
        end
    end)
    
    return prop
end

function CreateMoneyPropAroundPlayer(count)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local props = {}
    
    local propModels = {
        `prop_money_bag_01`,
        `prop_cash_pile_02`,
        `hei_prop_heist_cash_pile`
    }
    
    for i = 1, count do
        local propModel = propModels[math.random(#propModels)]
        
        if not HasModelLoaded(propModel) then
            RequestModel(propModel)
            local timeout = GetGameTimer() + 3000
            while not HasModelLoaded(propModel) and GetGameTimer() < timeout do
                Citizen.Wait(0)
            end
        end
        
        if not HasModelLoaded(propModel) then
            print("Model could not be loaded: " .. propModel)
            goto continue
        end
        
        local radius = 1.5
        local angle = math.random() * 2 * math.pi
        local spawnX = playerCoords.x + radius * math.cos(angle)
        local spawnY = playerCoords.y + radius * math.sin(angle)
        local spawnZ = playerCoords.z + 0.2
        
        local prop = CreateObject(propModel, spawnX, spawnY, spawnZ, true, true, false)
        
        if not DoesEntityExist(prop) then
            print("Prop could not be created!")
            goto continue
        end
        
        SetEntityVisible(prop, true, false)
        SetEntityAlpha(prop, 255, false)
        SetEntityDynamic(prop, true)
        SetEntityHasGravity(prop, true)
        SetEntityCollision(prop, true, true)
        
        SetEntityRotation(prop, math.random(0, 360) + 0.0, math.random(0, 360) + 0.0, math.random(0, 360) + 0.0, 2, true)
        
        local force = 1.5
        ApplyForceToEntity(
            prop,
            1,
            math.random(-10, 10) / 10.0 * force,
            math.random(-10, 10) / 10.0 * force,
            math.random(5, 10) / 10.0 * force,
            0.0, 0.0, 0.0,
            0,
            false, true, true, false, true
        )
        
        SetModelAsNoLongerNeeded(propModel)
        
        table.insert(props, prop)
        
        Citizen.SetTimeout(30000, function()
            if DoesEntityExist(prop) then
                DeleteObject(prop)
            end
        end)
        
        Citizen.Wait(50)
        
        ::continue::
    end
    
    return props
end

RegisterNUICallback('createMoneyPropsAroundPlayer', function(data, cb)
    local count = data.count or 10
    
    PlaySoundFrontend(-1, "ROBBERY_MONEY_TOTAL", "HUD_FRONTEND_CUSTOM_SOUNDSET", true)
    
    local props = CreateMoneyPropAroundPlayer(count)
    
    print("Number of props created: " .. #props)
    
    cb({success = true, count = #props})
end)

RegisterNUICallback('atmRobComplete', function(data, cb)
    local amount = data.amount
    local atmId = data.atmId
    
    if not amount or amount <= 0 then
        cb({ success = false, message = 'Invalid money amount!' })
        return
    end
    
    print("ATM robbery completed:")
    print("Amount: " .. amount)
    print("ATM ID: " .. atmId)
    
    TriggerServerEvent('hackphone:giveATMMoney', {
        amount = amount,
        atmId = atmId
    })
    
    cb({ success = true, message = 'Robbery completed! You earned $' .. amount .. '!' })
end)

function SetVehicleEngineState(vehicle, state)
    if not DoesEntityExist(vehicle) then return false end
    
    SetVehicleEngineOn(vehicle, state, true, true)
    SetVehicleUndriveable(vehicle, not state)
    
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if NetworkDoesNetworkIdExist(netId) then
        SetNetworkIdCanMigrate(netId, true)
        NetworkRequestControlOfNetworkId(netId)
        
        local timeout = GetGameTimer() + 5000
        while not NetworkHasControlOfNetworkId(netId) and GetGameTimer() < timeout do
            Citizen.Wait(100)
        end
        
        if NetworkHasControlOfNetworkId(netId) then
            SetVehicleEngineOn(vehicle, state, true, true)
            SetVehicleJetEngineOn(vehicle, state)
            SetVehicleUndriveable(vehicle, not state)
            return true
        end
    end
    
    return false
end

function SetVehicleLightsState(vehicle, state)
    if not DoesEntityExist(vehicle) then return false end
    
    SetVehicleLights(vehicle, state and 2 or 1)
    
    if state then
        SetVehicleLightMultiplier(vehicle, 1.0)
    end
    
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if NetworkDoesNetworkIdExist(netId) then
        SetNetworkIdCanMigrate(netId, true)
        NetworkRequestControlOfNetworkId(netId)
        
        local timeout = GetGameTimer() + 5000
        while not NetworkHasControlOfNetworkId(netId) and GetGameTimer() < timeout do
            Citizen.Wait(100)
        end
        
        if NetworkHasControlOfNetworkId(netId) then
            SetVehicleLights(vehicle, state and 2 or 1)
            if state then
                SetVehicleLightMultiplier(vehicle, 1.0)
            end
            return true
        end
    end
    
    return false
end

RegisterNUICallback('markATMRobbed', function(data, cb)
    local atmId = data.atmId
    
    if atmId then
        robbedATMs[atmId] = true
        TriggerServerEvent('hackphone:markATMRobbed', atmId)
        cb({success = true})
    else
        cb({success = false, message = "No ATM ID provided"})
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(2000) 
    TriggerServerEvent('hackphone:requestRobbedATMs')
    print("ATM list requested at client startup")
end)

RegisterNUICallback('getBlackMarketItems', function(data, cb)
    if not data or not data.items or #data.items == 0 then
        print("Geçersiz Black Market verileri!")
        cb({ success = false, message = 'Geçersiz Black Market verileri!' })
        return
    end
    local totalCost = data.totalCost or 0
    for i, item in ipairs(data.items) do
        print(string.format("Ürün #%d: %s (Model: %s) - Miktar: %d - Fiyat: $%d", 
            i, item.name, item.model, item.count, item.price))
    end
    TriggerServerEvent('blackmarket:purchaseItems', data.items, totalCost)
    cb({ success = true, message = 'Satın alma işlemi tamamlandı!' })
end)

RegisterNetEvent('blackmarket:syncStockData')
AddEventHandler('blackmarket:syncStockData', function(stockData)
    SendNUIMessage({
        data = 'updateBlackMarketStock',
        stockData = stockData
    })
end)

RegisterNUICallback('purchaseBlackMarketItems', function(data, cb)
    if not data or not data.items or #data.items == 0 then
        print("Geçersiz Black Market verileri!")
        cb({ success = false, message = 'Geçersiz Black Market verileri!' })
        return
    end
    local totalCost = data.totalCost or 0
    for i, item in ipairs(data.items) do
        print(string.format("^5[%d] %s x%d - $%d - Model: %s^7", 
            i, item.name, item.count, item.price, item.model or "N/A"))
    end
    Callback('Buy', function(result)
        if result and result.success then
            TriggerEvent("chatMessage", "BLACK MARKET", {0, 255, 0}, "Satın alma işlemi tamamlandı! Toplam: $" .. totalCost)
            PlaySoundFrontend(-1, "PURCHASE", "HUD_LIQUOR_STORE_SOUNDSET", true)
            if result.items then
                Config['Black Market Items'] = result.items
            end
            cb({ success = true, message = 'Satın alma işlemi tamamlandı!' })
        else
            cb({ success = false, message = result.message or 'Satın alma işlemi başarısız!' })
        end
    end, data.items)
end)
