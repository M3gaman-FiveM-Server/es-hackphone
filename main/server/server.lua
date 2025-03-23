Framework = nil
Framework = GetFramework()
Citizen.Await(Framework)
Callback = Config.Framework == "ESX" or Config.Framework == "NewESX" and Framework.RegisterServerCallback or Framework.Functions.CreateCallback

Callback('BlackMarket', function(source, cb)
    local blackMarketData = json.decode(LoadResourceFile(GetCurrentResourceName(), "blackmarket.json") or "[]")
    cb({
        items = blackMarketData
    })
end)

Callback('Buy', function(source, cb, items)
    local src = source
    print("^2[DEBUG] Buy callback çağrıldı - Oyuncu ID: " .. src)
    
    if not items or #items == 0 then
        cb({success = false, message = "Ürün verileri alınamadı!"})
        return
    end
    
    print("^3[DEBUG] Gelen ürünler: " .. json.encode(items))
    
    local blackMarketData = json.decode(LoadResourceFile(GetCurrentResourceName(), "blackmarket.json") or "[]")
    
    local success, errorMessage, purchasedItems, totalPrice = ProcessItems(src, items, blackMarketData)
    
    if success then
        if Config.Framework == "ESX" or Config.Framework == "NewESX" then
            local player = Framework.GetPlayerFromId(src)
            player.removeMoney(totalPrice)
        elseif Config.Framework == "QBCore" then
            local player = Framework.Functions.GetPlayer(src)
            player.Functions.RemoveMoney('cash', totalPrice)
        end
        
        for _, item in ipairs(purchasedItems) do
            blackMarketData[item.index].stock = blackMarketData[item.index].stock - item.count
        end
        
        SaveResourceFile(GetCurrentResourceName(), "blackmarket.json", json.encode(blackMarketData, {indent = true}), -1)
        
        cb({
            success = true,
            items = blackMarketData,
            message = "Satın alma işlemi başarılı!"
        })
        
        print("[BLACK MARKET] Oyuncu ID: " .. src .. " - $" .. totalPrice .. " değerinde " .. #purchasedItems .. " ürün satın aldı.")
    else
        cb({
            success = false,
            message = errorMessage
        })
    end
end)

function ProcessItems(src, items, blackMarketData)
    local totalPrice = 0
    local purchasedItems = {}
    local errorMessage = ""
    local success = true
    
    for _, item in ipairs(items) do
        local found = false
        local itemId = item.id
        local count = item.count or 1
        
        for i, marketItem in ipairs(blackMarketData) do
            if marketItem.id == itemId then
                found = true
                
                if marketItem.stock < count then
                    success = false
                    errorMessage = marketItem.name .. " için yeterli stok bulunmuyor!"
                    break
                end
                
                local itemPrice = marketItem.price * count
                totalPrice = totalPrice + itemPrice
                
                table.insert(purchasedItems, {
                    id = marketItem.id,
                    name = marketItem.name,
                    model = marketItem.model,
                    price = marketItem.price,
                    count = count,
                    index = i,
                    category = marketItem.category
                })
                
                break
            end
        end
        
        if not found then
            success = false
            errorMessage = "Ürün bulunamadı!"
            break
        end
        
        if not success then
            break
        end
    end
    
    if success and totalPrice > 0 then
        local hasEnoughMoney = false
        
        if Config.Framework == "ESX" or Config.Framework == "NewESX" then
            local player = Framework.GetPlayerFromId(src)
            if player then
                local money = player.getMoney()
                hasEnoughMoney = money >= totalPrice
                
                if not hasEnoughMoney then
                    success = false
                    errorMessage = "Yeterli paranız yok! Gereken: $" .. totalPrice
                end
            else
                success = false
                errorMessage = "Oyuncu bulunamadı!"
            end
        elseif Config.Framework == "QBCore" then
            local player = Framework.Functions.GetPlayer(src)
            if player then
                local money = player.PlayerData.money["cash"]
                hasEnoughMoney = money >= totalPrice
                
                if not hasEnoughMoney then
                    success = false
                    errorMessage = "Yeterli paranız yok! Gereken: $" .. totalPrice
                end
            else
                success = false
                errorMessage = "Oyuncu bulunamadı!"
            end
        else
            success = false
            errorMessage = "Desteklenmeyen framework ayarı!"
        end
    end
    
    return success, errorMessage, purchasedItems, totalPrice
end

RegisterServerEvent('hackphone:giveATMMoney')
AddEventHandler('hackphone:giveATMMoney', function(data)
    local src = source
    local amount = data.amount or 0
    
    if amount <= 0 then return end
    
    if Config.Framework == "ESX" or Config.Framework == "NewESX" then
        local xPlayer = Framework.GetPlayerFromId(src)
        if xPlayer then
            xPlayer.addMoney(amount)
        end
    elseif Config.Framework == "QBCore" then
        local Player = Framework.Functions.GetPlayer(src)
        if Player then
            Player.Functions.AddMoney('cash', amount)
        end
    end
    
    TriggerEvent('hackphone:logRobbery', src, amount)
end)

RegisterServerEvent('hackphone:logRobbery')
AddEventHandler('hackphone:logRobbery', function(playerId, amount)
    print('[HackPhone] Oyuncu ID: ' .. playerId .. ' - ATM\'den $' .. amount .. ' çaldı.')
end)

RegisterServerEvent('hackphone:syncExplosion')
AddEventHandler('hackphone:syncExplosion', function(vehicleNetId, coords)
    TriggerClientEvent('hackphone:explosion', -1, vehicleNetId, coords)
end)

RegisterServerEvent('hackphone:syncVehicleEngine')
AddEventHandler('hackphone:syncVehicleEngine', function(vehicleNetId, state)
    TriggerClientEvent('hackphone:updateVehicleEngine', -1, vehicleNetId, state)
end)

RegisterServerEvent('hackphone:syncVehicleLights')
AddEventHandler('hackphone:syncVehicleLights', function(vehicleNetId, state)
    TriggerClientEvent('hackphone:updateVehicleLights', -1, vehicleNetId, state)
end)

RegisterServerEvent('hackphone:syncVehicleDoor')
AddEventHandler('hackphone:syncVehicleDoor', function(vehicleNetId, doorIndex, state)
    TriggerClientEvent('hackphone:updateVehicleDoor', -1, vehicleNetId, doorIndex, state)
end)

RegisterServerEvent('hackphone:syncVehicleLock')
AddEventHandler('hackphone:syncVehicleLock', function(vehicleNetId, lockState)
    TriggerClientEvent('hackphone:updateVehicleLock', -1, vehicleNetId, lockState)
end)

RegisterServerEvent('hackphone:syncMoneyProps')
AddEventHandler('hackphone:syncMoneyProps', function(atmId, coords, count)
    TriggerClientEvent('hackphone:createMoneyProps', -1, atmId, coords, count)
end)

RegisterServerEvent('hackphone:syncBombPlanted')
AddEventHandler('hackphone:syncBombPlanted', function(vehicleNetId, explosionTime)
    TriggerClientEvent('hackphone:bombPlanted', -1, vehicleNetId, explosionTime)
end)

RegisterServerEvent('hackphone:syncATMRobbery')
AddEventHandler('hackphone:syncATMRobbery', function(atmId, progress, isActive)
    TriggerClientEvent('hackphone:updateATMRobbery', -1, atmId, progress, isActive)
end)

local robbedATMs = {}

Citizen.CreateThread(function()
    Citizen.Wait(1000) 
    robbedATMs = {}
    TriggerClientEvent('hackphone:syncRobbedATMs', -1, robbedATMs)
end)

RegisterServerEvent('hackphone:markATMRobbed')
AddEventHandler('hackphone:markATMRobbed', function(atmId)
    if not atmId then return end
    local atmIdStr = tostring(atmId)
    robbedATMs[atmIdStr] = true
    local count = 0
    for _ in pairs(robbedATMs) do count = count + 1 end
    print("ATM soyuldu: " .. atmIdStr .. " - Toplam soyulan ATM sayısı: " .. count)
    TriggerClientEvent('hackphone:syncRobbedATMs', -1, robbedATMs)
end)

AddEventHandler('playerJoining', function()
    local _source = source
    TriggerClientEvent('hackphone:syncRobbedATMs', _source, robbedATMs)
end)

RegisterCommand('resetatms', function(source, args, rawCommand)
    local _source = source
    if _source > 0 then
        local xPlayer = nil
        if Config.Framework == "ESX" or Config.Framework == "NewESX" then
            xPlayer = Framework.GetPlayerFromId(_source)
            if not xPlayer.getGroup() == 'admin' then
                return
            end
        elseif Config.Framework == "QBCore" then
            local Player = Framework.Functions.GetPlayer(_source)
            if not Player.PlayerData.permission == 'admin' then
                return
            end
        else
            return
        end
    end
    robbedATMs = {}
    TriggerClientEvent('hackphone:syncRobbedATMs', -1, robbedATMs)
    if _source > 0 then
        print("ATM'ler " .. GetPlayerName(_source) .. " tarafından sıfırlandı")
    else
        print("ATM'ler konsol tarafından sıfırlandı")
    end
end, true)

RegisterCommand('checkatms', function(source, args, rawCommand)
    local _source = source
    local count = 0
    for atmId, _ in pairs(robbedATMs) do
        count = count + 1
        print("Soyulmuş ATM: " .. atmId)
    end
    local content = LoadResourceFile(GetCurrentResourceName(), "robbedatms.json")
    if content and content ~= "" then
        print("robbedatms.json içeriği: " .. content)
    else
        print("robbedatms.json dosyası boş veya bulunamadı")
    end

    TriggerClientEvent('hackphone:syncRobbedATMs', -1, robbedATMs)
end, true)

RegisterServerEvent('hackphone:requestRobbedATMs')
AddEventHandler('hackphone:requestRobbedATMs', function()
    local _source = source
    TriggerClientEvent('hackphone:syncRobbedATMs', _source, robbedATMs)
    local count = 0
    for _ in pairs(robbedATMs) do count = count + 1 end
    print("ATM listesi istendi. Gönderilen ATM sayısı: " .. count)
end)

RegisterCommand('setautoresetatms', function(source, args, rawCommand)
    local _source = source
    local minutes = tonumber(args[1]) or 60 
    if _source > 0 then
        local xPlayer = nil
        if Config.Framework == "ESX" or Config.Framework == "NewESX" then
            xPlayer = Framework.GetPlayerFromId(_source)
            if not xPlayer.getGroup() == 'admin' then
                return
            end
        elseif Config.Framework == "QBCore" then
            local Player = Framework.Functions.GetPlayer(_source)
            if not Player.PlayerData.permission == 'admin' then
                return
            end
        else
            return
        end
    end

    Citizen.CreateThread(function()
        Citizen.Wait(minutes * 60 * 1000) 
        robbedATMs = {}
        TriggerClientEvent('hackphone:syncRobbedATMs', -1, robbedATMs)
    end)
    if _source > 0 then
        print(GetPlayerName(_source) .. " ATM'lerin " .. minutes .. " dakika sonra otomatik sıfırlanmasını ayarladı")
    else
        print("ATM'lerin " .. minutes .. " dakika sonra otomatik sıfırlanması ayarlandı")
    end
end, true)

RegisterServerEvent('blackmarket:giveItem')
AddEventHandler('blackmarket:giveItem', function(itemName, count)
    local src = source
    
    if not itemName or not count then
        print("^1[ERROR] Item delivery event - Missing parameters!")
        return
    end
    
    count = tonumber(count) or 1
    
    print("^2[DEBUG] BlackMarket delivery - Player ID: " .. src .. " - Item: " .. itemName .. " x" .. count)
    
    if Config.Framework == "QBCore" then
        local Player = Framework.Functions.GetPlayer(src)
        if Player then
            local qbItem = Framework.Shared.Items[itemName]
            
            if not qbItem then
                local possibleNames = {}
                
                if string.find(itemName, "weapon_") then
                    local withoutPrefix = itemName:gsub("weapon_", "")
                    table.insert(possibleNames, withoutPrefix)
                end
                
                if not string.find(itemName, "weapon_") then
                    local withPrefix = "weapon_" .. itemName
                    table.insert(possibleNames, withPrefix)
                end
                
                if not string.find(string.upper(itemName), "WEAPON_") then
                    local upperPrefix = "WEAPON_" .. string.upper(itemName:gsub("weapon_", ""))
                    table.insert(possibleNames, upperPrefix)
                end
                
                if itemName == "weapon_sniperrifle" or itemName == "sniperrifle" then
                    table.insert(possibleNames, "sniper")
                    table.insert(possibleNames, "WEAPON_SNIPERRIFLE")
                end
                
                if itemName == "weapon_pistol50" or itemName == "pistol50" then
                    table.insert(possibleNames, "weapon_pistol50")
                    table.insert(possibleNames, "pistol50")
                    table.insert(possibleNames, "WEAPON_PISTOL50")
                end
                
                if itemName == "weapon_pumpshotgun" or itemName == "pumpshotgun" then
                    table.insert(possibleNames, "shotgun")
                end
                
                for _, name in ipairs(possibleNames) do
                    if Framework.Shared.Items[name] then
                        qbItem = Framework.Shared.Items[name]
                        itemName = name
                        print("^2[DEBUG] Item bulundu! Alternatif format: " .. name)
                        break
                    end
                end
            end
            
            if qbItem then
                local success, errorMsg = pcall(function()
                    Player.Functions.AddItem(itemName, count)
                    TriggerClientEvent('inventory:client:ItemBox', src, qbItem, "add")
                end)
                
                if success then
                    print("^2[DEBUG] QBCore Item delivered: " .. itemName .. " x" .. count)
                    TriggerClientEvent("chatMessage", src, "BLACK MARKET", {0, 255, 0}, "Item eklendi: " .. qbItem.label .. " x" .. count)
                else
                    print("^1[ERROR] Failed to add item: " .. itemName .. " - Error: " .. tostring(errorMsg))
                    TriggerClientEvent("chatMessage", src, "BLACK MARKET", {255, 0, 0}, "Item eklenemedi!")
                end
            else
                print("^1[ERROR] QBCore item not found: " .. itemName .. " - Mevcut silahlar:")
                
                local foundWeapons = 0
                for k, v in pairs(Framework.Shared.Items) do
                    if string.find(string.lower(k), "weapon") or 
                       string.find(string.lower(k), "pistol") or
                       string.find(string.lower(k), "rifle") or
                       string.find(string.lower(k), "shotgun") then
                        print("   - " .. k)
                        foundWeapons = foundWeapons + 1
                        if foundWeapons >= 10 then break end
                    end
                end
                
                TriggerClientEvent("chatMessage", src, "BLACK MARKET", {255, 0, 0}, "Item bulunamadı: " .. itemName)
            end
        else
            print("^1[ERROR] QBCore Player not found! ID: " .. src)
        end
    elseif Config.Framework == "ESX" or Config.Framework == "NewESX" then
        local xPlayer = Framework.GetPlayerFromId(src)
        if xPlayer then
            if xPlayer.addInventoryItem then
                xPlayer.addInventoryItem(itemName, count)
                print("^2[DEBUG] ESX Item delivered: " .. itemName .. " x" .. count)
            else
                print("^1[ERROR] ESX addInventoryItem method not found")
                TriggerClientEvent("chatMessage", src, "BLACK MARKET", {255, 0, 0}, "Item could not be added to inventory")
            end
        else
            print("^1[ERROR] ESX Player not found! ID: " .. src)
        end
    else
        print("^1[ERROR] Unsupported framework: " .. (Config.Framework or "Not specified"))
    end
    
    TriggerClientEvent('blackmarket:itemDeliveryStatus', src, {
        success = true,
        itemName = itemName,
        count = count
    })
end)

RegisterServerEvent('blackmarket:directBuy')
AddEventHandler('blackmarket:directBuy', function(items)
    local src = source
    print("^2[DEBUG] blackmarket:directBuy eventi tetiklendi - Oyuncu ID: " .. src)
    
    if not items or #items == 0 then
        TriggerClientEvent('blackmarket:buyResponse', src, {
            success = false,
            message = "Sipariş içeriği boş!"
        })
        return
    end
    
    local blackMarketData = json.decode(LoadResourceFile(GetCurrentResourceName(), "blackmarket.json") or "[]")
    local success, errorMessage, purchasedItems, totalPrice = ProcessItems(src, items, blackMarketData)
    
    if success then
        if Config.Framework == "ESX" or Config.Framework == "NewESX" then
            local player = Framework.GetPlayerFromId(src)
            player.removeMoney(totalPrice)
            print("^2[DEBUG] ESX oyuncudan $" .. totalPrice .. " alındı")
        elseif Config.Framework == "QBCore" then
            local player = Framework.Functions.GetPlayer(src)
            player.Functions.RemoveMoney('cash', totalPrice)
            print("^2[DEBUG] QBCore oyuncudan $" .. totalPrice .. " alındı")
        end
        
        for _, item in ipairs(purchasedItems) do
            local oldStock = blackMarketData[item.index].stock
            blackMarketData[item.index].stock = oldStock - item.count
            print("^2[DEBUG] Stok güncellendi: " .. item.name .. " - Eski: " .. oldStock .. ", Yeni: " .. blackMarketData[item.index].stock)
        end
        
        SaveResourceFile(GetCurrentResourceName(), "blackmarket.json", json.encode(blackMarketData, {indent = true}), -1)
        
        TriggerClientEvent('blackmarket:buyResponse', src, {
            success = true,
            items = blackMarketData,
            message = "Satın alma işlemi başarılı!"
        })
        
        print("^2[DEBUG] Satın alma işlemi tamamlandı - Oyuncu: " .. src .. " - Toplam: $" .. totalPrice)
    else
        TriggerClientEvent('blackmarket:buyResponse', src, {
            success = false,
            message = errorMessage
        })
    end
end)