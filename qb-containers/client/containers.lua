
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    QBCore.Functions.TriggerCallback('qb-containers:server:GetContainerConfig', function(ContainerConfig)
        Config.Containers = ContainerConfig
    end)
end)

local function HasKey(cid, Container)
    if not Container or not cid then return false end
    local GlobalConfig = Config.Containers
    if not GlobalConfig.Locations[Container] then return end
    if GlobalConfig.Locations[Container].isOwned then 
        local canChange = false
        for k, v in pairs(GlobalConfig.Locations[Container].KeyHolders) do 
            if v.cid == cid then 
                return true
            end
        end
    else
        return false
    end
    return false
end

RegisterNetEvent('qb-containers:client:Container', function(Info)
    Config.Containers = Info
end)

RegisterNetEvent('qb-containers:client:Confirm', function(data)
    local alert = lib.alertDialog({
        header = 'Confirmation',
        content = 'First Payment $ '..Config.Containers.FirstPayment..'\n\n\n\n\n\n\n Then $ '..Config.Containers.Rent..' Per week',
        centered = true,
        cancel = true
    })
    if alert then 
        if alert == 'confirm' then 
            TriggerServerEvent('qb-containers:server:RentContainer', data)
        end
    end
end)

RegisterNetEvent('qb-containers:client:Cancel', function(data)
    local alert = lib.alertDialog({
        header = 'Confirmation',
        content = 'Are you sure you want to cancel you container contract ?',
        centered = true,
        cancel = true
    })
    if alert then 
        if alert == 'confirm' then 
            TriggerServerEvent('qb-containers:server:Cancel', data)
        end
    end
end)

RegisterNetEvent('qb-containers:client:ContainerMenu', function(data)
    PlayerData = QBCore.Functions.GetPlayerData()
    local GlobalConfig = Config.Containers
    if not GlobalConfig.Locations[data.id] then return end
    if GlobalConfig.Locations[data.id].isOwned then 
        if GlobalConfig.Locations[data.id].Owner == PlayerData.citizenid then 
            local HeaderMsg = "Manage<br> Total Payment: $ "..GlobalConfig.Locations[data.id].Total.."<br>Remaining Payment : $ "..math.ceil(Config.Containers.TotalRent - GlobalConfig.Locations[data.id].Total)..""
            if GlobalConfig.Locations[data.id].Total >= Config.Containers.TotalRent then 
                HeaderMsg = "Manage<br> All payment Have Been Completed"
            end
            exports['qb-menu']:openMenu({
                {
                    header = HeaderMsg,
                    isMenuHeader = true, -- Set to true to make a nonclickable title
                    icon = "fa-solid fa-people-roof",
                },
                {
                    header = "Stash",
                    txt = "Open Stash",
                    icon = "fa-regular fa-warehouse",
                    params = {
                        event = "qb-containers:client:ContainerStash",
                        args = {
                            id = data.id,
                        }
                    }
                },
                {
                    header = "Manage",
                    txt = "Manage Weight / Slots",
                    icon = "fa-solid fa-list-check",
                    params = {
                        event = "qb-containers:client:ContainerManage",
                        args = {
                            id = data.id,
                        }
                    }
                },
                {
                    header = "Give Key",
                    txt = "Give Key To Some One",
                    icon = "fa-regular fa-hand-holding-hand",
                    params = {
                        isServer = true,
                        event = "qb-containers:server:Key",
                        args = {
                            id = data.id,
                        }
                    }
                },
                {
                    header = "Remove Key",
                    txt = "Remove Key From Some One",
                    icon = "fa-solid fa-person-circle-minus",
                    params = {
                        isServer = true,
                        event = "qb-containers:server:RemoveKeyList",
                        args = {
                            id = data.id,
                        }
                    }
                },
                {
                    header = "Transfer",
                    txt = "Transfer Your Container To Some One",
                    icon = "fa-regular fa-turn-down-right",
                    params = {
                        isServer = true,
                        event = "qb-containers:server:Transfer",
                        args = {
                            id = data.id,
                        }
                    }
                },
                {
                    header = "Cancel",
                    txt = "Cancel Your Container Contract",
                    icon = "fa-duotone fa-trash",
                    params = {
                        event = "qb-containers:client:Cancel",
                        args = {
                            id = data.id,
                        }
                    }
                },
                {
                    header = "Exit",
                    icon = "fa-regular fa-circle-xmark",
                    params = {
                        event = "qb-menu:closeMenu",
                    }
                }
            })
        elseif HasKey(PlayerData.citizenid, data.id) then 
            TriggerEvent('qb-containers:client:ContainerStash', {id = data.id})
        else
            QBCore.Functions.Notify('You don\'t have access', 'error', 7500)
        end
    else
        local GlobalConfig = Config.Containers
        local ContainerMenu = {
            {
                header = "Containers<br><br>First Payment : $ "..Config.Containers.FirstPayment.."",
                isMenuHeader = true, -- Set to true to make a nonclickable title
                icon = "fa-duotone fa-building-user",
            },
        }
        if not GlobalConfig.Locations[data.id].isOwned then 
            ContainerMenu[#ContainerMenu + 1] = {
                header = 'Container #'..data.id,
                txt = 'Rent This Container For $ '..Config.Containers.Rent..' Per Week',
                icon = "fa-regular fa-building-user",
                params = {
                    event = 'qb-containers:client:Confirm',
                    args = {
                        container = data.id
                    }
                }
            }
        end
        ContainerMenu[#ContainerMenu + 1] = {
            header = "Exit",
            icon = "fa-regular fa-circle-xmark",
            params = {
                event = "qb-menu:closeMenu",
            }
        }
        if #ContainerMenu > 0 then 
            exports['qb-menu']:openMenu(ContainerMenu)
        end
    end
end)

