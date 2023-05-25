
Citizen.CreateThread(function()
    exports['oxmysql']:execute("SELECT * FROM `containers`", function(result)
        if result[1] then 
            local ToDay = os.date("%A")
            local CutDay = {
                -- ["Sunday"] = true,
                ["Friday"] = true,
            }

            local Containers = result

            if CutDay[ToDay] then 
                for i = 1, (#Containers), 1 do
                    Wait(100)
                    if tonumber(Containers[i].flag) == 0 then 
                        if tonumber(Containers[i].total) < Config.Containers.TotalRent then 
                            local PlayerData = MySQL.Sync.prepare('SELECT * FROM players where citizenid = ?', { Containers[i].owner })
                            if PlayerData then 
                                PlayerData.money = json.decode(PlayerData.money)
                                if PlayerData.money then 
                                    if tonumber(PlayerData.money.bank) >= Config.Containers.Rent then 
                                        PlayerData.money.bank = PlayerData.money.bank - Config.Containers.Rent
                                        MySQL.Async.prepare('UPDATE players SET money = ? WHERE citizenid = ?', { json.encode(PlayerData.money), Containers[i].owner })
                                        Wait(50)
                                        Containers[i].total += Config.Containers.Rent
                                        MySQL.Async.prepare('UPDATE containers SET flag = ?, total = ? WHERE id = ?', { tonumber('1'), Containers[i].total, Containers[i].id })
    
                                        if Config.Containers.Locations[Containers[i].id] then 
                                            Config.Containers.Locations[Containers[i].id].isOwned = true
                                            Config.Containers.Locations[Containers[i].id].Owner = Containers[i].owner
                                            Config.Containers.Locations[Containers[i].id].Total = Containers[i].total
                                            Config.Containers.Locations[Containers[i].id].stash.size = tonumber(Containers[i].size)
                                            Config.Containers.Locations[Containers[i].id].stash.slots = tonumber(Containers[i].slots)
                                            if Containers[i].keyholders then 
                                                Containers[i].keyholders = json.decode(Containers[i].keyholders)
                                                for key, holder in pairs(Containers[i].keyholders) do 
                                                    Config.Containers.Locations[Containers[i].id].KeyHolders[#Config.Containers.Locations[Containers[i].id].KeyHolders + 1] = {
                                                        name = holder.name,
                                                        cid = holder.cid,
                                                    }
                                                end
                                            end
                                        end
                                    else
                                        MySQL.query("DELETE FROM containers WHERE id = ?", {
                                            Containers[i].id
                                        })
                                    end
                                else
                                    MySQL.query("DELETE FROM containers WHERE id = ?", {
                                        Containers[i].id
                                    })
                                end
                            else
                                MySQL.query("DELETE FROM containers WHERE id = ?", {
                                    Containers[i].id
                                })
                            end
                        elseif tonumber(Containers[i].total) >= Config.Containers.TotalRent then 
                            if Config.Containers.Locations[Containers[i].id] then 
                                Config.Containers.Locations[Containers[i].id].isOwned = true
                                Config.Containers.Locations[Containers[i].id].Owner = Containers[i].owner
                                Config.Containers.Locations[Containers[i].id].Total = Containers[i].total
                                Config.Containers.Locations[Containers[i].id].stash.size = tonumber(Containers[i].size)
                                Config.Containers.Locations[Containers[i].id].stash.slots = tonumber(Containers[i].slots)
                                if Containers[i].keyholders then 
                                    Containers[i].keyholders = json.decode(Containers[i].keyholders)
                                    for key, holder in pairs(Containers[i].keyholders) do 
                                        Config.Containers.Locations[Containers[i].id].KeyHolders[#Config.Containers.Locations[Containers[i].id].KeyHolders + 1] = {
                                            name = holder.name,
                                            cid = holder.cid,
                                        }
                                    end
                                end
                            end
                        end
                    else
                        if Config.Containers.Locations[Containers[i].id] then 
                            Config.Containers.Locations[Containers[i].id].isOwned = true
                            Config.Containers.Locations[Containers[i].id].Owner = Containers[i].owner
                            Config.Containers.Locations[Containers[i].id].Total = Containers[i].total
                            Config.Containers.Locations[Containers[i].id].stash.size = tonumber(Containers[i].size)
                            Config.Containers.Locations[Containers[i].id].stash.slots = tonumber(Containers[i].slots)
                            if Containers[i].keyholders then 
                                Containers[i].keyholders = json.decode(Containers[i].keyholders)
                                for key, holder in pairs(Containers[i].keyholders) do 
                                    Config.Containers.Locations[Containers[i].id].KeyHolders[#Config.Containers.Locations[Containers[i].id].KeyHolders + 1] = {
                                        name = holder.name,
                                        cid = holder.cid,
                                    }
                                end
                            end
                        end
                    end
                end
            else
                for i = 1, (#Containers), 1 do
                    Wait(50)
                    if tonumber(Containers[i].flag) == 1 then 
                        MySQL.Async.prepare('UPDATE containers SET flag = ? WHERE id = ?', { tonumber('0'), Containers[i].id })
                    end
                    if Config.Containers.Locations[Containers[i].id] then 
                        Config.Containers.Locations[Containers[i].id].isOwned = true
                        Config.Containers.Locations[Containers[i].id].Owner = Containers[i].owner
                        Config.Containers.Locations[Containers[i].id].Total = Containers[i].total
                        Config.Containers.Locations[Containers[i].id].stash.size = tonumber(Containers[i].size)
                        Config.Containers.Locations[Containers[i].id].stash.slots = tonumber(Containers[i].slots)
                        if Containers[i].keyholders then 
                            Containers[i].keyholders = json.decode(Containers[i].keyholders)
                            for key, holder in pairs(Containers[i].keyholders) do 
                                Config.Containers.Locations[Containers[i].id].KeyHolders[#Config.Containers.Locations[Containers[i].id].KeyHolders + 1] = {
                                    name = holder.name,
                                    cid = holder.cid,
                                }
                            end
                        end
                    end
                end
            end
            Wait(1000)
            TriggerClientEvent('qb-containers:client:Container', -1, Config.Containers)
        end
    end)
end)

QBCore.Functions.CreateCallback('qb-containers:server:GetContainerConfig', function(source, cb)
	cb(Config.Containers)
end)

RegisterNetEvent('qb-containers:server:RentContainer', function(data)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    local CanBuy = true
    if Player then 
        local Bank = Player.PlayerData.money.bank
        if Bank then 
            if Bank >= Config.Containers.Rent then 
                Wait(500)
                if not Config.Containers.Locations[data.container].isOwned then 
                    for k, v in pairs(Config.Containers.Locations) do 
                        if v.Owner == Player.PlayerData.citizenid then 
                            QBCore.Functions.Notify(src, 'You Can\'t Have More Than One container', 'error', 7500)
                            CanBuy = false
                            return
                        end
                    end
                    if CanBuy then 
                        if not Config.Containers.Locations[data.container].isOwned then 
                            if Player.Functions.RemoveMoney('bank', tonumber(Config.Containers.FirstPayment), 'containers-rent') then 
                                Config.Containers.Locations[data.container].isOwned = true
                                Config.Containers.Locations[data.container].Owner = Player.PlayerData.citizenid
                                Config.Containers.Locations[data.container].Total = Config.Containers.FirstPayment
                                Config.Containers.Locations[data.container].KeyHolders = {}
                                Config.Containers.Locations[data.container].KeyHolders[#Config.Containers.Locations[data.container].KeyHolders + 1] = {
                                    name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
                                    cid = Player.PlayerData.citizenid,
                                }
                                MySQL.Async.insert('INSERT INTO containers (id, owner, keyholders, flag, total, size, slots) VALUES (:id, :owner, :keyholders, :flag, :total, :size, :slots) ON DUPLICATE KEY UPDATE id = :id, owner = :owner, keyholders = :keyholders, flag = :flag, total = :total, size = :size, slots = :slots', {
                                    id = Config.Containers.Locations[data.container].id,
                                    owner = Player.PlayerData.citizenid,
                                    keyholders = json.encode(Config.Containers.Locations[data.container].KeyHolders),
                                    flag = 1,
                                    total = Config.Containers.FirstPayment,
                                    size = Config.Containers.size,
                                    slots = Config.Containers.slots,
                                })
                                QBCore.Functions.Notify(src, 'You have rented container # '..data.container..'', 'success', 7500)
                                TriggerClientEvent('qb-containers:client:Container', -1, Config.Containers)
                            else
                                QBCore.Functions.Notify(src, 'You don\'t have money', 'error', 7500)
                            end
                        end
                    end
                else
                    QBCore.Functions.Notify(src, 'This container is already sold', 'error', 7500)
                end
            else
                QBCore.Functions.Notify(src, 'You don\'t have money', 'error', 7500)
            end
        end
    end
end)

RegisterNetEvent('qb-containers:server:ContainerManageSrcond', function(data)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    local CanBuy = true
    if Player then 
        local Bank = Player.PlayerData.money.bank
        if Bank then 
            if data.action == 'weight' then 
                if Bank >= tonumber(data.price) then 
                    if tonumber(data.option) > Config.Containers.Locations[data.id].stash.size then 
                        if Player.Functions.RemoveMoney(data.money, tonumber(data.price), 'containers-upgrade-size') then 
                            Config.Containers.Locations[data.id].stash.size = tonumber(data.option)
                            MySQL.Async.prepare('UPDATE containers SET size = ? WHERE id = ?', { data.option, data.id })
                            QBCore.Functions.Notify(src, 'You have rised your stash weight to '..math.ceil(data.option / 1000)..' KG', 'success', 7500)
                            TriggerClientEvent('qb-containers:client:Container', -1, Config.Containers)
                        else
                            QBCore.Functions.Notify(src, 'You don\'t have money', 'error', 7500)
                        end
                    else
                        QBCore.Functions.Notify(src, 'Your stash has max weight', 'error', 7500)
                    end
                else
                    QBCore.Functions.Notify(src, 'You don\'t have money', 'error', 7500)
                end
            elseif data.action == 'slots' then 
                if Bank >= tonumber(data.price) then 
                    if tonumber(data.option) > Config.Containers.Locations[data.id].stash.slots then 
                        if Player.Functions.RemoveMoney(data.money, tonumber(data.price), 'containers-upgrade-slots') then 
                            Config.Containers.Locations[data.id].stash.slots = tonumber(data.option)
                            MySQL.Async.prepare('UPDATE containers SET slots = ? WHERE id = ?', { data.option, data.id })
                            QBCore.Functions.Notify(src, 'You have rised your stash slots to '..math.ceil(data.option / 1000)..' KG', 'success', 7500)
                            TriggerClientEvent('qb-containers:client:Container', -1, Config.Containers)
                        else
                            QBCore.Functions.Notify(src, 'You don\'t have money', 'error', 7500)
                        end
                    else
                        QBCore.Functions.Notify(src, 'Your stash has max slots', 'error', 7500)
                    end
                else
                    QBCore.Functions.Notify(src, 'You don\'t have money', 'error', 7500)
                end
            end
        end
    end
end)

RegisterNetEvent('qb-containers:server:Key', function(data)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    local players = {}
    local MyPed = GetPlayerPed(src)
    local MyCoords = GetEntityCoords(MyPed)
    local QBPlayers = QBCore.Functions.GetQBPlayers()
    for k, v in pairs(QBPlayers) do
        if v.PlayerData.source ~= src then 
            local targetped = GetPlayerPed(v.PlayerData.source)
            local TargetCoords = GetEntityCoords(targetped)
            if #(MyCoords - TargetCoords) <= 7 then 
                players[#players+1] = {
                    name = v.PlayerData.charinfo.firstname .. ' ' .. v.PlayerData.charinfo.lastname,
                    id = v.PlayerData.source,
                    citizenid = v.PlayerData.citizenid,
                }
            end
        end
    end
    if #players > 0 then 
        TriggerClientEvent('qb-containers:client:Key', src, data, players)
    else
        QBCore.Functions.Notify(src, 'No One Here', 'error', 7500)
    end
end)

RegisterNetEvent('qb-containers:server:GiveKey', function(data)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local Target = QBCore.Functions.GetPlayerByCitizenId(data.cid)
    if Player then 
        if not data then return end
        if not data.id then return end
        if not Config.Containers.Locations[data.id] then return end
        if Config.Containers.Locations[data.id].Owner == Player.PlayerData.citizenid then 
            if Target then 
                for key, holder in pairs(Config.Containers.Locations[data.id].KeyHolders) do 
                    if holder.cid == data.cid then 
                        QBCore.Functions.Notify(src, 'This One Already Have Key', 'error', 7500)
                        return
                    end
                end
                Config.Containers.Locations[data.id].KeyHolders[#Config.Containers.Locations[data.id].KeyHolders + 1] = {
                    name = Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname,
                    cid = data.cid,
                }
                MySQL.Async.prepare('UPDATE containers SET keyholders = ? WHERE id = ?', { json.encode(Config.Containers.Locations[data.id].KeyHolders), data.id })
                QBCore.Functions.Notify(src, 'Key Have Been Gived To '..Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname..'', 'success', 7500)
                QBCore.Functions.Notify(Target.PlayerData.source, 'You Got New Key For This Container', 'success', 7500)
                TriggerClientEvent('qb-containers:client:Container', Target.PlayerData.source, Config.Containers)
            end
        else
            QBCore.Functions.Notify(Target.PlayerData.source, 'You Don\'t Have Access', 'error', 7500)
        end
    end
end)

RegisterNetEvent('qb-containers:server:RemoveKeyList', function(data)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    local players = {}
    if Player then 
        if not data then return end
        if not data.id then return end
        if not Config.Containers.Locations[data.id] then return end
        if Config.Containers.Locations[data.id].Owner == Player.PlayerData.citizenid then 
            for key, holder in pairs(Config.Containers.Locations[data.id].KeyHolders) do 
                if holder.cid ~= Player.PlayerData.citizenid then 
                    players[#players+1] = {
                        name = holder.name,
                        citizenid = holder.cid,
                    }
                end
            end
        else
            QBCore.Functions.Notify(Target.PlayerData.source, 'You Don\'t Have Access', 'error', 7500)
        end
        if #players > 0 then 
            TriggerClientEvent('qb-containers:client:RemoveKeyList', src, data, players)
        else
            QBCore.Functions.Notify(src, 'No Key Holders', 'error', 7500)
        end
    end
end)

RegisterNetEvent('qb-containers:server:Transfer', function(data)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    local players = {}
    local MyPed = GetPlayerPed(src)
    local MyCoords = GetEntityCoords(MyPed)
    local QBPlayers = QBCore.Functions.GetQBPlayers()
    for k, v in pairs(QBPlayers) do
        if v.PlayerData.source ~= src then 
            local targetped = GetPlayerPed(v.PlayerData.source)
            local TargetCoords = GetEntityCoords(targetped)
            if #(MyCoords - TargetCoords) <= 7 then 
                players[#players+1] = {
                    name = v.PlayerData.charinfo.firstname .. ' ' .. v.PlayerData.charinfo.lastname,
                    id = v.PlayerData.source,
                    citizenid = v.PlayerData.citizenid,
                }
            end
        end
    end
    if #players > 0 then 
        TriggerClientEvent('qb-containers:client:Transfer', src, data, players)
    else
        QBCore.Functions.Notify(src, 'No One Here', 'error', 7500)
    end
end)

RegisterNetEvent('qb-containers:server:TransferConfirm', function(data)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayerByCitizenId(data.cid)
    if Target then 
        data.Or = ''..Player.PlayerData.charinfo.firstname..' '..Player.PlayerData.charinfo.lastname..''
        data.Owner = Player.PlayerData.citizenid
        TriggerClientEvent('qb-containers:client:TransferConfirm', Target.PlayerData.source, data)
    end
end)

RegisterNetEvent('qb-containers:server:TransferAccept', function(data)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    if Player then 
        if not data then return end
        if not data.id then return end
        if not Config.Containers.Locations[data.id] then return end
        local Target = QBCore.Functions.GetPlayerByCitizenId(data.Owner)
        if Target then 
            if Config.Containers.Locations[data.id].Owner == Target.PlayerData.citizenid then 
                for k, v in pairs(Config.Containers.Locations) do 
                    if v.Owner == Player.PlayerData.citizenid then 
                        QBCore.Functions.Notify(src, 'You Can\'t Have More Than One Container', 'error', 7500)
                        QBCore.Functions.Notify(Target.PlayerData.source, 'Can not transferred to this person', 'error', 7500)
                        CanBuy = false
                        return
                    end
                end
                Config.Containers.Locations[data.id].Owner = Player.PlayerData.citizenid
                Config.Containers.Locations[data.id].KeyHolders = {}
                Config.Containers.Locations[data.id].KeyHolders[#Config.Containers.Locations[data.id].KeyHolders + 1] = {
                    name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
                    cid = Player.PlayerData.citizenid,
                }
                MySQL.Async.prepare('UPDATE containers SET owner = ?, keyholders = ? WHERE id = ?', {
                    Player.PlayerData.citizenid,
                    json.encode(Config.Containers.Locations[data.id].KeyHolders),
                    data.id 
                })
                QBCore.Functions.Notify(src, 'Container have been transferred', 'success', 7500)
                QBCore.Functions.Notify(Target.PlayerData.source, 'Container have been transferred', 'success', 7500)
                TriggerClientEvent('qb-containers:client:Container', -1, Config.Containers)
            end
        end
    end
end)

RegisterNetEvent('qb-containers:server:Cancel', function(data)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    local players = {}
    if Player then 
        if not data then return end
        if not data.id then return end
        if not Config.Containers.Locations[data.id] then return end
        if Config.Containers.Locations[data.id].Owner == Player.PlayerData.citizenid then 
            Config.Containers.Locations[data.id].isOwned = false
            Config.Containers.Locations[data.id].Owner = nil
            Config.Containers.Locations[data.id].Total = 0
            Config.Containers.Locations[data.id].KeyHolders = {}
            Config.Containers.Locations[data.id].stash.size = Config.Containers.size
            Config.Containers.Locations[data.id].stash.slots = Config.Containers.slots
            MySQL.query("DELETE FROM containers WHERE id = ?", {
                data.id
            })
            QBCore.Functions.Notify(src, 'You have canceled your container # '..data.id..' contract', 'success', 7500)
            TriggerClientEvent('qb-containers:client:Container', -1, Config.Containers)
        end
    end
end)

RegisterNetEvent('qb-containers:server:RemoveKey', function(data)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    if Player then 
        if not data then return end
        if not data.id then return end
        if not Config.Containers.Locations[data.id] then return end
        if Config.Containers.Locations[data.id].Owner == Player.PlayerData.citizenid then 
            for key, holder in pairs(Config.Containers.Locations[data.id].KeyHolders) do 
                if holder.cid == data.cid then 
                    table.remove(Config.Containers.Locations[data.id].KeyHolders, key)
                    MySQL.Async.prepare('UPDATE containers SET keyholders = ? WHERE id = ?', { json.encode(Config.Containers.Locations[data.id].KeyHolders), data.id })
                    QBCore.Functions.Notify(src, 'Key Removed Key Ftom '..data.name..'', 'success', 7500)
                    local Target = QBCore.Functions.GetPlayerByCitizenId(data.cid)
                    if Target then 
                        QBCore.Functions.Notify(Target.PlayerData.source, 'Your Key For Containers # '..data.id..' Have Been Removed By Owner', 'warning', 7500)
                        TriggerClientEvent('qb-containers:client:Container', Target.PlayerData.source, Config.Containers)
                    end
                    return
                end
            end
        else
            QBCore.Functions.Notify(Target.PlayerData.source, 'You Don\'t Have Access', 'error', 7500)
        end
    end
end)