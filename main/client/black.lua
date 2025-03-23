Framework = nil
Framework = GetFramework()

Citizen.CreateThread(function()
    while Framework == nil do Citizen.Wait(750) end
    Citizen.Wait(2500)
end)

local dealerPed, dealerBlip = nil, nil
local isEnroute = false
local activeVehicle = nil
local activeDelivery = false
local weaponDelivered = false
local deliveryInProgress = false
local pendingDelivery = false

RegisterNUICallback('purchaseBlackMarketItems', function(data, cb)
    print("^2[DEBUG] purchaseBlackMarketItems NUI callback called")
    print("^3[DEBUG] Received data: " .. json.encode(data))
    
    if deliveryInProgress or pendingDelivery then
        print("^1[ERROR] Purchase rejected - delivery already in progress")
        cb({success = false, message = 'There is already an active delivery in progress. Please wait until it is completed before ordering again.'})
        TriggerEvent("chatMessage", "BLACK MARKET", {255, 0, 0}, "You already have an active delivery. Wait for it to complete before placing a new order.")
        return
    end
    
    if not data or not data.items or #data.items == 0 then
        print("^1[ERROR] Cart empty or no data!")
        cb({success = false, message = 'Cart is empty! No items to purchase.'})
        return
    end
    
    cb({success = true, message = "Your transaction has been received, please wait..."})
    
    print("^2[DEBUG] Sending directBuy event to server...")
    
    TriggerServerEvent('blackmarket:directBuy', data.items, function(result)
        print("^2[DEBUG] directBuy event sent")
    end)
    
    print("^2[DEBUG] Purchase completed, adding items to delivery queue")
    
    if not Config.PurchasedItems then Config.PurchasedItems = {} end
    
    for i, item in ipairs(data.items) do
        local itemData = {
            id = item.id,
            name = item.name or "Unknown Item",
            model = item.model or "unknown_model",
            count = item.count or 1,
            price = item.price or 0,
            category = item.category or ""
        }
        
        if itemData.category == "" then
            for _, marketItem in ipairs(Config['Black Market Items']) do
                if marketItem.id == item.id then
                    itemData.category = marketItem.category
                    break
                end
            end
        end
        
        table.insert(Config.PurchasedItems, itemData)
        
        print(string.format("^3[DEBUG] [%d] %s x%d ($%d) - Model: %s - Category: %s", 
            i, itemData.name, itemData.count, itemData.price, itemData.model, itemData.category))
    end
    
    print("^2[DEBUG] PurchasedItems list updated. Total: " .. #Config.PurchasedItems .. " items")
    
    TriggerEvent("chatMessage", "BLACK MARKET", {0, 255, 0}, 
        "Your order has been received! Total: $" .. (data.totalCost or 0) .. " - The delivery vehicle is on its way!")
    
    PlaySoundFrontend(-1, "PURCHASE", "HUD_LIQUOR_STORE_SOUNDSET", true)
    
    pendingDelivery = true
    Citizen.SetTimeout(3000, function()
        if not deliveryInProgress then
            pendingDelivery = false
            deliveryInProgress = true
            StartDeliveryProcess()
        end
    end)
end)

RegisterNetEvent('blackmarket:buyResponse')
AddEventHandler('blackmarket:buyResponse', function(result)
    print("^2[DEBUG] blackmarket:buyResponse event triggered: " .. json.encode(result))
    
    if result and result.success then
        print("^2[DEBUG] Purchase confirmed by server")
        
        if result.items then
            Config['Black Market Items'] = result.items
            print("^2[DEBUG] Black market item stocks updated")
        end
        
        TriggerEvent("chatMessage", "BLACK MARKET", {0, 255, 0}, 
            "Purchase completed! The delivery vehicle is on its way...")
        
        if not deliveryInProgress and not pendingDelivery then
            pendingDelivery = true
            Citizen.SetTimeout(3000, function()
                if not deliveryInProgress then
                    pendingDelivery = false
                    deliveryInProgress = true
                    StartDeliveryProcess()
                end
            end)
        else
            print("^3[DEBUG] Delivery already in progress, not starting a new one")
            TriggerEvent("chatMessage", "BLACK MARKET", {255, 165, 0}, 
                "Your purchase has been processed, but there is already an active delivery. Items will be delivered with the current shipment.")
        end
    else
        print("^1[ERROR] Purchase rejected: " .. (result.message or "Unknown error"))
        TriggerEvent("chatMessage", "BLACK MARKET", {255, 0, 0}, 
            "Purchase failed: " .. (result.message or "Transaction rejected!"))
    end
end)

RegisterCommand("buyblackmarket", function(source, args)
    if deliveryInProgress or pendingDelivery then
        TriggerEvent("chatMessage", "BLACK MARKET", {255, 0, 0}, "You already have an active delivery. Wait for it to complete before placing a new order.")
        return
    end
    
    if args[1] then
        local itemId = tonumber(args[1])
        if itemId then
            print("^2[DEBUG] Command purchase: Item ID " .. itemId)
            
            local foundItem = nil
            for _, item in ipairs(Config['Black Market Items']) do
                if item.id == itemId then
                    foundItem = item
                    break
                end
            end
            
            if foundItem then
                local testData = {
                    items = {
                        {
                            id = foundItem.id, 
                            name = foundItem.name,
                            model = foundItem.model,
                            count = 1,
                            price = foundItem.price,
                            category = foundItem.category
                        }
                    },
                    totalCost = foundItem.price
                }
                
                if not Config.PurchasedItems then Config.PurchasedItems = {} end
                table.insert(Config.PurchasedItems, testData.items[1])
                
                TriggerEvent("chatMessage", "BLACK MARKET", {0, 255, 0}, "Test purchase: " .. foundItem.name)
                print("^2[DEBUG] Test item added to delivery queue")
                
                pendingDelivery = true
                Citizen.SetTimeout(1000, function()
                    if not deliveryInProgress then
                        pendingDelivery = false
                        deliveryInProgress = true
                        StartDeliveryProcess()
                    end
                end)
            else
                TriggerEvent("chatMessage", "BLACK MARKET", {255, 0, 0}, "Item not found: ID " .. itemId)
            end
        end
    else
        TriggerEvent("chatMessage", "BLACK MARKET", {255, 255, 0}, "Usage: /buyblackmarket [ItemID]")
    end
end, false)

function StartDeliveryProcess()
    print("^3[DEBUG] StartDeliveryProcess called")
    
    if #Config.PurchasedItems == 0 then
        print("^1[ERROR] No items to deliver, canceling delivery")
        TriggerEvent("chatMessage", "BLACK MARKET", {255, 0, 0}, "No orders found for delivery!")
        CleanupDelivery()
        return
    end
    
    CleanupDelivery(true)
    
    activeDelivery = true
    
    Citizen.SetTimeout(5 * 60 * 1000, function()
        if activeDelivery and not weaponDelivered then
            TriggerEvent("chatMessage", "BLACK MARKET", {255, 0, 0}, "The delivery timed out and has been canceled.")
            CleanupDelivery()
        end
    end)
    
    print("^3[DEBUG] Calling CreateDeliveryVehicle...")
    Citizen.Wait(1000)
    CreateDeliveryVehicle()
    
    TriggerEvent("chatMessage", "BLACK MARKET", {255, 165, 0}, 
        "The delivery vehicle is on its way! Go to the marked location on the map.")
end

RegisterCommand("weapondelivery", function() 
    if deliveryInProgress then
        TriggerEvent("chatMessage", "BLACK MARKET", {255, 0, 0}, "A delivery is already in progress!")
        return
    end
    
    local player = PlayerPedId()
    if not player or not DoesEntityExist(player) then
        TriggerEvent("chatMessage", "BLACK MARKET", {255, 0, 0}, "Player not found!")
        return
    end
    
    if IsPedInAnyVehicle(player, false) then
        TriggerEvent("chatMessage", "BLACK MARKET", {255, 0, 0}, "You cannot start a delivery while in a vehicle!")
        return
    end
    
    if Config.PurchasedItems and #Config.PurchasedItems > 0 then
        deliveryInProgress = true
        StartDeliveryProcess()
    else
        TriggerEvent("chatMessage", "BLACK MARKET", {255, 0, 0}, "No active orders for delivery found!")
    end
end, false)

RegisterNetEvent("blackmarket:start")
AddEventHandler("blackmarket:start", function()
    print("^2[DEBUG] blackmarket:start event triggered")
    
    if not deliveryInProgress and not pendingDelivery then
        if Config.PurchasedItems and #Config.PurchasedItems > 0 then
            deliveryInProgress = true
            StartDeliveryProcess()
        else
            print("^1[DEBUG] No purchased items to deliver")
        end
    else
        print("^1[DEBUG] Delivery already in progress or pending, not starting again")
    end
end)

function CreateDeliveryVehicle()
    print("^3[DEBUG] CreateDeliveryVehicle started")
    local player = PlayerPedId()
    if not player then 
        print("^1[ERROR] Player not found")
        CleanupDelivery()
        return 
    end
    local playerPos = GetEntityCoords(player)
    if not playerPos then
        print("^1[ERROR] Could not get player coordinates")
        CleanupDelivery()
        return
    end
    local driverModel = "g_m_y_mexgoon_01"
    local vehicleModel = "tampa"
    if Config and Config.Dealer then
        if Config.Dealer.npc and type(Config.Dealer.npc) == "string" then
            driverModel = Config.Dealer.npc
        end
        
        if Config.Dealer.vehicle and type(Config.Dealer.vehicle) == "string" then
            vehicleModel = Config.Dealer.vehicle
        end
    end
    print("^3[DEBUG] Driver Model: " .. driverModel .. ", Vehicle Model: " .. vehicleModel)
    local driverHash = GetHashKey(driverModel)
    local vehicleHash = GetHashKey(vehicleModel)
    RequestModel(driverHash)
    RequestModel(vehicleHash)
    print("^3[DEBUG] Loading models...")
    local timeout = 0
    local modelLoaded = false
    while timeout < 50 do
        if HasModelLoaded(driverHash) and HasModelLoaded(vehicleHash) then
            modelLoaded = true
            print("^2[DEBUG] Models loaded!")
            break
        end
        Citizen.Wait(100)
        timeout = timeout + 1
        
        if timeout % 10 == 0 then
            print("^3[DEBUG] Waiting for models to load... " .. timeout)
        end
    end
    if not modelLoaded then
        print("^1[ERROR] Models failed to load!")
        TriggerEvent("chatMessage", "BLACK MARKET", {255, 0, 0}, "Failed to load models. Please try again later.")
        CleanupDelivery()
        return
    end
    print("^2[DEBUG] Creating vehicle...")
    SpawnVehicle(playerPos, vehicleHash, driverHash, vehicleModel)
    SetModelAsNoLongerNeeded(driverHash)
    SetModelAsNoLongerNeeded(vehicleHash)
end

function SpawnVehicle(playerPos, vehicleHash, driverHash, vehicleModel)
    local player = PlayerPedId()
    if not player then 
        CleanupDelivery()
        return 
    end
    local heading = GetEntityHeading(player)
    local spawnDistance = 100.0
    local offset = vector3(
        math.sin(math.rad(heading)) * -spawnDistance, 
        math.cos(math.rad(heading)) * -spawnDistance, 
        0.0
    )
    local spawnPos = vector3(playerPos.x + offset.x, playerPos.y + offset.y, playerPos.z)
    local success, groundZ = GetGroundZFor_3dCoord(spawnPos.x, spawnPos.y, spawnPos.z + 5.0, false)
    if success then
        spawnPos = vector3(spawnPos.x, spawnPos.y, groundZ + 0.5)
    end
    local vehicle = CreateVehicle(vehicleHash, spawnPos.x, spawnPos.y, spawnPos.z, heading, true, false)
    if not DoesEntityExist(vehicle) then
        TriggerEvent("chatMessage", "BLACK MARKET", {255, 0, 0}, "Vehicle could not be created. Try again.")
        CleanupDelivery()
        return
    end
    activeVehicle = vehicle
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleNumberPlateText(vehicle, "BLCKSHP")
    SetVehicleColours(vehicle, 0, 0)
    SetVehicleEngineOn(vehicle, true, true, false)
    local driver = CreatePedInsideVehicle(vehicle, 26, driverHash, -1, true, false)
    if not DoesEntityExist(driver) then
        DeleteVehicle(vehicle)
        TriggerEvent("chatMessage", "BLACK MARKET", {255, 0, 0}, "Driver could not be created. Try again.")
        CleanupDelivery()
        return
    end
    dealerPed = driver
    SetEntityAsMissionEntity(driver, true, true)
    SetBlockingOfNonTemporaryEvents(driver, true)
    SetPedCanBeTargetted(driver, false)
    SetPedCanRagdoll(driver, false)
    SetEntityInvincible(driver, true)
    SetDriverAbility(driver, 1.0)
    SetDriverAggressiveness(driver, 0.0)
    if Config and Config.Blip then
        dealerBlip = AddBlipForEntity(vehicle)
        SetBlipSprite(dealerBlip, Config.Blip.Sprite or 1)
        SetBlipDisplay(dealerBlip, Config.Blip.Display or 4)
        SetBlipScale(dealerBlip, Config.Blip.Scale or 0.8)
        SetBlipColour(dealerBlip, Config.Blip.Color or 1)
        SetBlipFlashes(dealerBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.Blip.Label or "Weapon Dealer")
        EndTextCommandSetBlipName(dealerBlip)

        SetBlipRoute(dealerBlip, true)
        SetBlipRouteColour(dealerBlip, 1) 
    end
    TriggerEvent("chatMessage", "BLACK MARKET", {0, 0, 0}, "^1Weapon dealer is on the way. Follow the marked vehicle on the map.")
    isEnroute = true
    Citizen.Wait(500)
    StartDrivingToPlayer(player, vehicle, driver, vehicleModel)
end

function StartDrivingToPlayer(targetPlayer, vehicle, driver, vehicleModel)
    if not DoesEntityExist(vehicle) or not DoesEntityExist(driver) then 
        CleanupDelivery()
        return 
    end
    
    Citizen.CreateThread(function()
        local stuckCounter = 0
        local lastPos = GetEntityCoords(vehicle)
        local lastUpdateTime = GetGameTimer()
        local failsafeCounter = 0
        while isEnroute and DoesEntityExist(vehicle) and DoesEntityExist(driver) and activeDelivery do
            Citizen.Wait(1000)
            failsafeCounter = failsafeCounter + 1
            if failsafeCounter > 300 then
                if DoesEntityExist(vehicle) and DoesEntityExist(driver) then
                    ArriveAtDeliveryPoint(vehicle, driver, vehicleModel)
                else
                    CleanupDelivery()
                end
                return 
            end
            if not DoesEntityExist(targetPlayer) then
                targetPlayer = PlayerPedId()
                if not DoesEntityExist(targetPlayer) then
                    CleanupDelivery()
                    return 
                end
            end
            local targetPos = GetEntityCoords(targetPlayer)
            local vehiclePos = GetEntityCoords(vehicle)
            if not targetPos or not vehiclePos then
                Citizen.Wait(500)
            else
                local distanceToTarget = #(targetPos - vehiclePos)
                local currentTime = GetGameTimer()
                local timeDiff = (currentTime - lastUpdateTime) / 1000
                if timeDiff <= 0 then timeDiff = 1.0 end
                local distanceMoved = #(vehiclePos - lastPos)
                local speed = distanceMoved / timeDiff
                if speed < 1.0 and distanceToTarget > 20.0 then
                    stuckCounter = stuckCounter + 1
                    if stuckCounter > 3 then
                        local offset = SafeNormalize(vector3(
                            math.random(-20, -10), 
                            math.random(-20, -10), 
                            0.0
                        ))
                        local newPos = vector3(
                            targetPos.x + (offset.x * 15.0),
                            targetPos.y + (offset.y * 15.0),
                            targetPos.z
                        )
                        local success, groundZ = false, 0
                        for i = 1, 10 do 
                            success, groundZ = GetGroundZFor_3dCoord(newPos.x, newPos.y, newPos.z + 5.0, false)
                            if success then break end
                            Citizen.Wait(50)
                        end
                        if success then
                            newPos = vector3(newPos.x, newPos.y, groundZ + 0.5)
                            SetEntityCoordsNoOffset(vehicle, newPos.x, newPos.y, newPos.z, false, false, false)
                            local heading = GetHeadingFromVector_2d(
                                targetPos.x - newPos.x,
                                targetPos.y - newPos.y
                            )
                            SetEntityHeading(vehicle, heading)
                            
                            stuckCounter = 0
                        end
                    end
                else
                    stuckCounter = 0
                end
                if DoesEntityExist(driver) and DoesEntityExist(vehicle) then
                    local drivingStyle = 786603
                    local fixedSpeed = 25.0
                    TaskVehicleDriveToCoordLongrange(
                        driver, 
                        vehicle, 
                        targetPos.x, targetPos.y, targetPos.z, 
                        fixedSpeed,
                        drivingStyle,
                        5.0
                    )
                else
                    CleanupDelivery()
                    return
                end
                if distanceToTarget < 10 then
                    ArriveAtDeliveryPoint(vehicle, driver, vehicleModel)
                    return 
                elseif distanceToTarget > 150 then
                    local offset = SafeNormalize(vector3(
                        math.random(-25, -15), 
                        math.random(-25, -15), 
                        0.0
                    ))
                    local newPos = vector3(
                        targetPos.x + (offset.x * 20.0),
                        targetPos.y + (offset.y * 20.0),
                        targetPos.z
                    )
                    local success, groundZ = false, 0
                    for i = 1, 10 do
                        success, groundZ = GetGroundZFor_3dCoord(newPos.x, newPos.y, newPos.z + 5.0, false)
                        if success then break end
                        Citizen.Wait(50)
                    end
                    if success then
                        newPos = vector3(newPos.x, newPos.y, groundZ + 0.5)
                        SetEntityCoordsNoOffset(vehicle, newPos.x, newPos.y, newPos.z, false, false, false)
                    end
                end
                lastPos = vehiclePos
                lastUpdateTime = currentTime
            end
        end
        if not isEnroute and not activeDelivery then
            CleanupDelivery()
        end
    end)
end

function SafeNormalize(vector)
    if not vector then return vector3(0, 0, 0) end
    local lengthSquared = (vector.x * vector.x) + (vector.y * vector.y) + (vector.z * vector.z)
    if lengthSquared <= 0.0001 then 
        return vector3(0, 1, 0)
    end
    local length = math.sqrt(lengthSquared)
    return vector3(vector.x / length, vector.y / length, vector.z / length)
end

function ArriveAtDeliveryPoint(vehicle, driver, vehicleModel)
    if not activeDelivery or not DoesEntityExist(vehicle) then return end
    if DoesBlipExist(dealerBlip) then
        RemoveBlip(dealerBlip)
        dealerBlip = nil
    end
    if DoesEntityExist(driver) then
        TaskVehicleTempAction(driver, vehicle, 27, 6000)
    end
    if DoesEntityExist(vehicle) then
        SetVehicleDoorOpen(vehicle, 5, false, false)
    end
    isEnroute = false
    TriggerEvent("chatMessage", "BLACK MARKET", {0, 0, 0}, "^2Dealer has arrived! Approach the trunk to collect your items.")
    Citizen.CreateThread(function()
        local timeLeft = 60 
        while timeLeft > 0 and activeDelivery and DoesEntityExist(vehicle) and not weaponDelivered do
            Citizen.Wait(1000)
            timeLeft = timeLeft - 1
        end
        if activeDelivery and DoesEntityExist(vehicle) and not weaponDelivered then
            TriggerEvent("chatMessage", "BLACK MARKET", {0, 0, 0}, "^1Dealer is leaving...")
            DealerLeave(vehicle, driver, vehicleModel)
        end
    end)
    Citizen.CreateThread(function()
        HandleTrunkInteraction(vehicle, vehicleModel)
    end)
end

function HandleTrunkInteraction(vehicle, vehicleModel)
    if not DoesEntityExist(vehicle) or not activeDelivery then return end
    
    local interactionActive = true
    local renderDistance = 15.0 
    local promptShown = false
    local lastPromptTime = 0
    
    Citizen.CreateThread(function()
        while interactionActive and DoesEntityExist(vehicle) and activeDelivery and not weaponDelivered do
            Citizen.Wait(0)
            local player = PlayerPedId()
            
            if not DoesEntityExist(player) then
                Citizen.Wait(500)
            else
                local playerPos = GetEntityCoords(player)
                if not playerPos then
                    Citizen.Wait(500)
                else
                    local vehiclePos = GetEntityCoords(vehicle)
                    
                    if not vehiclePos then
                        Citizen.Wait(500)
                    else
                        local distanceToVehicle = #(playerPos - vehiclePos)
                        if distanceToVehicle <= renderDistance then
                            if distanceToVehicle <= 10.0 then
                                local trunkPos = nil
                                local trunkBone = GetEntityBoneIndexByName(vehicle, "boot")
                                
                                if trunkBone ~= -1 then
                                    trunkPos = GetWorldPositionOfEntityBone(vehicle, trunkBone)
                                else
                                    if not trunkPos then
                                        local min, max = GetModelDimensions(GetEntityModel(vehicle))
                                        if min and max then
                                            local offset = vector3(0.0, min.y - 0.2, 0.0)
                                            trunkPos = GetOffsetFromEntityInWorldCoords(vehicle, offset.x, offset.y, offset.z + 0.5)
                                        end
                                    end
                                end

                                if trunkPos then
                                    local distanceToTrunk = #(playerPos - trunkPos)
                                    if distanceToTrunk < 2.0 then
                                        DisplayHelpText("Press ~INPUT_CONTEXT~ to retrieve your order")
                                        promptShown = true
                                        
                                        if IsControlJustPressed(0, 38) then
                                            print("^2[DEBUG] E key pressed, giving items")
                                            
                                            local currentTime = GetGameTimer()
                                            if currentTime - lastPromptTime < 1000 then
                                                Citizen.Wait(500)
                                            else
                                                lastPromptTime = currentTime
                                                
                                                GiveWeaponToPlayer()
                                                
                                                weaponDelivered = true
                                                interactionActive = false
                                                
                                                DealerLeave(vehicle, dealerPed, vehicleModel)
                                                return
                                            end
                                        end
                                    else
                                        if promptShown then
                                            promptShown = false
                                            Citizen.Wait(100)
                                        else
                                            Citizen.Wait(250)
                                        end
                                    end
                                else
                                    Citizen.Wait(500)
                                end
                            else
                                Citizen.Wait(500)
                            end
                        else
                            Citizen.Wait(1000)
                        end
                    end
                end
            end
            if not DoesEntityExist(vehicle) or not activeDelivery then
                interactionActive = false
                return
            end
        end
    end)
end

function DisplayHelpText(text)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, false, -1)
end