RegisterNetEvent('qb-containers:client:ContainerManage', function(data)
    local ContainerMenu = {
        {
            header = "Manage",
            isMenuHeader = true, -- Set to true to make a nonclickable title
        },
        {
            header = 'Rise weight',
            txt = 'Rise your stash weight',
            icon = "fa-regular fa-user",
            params = {
                event = 'qb-containers:client:ContainerManageSrcond',
                args = {
                    actions = 'weight',
                    id = data.id,
                }
            }
        },
        {
            header = 'More Slots',
            txt = 'Add more slots to your stash',
            icon = "fa-regular fa-user",
            params = {
                event = 'qb-containers:client:ContainerManageSrcond',
                args = {
                    actions = 'slots',
                    id = data.id,
                }
            }
        },
    }
    ContainerMenu[#ContainerMenu + 1] = {
        header = "Exit",
        icon = "fa-regular fa-circle-xmark",
        params = {
            event = "qb-menu:closeMenu",
        }
    }
    if #ContainerMenu > 0 then 
        exports['qb-menu']:openMenu(ContainerMenu)
    end
end)

RegisterNetEvent('qb-containers:client:ContainerManageSrcond', function(data)
    if data.actions == 'weight' then 
        local ContainerMenu = {
            {
                header = "Rise weight",
                isMenuHeader = true, -- Set to true to make a nonclickable title
            },
        }
        for k, v in pairs(Config.Containers.Capac) do 
            ContainerMenu[#ContainerMenu + 1] = {
                header = 'Option # '..k,
                txt = 'Rise this stash to '..math.ceil(v.size / 1000)..' KG for $ '..v.price..'<br> Money Type : in game money',
                icon = "fa-regular fa-user",
                params = {
                    isServer = true,
                    event = 'qb-containers:server:ContainerManageSrcond',
                    args = {
                        action = 'weight',
                        option = v.size,
                        price = v.price,
                        id = data.id,
                        money = v.money,
                    }
                }
            }
        end
        ContainerMenu[#ContainerMenu + 1] = {
            header = "Exit",
            icon = "fa-regular fa-circle-xmark",
            params = {
                event = "qb-menu:closeMenu",
            }
        }
        if #ContainerMenu > 0 then 
            exports['qb-menu']:openMenu(ContainerMenu)
        end
    elseif data.actions == 'slots' then 
        local ContainerMenu = {
            {
                header = "More Slots",
                isMenuHeader = true, -- Set to true to make a nonclickable title
            },
        }
        for k, v in pairs(Config.Containers.Capac) do 
            ContainerMenu[#ContainerMenu + 1] = {
                header = 'Option # '..k,
                txt = 'Upgrade to '..v.slots..' slots for $ '..v.price..'<br> Money Type : in game money',
                icon = "fa-regular fa-user",
                params = {
                    isServer = true,
                    event = 'qb-containers:server:ContainerManageSrcond',
                    args = {
                        action = 'slots',
                        option = v.slots,
                        price = v.price,
                        id = data.id,
                        money = v.money,
                    }
                }
            }
        end
        ContainerMenu[#ContainerMenu + 1] = {
            header = "Exit",
            icon = "fa-regular fa-circle-xmark",
            params = {
                event = "qb-menu:closeMenu",
            }
        }
        if #ContainerMenu > 0 then 
            exports['qb-menu']:openMenu(ContainerMenu)
        end
    end
end)

