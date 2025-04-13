Config = {}

Config = {
    Framework = 'QBCore',  -- QBCore or ESX or OLDQBCore or NewESX
    Dealer = {
        marker = "[E] Black Shop", 
        vehicle = "slamvan2",
        npc = "g_m_y_mexgoon_01"
    },
    Blip = {
        Sprite = 1, 
        Display = 4, 
        Scale = 0.8,
        Color = 1, 
        Label = "Weapon Dealer"
    },

    UseItem = true, -- Enable/disable using items to open phone
    ItemName = "hackphone", -- Item name required to open phone if UseItem is true
    OpenKey = 'J', -- Key to open phone when UseItem is true and player has the required item

    ['Phone Wallpapers'] = {
      'https://i.pinimg.com/originals/eb/42/9d/eb429d3a85e9ab08d5636c07c137f765.jpg',
      'https://w0.peakpx.com/wallpaper/697/23/HD-wallpaper-iphone-14-iphone-apple-thumbnail.jpg',
      'https://9to5mac.com/wp-content/uploads/sites/6/2024/09/iPhone-16-and-16-Pro-wallpapers-8.jpg?quality=82&strip=all',
      'https://wallpapers.com/images/hd/professional-iphone-zdw0vf97xfqk7m42.jpg'
    },

    ['Black Market Categories'] = {
        { id = 'all', name = 'All', icon = 'ri-store-2-fill', color = '#FF6B6B' },
        { id = 'weapons', name = 'Weapons', icon = 'ri-sword-fill', color = '#FF4757' },
        { id = 'meds', name = 'Medications', icon = 'ri-medicine-bottle-fill', color = '#2ED573' },
        { id = 'equipment', name = 'Equipment', icon = 'ri-tools-fill', color = '#1E90FF' },
        { id = 'hacktools', name = 'Hack Tools', icon = 'ri-code-box-fill', color = '#FFA502' },
        { id = 'documents', name = 'Documents', icon = 'ri-file-text-fill', color = '#A55EEA' }
    },
    
    ['Black Market Items'] = {},
    PurchasedItems = {}
}

function GetFramework()
    local Get = nil
    if Config.Framework == "ESX" then
        while Get == nil do
            TriggerEvent('esx:getSharedObject', function(Set) Get = Set end)
            Citizen.Wait(0)
        end
    elseif Config.Framework == "NewESX" then
        Get = exports['es_extended']:getSharedObject()
    elseif Config.Framework == "QBCore" then
        Get = exports["qb-core"]:GetCoreObject()
    elseif Config.Framework == "OLDQBCore" then
        while Get == nil do
            TriggerEvent('QBCore:GetObject', function(Set) Get = Set end)
            Citizen.Wait(200)
        end
    end
    return Get
end