function GiveWeaponToPlayer()
    if not activeDelivery then return end
    
    local player = PlayerPedId()
    if not player then
        print("^1[ERROR] Player not found!")
        return
    end
    
    if not Config.PurchasedItems or #Config.PurchasedItems == 0 then
        print("^1[ERROR] Delivery content not found! PurchasedItems is empty.")
        TriggerEvent("chatMessage", "BLACK MARKET", {255, 0, 0}, "Delivery content not found!")
        return
    end
    
    print("^2[DEBUG] Starting item delivery. Total " .. #Config.PurchasedItems .. " items")
    
    -- Animasyon başlatma
    local animDict = "anim@heists@narcotics@trash"
    local animName = "pickup"
    
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(100)
    end
    
    TaskPlayAnim(player, animDict, animName, 8.0, 8.0, -1, 0, 1, false, false, false)
    TriggerEvent("chatMessage", "BLACK MARKET", {0, 255, 0}, "You are retrieving your package...")
    
    Citizen.Wait(2500)
    ClearPedTasks(player)
    
    PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    
    TriggerEvent("chatMessage", "BLACK MARKET", {0, 255, 0}, "^3Delivering purchased items:")
    
    local weaponCount = 0
    local itemCount = 0
    
    for i, item in ipairs(Config.PurchasedItems) do
        if item and item.name and item.model then
            print("^2[DEBUG] Processing item #" .. i .. ": " .. item.name)
            
            local count = item.count or 1
            local category = item.category or ""
            
            if category == "" then
                for _, marketItem in ipairs(Config['Black Market Items']) do
                    if marketItem.id == item.id then
                        category = marketItem.category
                        break
                    end
                end
            end
            
            print("^3[DEBUG] Processing item: " .. item.name .. " - Category: " .. category .. " - Model: " .. item.model)
            
            if category == "weapons" then
                local weaponModel = item.model
                
                -- Silahı envantere ekle, ele verme
                print("^2[DEBUG] Adding weapon to inventory: " .. weaponModel)
                TriggerServerEvent('blackmarket:giveItem', weaponModel, count)
                TriggerEvent("chatMessage", "", {255, 255, 255}, "- " .. item.name .. " x" .. count)
                weaponCount = weaponCount + count
                PlaySoundFrontend(-1, "WEAPON_PURCHASE", "HUD_AMMO_SHOP_SOUNDSET", true)
            else
                print("^3[DEBUG] Giving item: " .. item.model .. " x" .. count)
                
                local itemCode = item.model
                
                print("^2[DEBUG] Adding to inventory: '" .. itemCode .. "' x" .. count)
                TriggerServerEvent('blackmarket:giveItem', itemCode, count)
                
                TriggerEvent("chatMessage", "", {255, 255, 255}, "- " .. item.name .. " x" .. count)
                itemCount = itemCount + count
            end
            
            Citizen.Wait(300)
        end
    end
    
    if weaponCount > 0 and itemCount > 0 then
        TriggerEvent("chatMessage", "BLACK MARKET", {0, 255, 0}, "^2Delivery completed! " .. weaponCount .. " weapons and " .. itemCount .. " items received.")
    elseif weaponCount > 0 then
        TriggerEvent("chatMessage", "BLACK MARKET", {0, 255, 0}, "^2Delivery completed! " .. weaponCount .. " weapons received.")
    elseif itemCount > 0 then
        TriggerEvent("chatMessage", "BLACK MARKET", {0, 255, 0}, "^2Delivery completed! " .. itemCount .. " items received.")
    else
        TriggerEvent("chatMessage", "BLACK MARKET", {0, 255, 0}, "^2Delivery completed!")
    end
    
    print("^2[DEBUG] Delivery completed, clearing PurchasedItems")
    Config.PurchasedItems = {}
end

function DealerLeave(vehicle, driver, vehicleModel)
    if not activeDelivery then return end
    
    if not DoesEntityExist(vehicle) then
        CleanupDelivery()
        return
    end

    SetVehicleDoorShut(vehicle, 5, false)
    
    if DoesEntityExist(driver) then
        local player = PlayerPedId()
        if DoesEntityExist(player) then
            local playerPos = GetEntityCoords(player)
            if playerPos then
                local awayPos = GetOffsetFromEntityInWorldCoords(player, 0.0, -1000.0, 0.0)
                
                TaskVehicleDriveToCoord(
                    driver, 
                    vehicle, 
                    awayPos.x, awayPos.y, awayPos.z, 
                    25.0,
                    1, 
                    GetHashKey(vehicleModel), 
                    786603,
                    5.0, 
                    true
                )
            end
        end
    end
    
    TriggerEvent("chatMessage", "BLACK MARKET", {0, 0, 0}, "^1Dealer is leaving the area...")
    
    Citizen.SetTimeout(30000, function()
        CleanupDelivery()
    end)
end

function CleanupDelivery(keepItems)
    if activeVehicle and DoesEntityExist(activeVehicle) then
        SetEntityAsMissionEntity(activeVehicle, false, true)
        DeleteVehicle(activeVehicle)
        activeVehicle = nil
    end
    
    if dealerPed and DoesEntityExist(dealerPed) then
        SetEntityAsMissionEntity(dealerPed, false, true)
        DeletePed(dealerPed)
        dealerPed = nil
    end
    
    if dealerBlip and DoesBlipExist(dealerBlip) then
        RemoveBlip(dealerBlip)
        dealerBlip = nil
    end
    
    isEnroute = false
    activeDelivery = false
    weaponDelivered = false
    deliveryInProgress = false
    pendingDelivery = false

    if not keepItems then
        Config.PurchasedItems = {}
    end

    SetModelAsNoLongerNeeded(GetHashKey("g_m_y_mexgoon_01"))
    SetModelAsNoLongerNeeded(GetHashKey("tampa"))
    
    if Config and Config.Dealer then
        if Config.Dealer.npc and type(Config.Dealer.npc) == "string" then
            SetModelAsNoLongerNeeded(GetHashKey(Config.Dealer.npc))
        end
        
        if Config.Dealer.vehicle and type(Config.Dealer.vehicle) == "string" then
            SetModelAsNoLongerNeeded(GetHashKey(Config.Dealer.vehicle))
        end
    end
    
    collectgarbage("collect")
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    CleanupDelivery()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    CleanupDelivery()
end)

Citizen.CreateThread(function()
    CleanupDelivery()
end)