RegisterNetEvent('qb-containers:client:RemoveKeyList', function(data, players)
    if players then 
        local ContainerMenu = {
            {
                header = "Remove Key",
                isMenuHeader = true, -- Set to true to make a nonclickable title
            },
        }
        for k, v in pairs(players) do 
            ContainerMenu[#ContainerMenu + 1] = {
                header = 'name : '..v.name,
                txt = '',
                icon = "fa-regular fa-user",
                params = {
                    isServer = true,
                    event = 'qb-containers:server:RemoveKey',
                    args = {
                        cid = v.citizenid,
                        name = v.name,
                        id = data.id,
                    }
                }
            }
        end
        ContainerMenu[#ContainerMenu + 1] = {
            header = "Exit",
            icon = "fa-regular fa-circle-xmark",
            params = {
                event = "qb-menu:closeMenu",
            }
        }
        if #ContainerMenu > 0 then 
            exports['qb-menu']:openMenu(ContainerMenu)
        end
    end
end)

RegisterNetEvent('qb-containers:client:Key', function(data, players)
    if players then 
        local ContainerMenu = {
            {
                header = "Give Key",
                isMenuHeader = true, -- Set to true to make a nonclickable title
            },
        }
        for k, v in pairs(players) do 
            ContainerMenu[#ContainerMenu + 1] = {
                header = 'name : '..v.name,
                txt = '',
                icon = "fa-regular fa-user",
                params = {
                    isServer = true,
                    event = 'qb-containers:server:GiveKey',
                    args = {
                        cid = v.citizenid,
                        id = data.id,
                    }
                }
            }
        end
        ContainerMenu[#ContainerMenu + 1] = {
            header = "Exit",
            icon = "fa-regular fa-circle-xmark",
            params = {
                event = "qb-menu:closeMenu",
            }
        }
        if #ContainerMenu > 0 then 
            exports['qb-menu']:openMenu(ContainerMenu)
        end
    end
end)

RegisterNetEvent('qb-containers:client:Transfer', function(data, players)
    if players then 
        local ContainerMenu = {
            {
                header = "Transfer",
                isMenuHeader = true, -- Set to true to make a nonclickable title
            },
        }
        for k, v in pairs(players) do 
            ContainerMenu[#ContainerMenu + 1] = {
                header = 'name : '..v.name,
                txt = '',
                icon = "fa-regular fa-user",
                params = {
                    isServer = true,
                    event = 'qb-containers:server:TransferConfirm',
                    args = {
                        cid = v.citizenid,
                        id = data.id,
                    }
                }
            }
        end
        ContainerMenu[#ContainerMenu + 1] = {
            header = "Exit",
            icon = "fa-regular fa-circle-xmark",
            params = {
                event = "qb-menu:closeMenu",
            }
        }
        if #ContainerMenu > 0 then 
            exports['qb-menu']:openMenu(ContainerMenu)
        end
    end
end)

RegisterNetEvent('qb-containers:client:TransferConfirm', function(data)
    local alert = lib.alertDialog({
        header = 'Confirmation',
        content = 'Do you accept tp transfer container '..data.id..' from [ '..data.Or..' ] to your name ?',
        centered = true,
        cancel = true
    })
    if alert then 
        if alert == 'confirm' then 
            TriggerServerEvent('qb-containers:server:TransferAccept', data)
        end
    end
end)

RegisterNetEvent('qb-containers:client:ContainerStash', function(data)
    local GlobalConfig = Config.Containers
    if not GlobalConfig.Locations[data.id] then return end
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "container_"..data.id, {
        maxweight = Config.Containers.Locations[data.id].stash.size,
        slots = Config.Containers.Locations[data.id].stash.slots,
    })
    TriggerEvent("inventory:client:SetCurrentStash", "container_"..data.id)
end)


CreateThread(function()
    for k, v in pairs(Config.Containers.Locations) do 
        exports['qb-target']:AddBoxZone('ocontainer'..v.stash.name..''..k, v.stash.coords, v.stash.info1, v.stash.info2, {
            name= 'ocontainer'..v.stash.name..''..k,
            heading= v.stash.heading,
            debugPoly= false,
            minZ= v.stash.minZ,
            maxZ= v.stash.maxZ
        }, {
            options = v.stash.options,
            distance = v.stash.distance, 
        })
    end
end)