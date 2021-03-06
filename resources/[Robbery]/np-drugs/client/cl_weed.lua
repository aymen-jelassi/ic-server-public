local knownCrops, isBusy = {}, false

local cropstatus = {
	[1] = { ["info"] = "Looks Good" },
	[2] = { ["info"] = "Needs Water" },
}

local closest = 0
local distance = 6969.0
local closestInfo = {}
local plyPed = PlayerPedId()
local plyCoords = vec3(0, 0, 0)

local function ShouldDeduct(sentType)
    if sentType == 'maleseed' then return 2 end
    if sentType == 'highgradefemaleseed' then return 0.7 end
    if sentType == 'femaleseed' then return 0.7 end
    return 1
end

local isInHouse = true
RegisterNetEvent("house:InHouse")
AddEventHandler("house:InHouse", function(value)
	isInHouse = true
end)



RegisterNetEvent('np-weed:knownCrops')
AddEventHandler('np-weed:knownCrops', function(sentInfo, currentTime)

    local hellYeah = {}

    TriggerEvent('np-weed:DeleteKnownCrops')
    knownCrops = hellYeah

    for i=1, #sentInfo do
        local justCuz = sentInfo[i]
        if justCuz ~= nil then
            local huhstatus = 2
            local currTime = tonumber(justCuz['time'])

            if tonumber(justCuz['growth']) ~= 0 then
                if currTime - currentTime <= 0 then 
                    huhstatus = 2
                else
                    huhstatus = 1 
                end
            end


            hellYeah[#hellYeah+1] = {
                ['coords'] = vector3(justCuz['x'], justCuz['y'], justCuz['z']),
                ['growth'] = tonumber(justCuz['growth']),
                ['type'] = justCuz['type'],
                ['knownId'] = tonumber(justCuz['id']),
                ['status'] = huhstatus
            }
        end
    end

    knownCrops = hellYeah
end)

AddEventHandler('np-weed:DeleteKnownCrops', function()
    for i = 1, #knownCrops do
        if knownCrops[i] ~= nil then
            local ObjectFound = knownCrops[i]["object"]
            if ObjectFound and DoesEntityExist(ObjectFound) then
                DeleteObject(ObjectFound)
                DeleteEntity(ObjectFound)
            end
        end
	end
end)

function GetCropProp(info)
    local theModel = `bkr_prop_weed_med_01b`
    if info['type'] == 'placeholder' then theModel = `prop_plant_fern_02a` end
    if info['growth'] < 33 then -- 1st Stage.
        theModel = `bkr_prop_weed_01_small_01b`
        if info['type'] == 'placeholder' then theModel = `prop_plant_fern_02a` end
    elseif info['growth'] > 66 then
        theModel = `bkr_prop_weed_lrg_01b`
        if info['type'] == 'placeholder' then theModel = `prop_plant_fern_02a` end
    end
    return theModel
end

function CreateKnownCrop(sentId)
    if sentId then

        local theModel = `bkr_prop_weed_med_01b`
        local size = 3.55

        if knownCrops[sentId]['type'] == 'placeholder' then -- 2nd Stage.
            theModel = `prop_plant_fern_02a`
        end

        if knownCrops[sentId]['growth'] < 33 then -- 1st Stage.
            size = 1
            theModel = `bkr_prop_weed_01_small_01b`

            if knownCrops[sentId]['type'] == 'placeholder' then
                theModel = `prop_plant_fern_02a`
            end

        elseif knownCrops[sentId]['growth'] > 66 then -- 3rd Stage.
            theModel = `bkr_prop_weed_lrg_01b`

            if knownCrops[sentId]['type'] == 'placeholder' then
                theModel = `prop_plant_fern_02a`
            end

        end
        
        RequestModel(theModel)
        while not HasModelLoaded(theModel) do
            Wait(10)
        end
        
        
        local theZ = knownCrops[sentId]['coords']['z']-size
       
        if knownCrops[sentId]['type'] == 'placeholder' then
            theZ = (theZ + size) + 0.5
        end

        local CreatedObject = CreateObject(theModel, knownCrops[sentId]['coords']['x'], knownCrops[sentId]['coords']['y'], theZ, false, false, false)
        PlaceObjectOnGroundProperly(CreatedObject)
        SetEntityCollision(CreatedObject, false, false)
        knownCrops[sentId]["object"] = CreatedObject
    end
end


local inhouse = true
RegisterNetEvent("inhouse")
AddEventHandler("inhouse", function(status)
    inhouse = status
end)

RegisterNetEvent('np-weed:plantSeed')
AddEventHandler('np-weed:plantSeed', function(sentType)
    if not isBusy  then
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh == 0 then
            local success = true
            isBusy = true

            if knownCrops[1] ~= nil then
                for i = 1, #knownCrops do
                    if knownCrops[i] ~= nil then
                        local dist = #(knownCrops[i]['coords'] - GetEntityCoords(plyPed))
                        if dist < 1.5 then success = false break end
                    end
                end
            end
            
            if success then
                if exports["np-inventory"]:hasEnoughOfItem(sentType,1,false) then
                    TriggerEvent("animation:PlayAnimation","gardening")
                local finished = exports["np-taskbar"]:taskBar(10000,"Planting Seed",true,false)
                if (finished == 100) then
                        TriggerEvent("inventory:removeItem", sentType, 1)
                        NewPlant(sentType)
                        TriggerEvent("animation:PlayAnimation","cancel")
                        ClearPedTasks(ped)
                    end
                else
                    ClearPedTasks(ped)
                end
            end
        else
			TriggerEvent('DoLongHudText', "You are in a vehicle", 2)
        end
        isBusy = false
    end
end)

RegisterNetEvent('np-weed:destroyPlant')
AddEventHandler('np-weed:destroyPlant', function(sentType)
    if not isBusy then
        plyCoords = GetEntityCoords(plyPed)
        isBusy = true

        local knownInfo = {
            ['id'] = 0,
            ['dist'] = 1000
        }

        for i=1, #knownCrops do
            if knownCrops[i] ~= nil then
                local dist = #(knownCrops[i]['coords'] - plyCoords)
                
                if dist < knownInfo['dist'] then
                    knownInfo['dist'] = dist 
                    knownInfo['id'] = i
                end
            end
        end

        if knownInfo['id'] > 0 and knownInfo['dist'] < 4 then
            if knownCrops[knownInfo['id']]['object'] and DoesEntityExist(knownCrops[knownInfo['id']]['object']) then
                TriggerServerEvent("np-weed:killplant", knownCrops[knownInfo['id']]['knownId'])
            end
        end

        isBusy = false

    end
end)


function NewPlant(sentType)
	TriggerServerEvent("np-weed:newplant", GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.4, 0.0), sentType)
end

--[[
    Status' that can be sent:

    0 = Delete,
    1 = Alter,
    2 = Convert,
    3 = New
]]

RegisterNetEvent('np-weed:updatePlant')
AddEventHandler('np-weed:updatePlant', function(updateType, sentId, sentGrowth, sentTime, sentStatus, sentNewInfo, currentTime)
    if updateType == 0 then
        for i=1, #knownCrops do
            if knownCrops[i] ~= nil then
                if knownCrops[i]['knownId'] == sentId then
                    local currObj = knownCrops[i]['object']
                    table.remove(knownCrops, i)
                    if currObj and DoesEntityExist(currObj) then
                        DeleteObject(currObj) 
                        DeleteEntity(currObj)
                    end
                    break
                end
            end 
        end 
    elseif updateType == 1 then
        for i=1, #knownCrops do
            if knownCrops[i] ~= nil then
                if knownCrops[i]['knownId'] == sentId then
                    
                    local huhstatus = 2
                    local currGrowth = tonumber(sentGrowth)

                    if currGrowth ~= 0 then
                        if currGrowth - currentTime <= 0 then 
                            huhstatus = 2
                        else
                            huhstatus = 1 
                        end
                    end

                    local huhstatus = 2
                    local currTime = tonumber(sentTime)
        
                    if tonumber(sentGrowth) ~= 0 then
                        if currTime - currentTime <= 0 then 
                            huhstatus = 2
                        else
                            huhstatus = 1 
                        end
                    end

                    knownCrops[i]['growth'] = sentGrowth
                    knownCrops[i]['time'] = sentTime
                    knownCrops[i]['status'] = huhstatus
                    break 
                end 
            end 
        end 
    elseif updateType == 2 then
        -- Adjust later on.
    elseif updateType == 2 and sentNewInfo then
        knownCrops[#knownCrops+1] = {
            ['coords'] = vector3(sentNewInfo['x'], sentNewInfo['y'], sentNewInfo['z']),
            ['growth'] = tonumber(sentNewInfo['growth']),
            ['type'] = sentNewInfo['type'],
            ['knownId'] = tonumber(sentId),
            ['time'] = tonumber(sentTime),
            ['status'] = tonumber(sentStatus)
        }
    end 
end)

-- Now for the thread

local TyPes = {
    ['maleseed'] = 'Kush',
    ['femaleseed'] = 'Stardawg',
    ['highgradefemaleseed'] = 'Gelato'
}

CreateThread(function()
    while true do

        Wait(1000)
        
        plyPed = PlayerPedId()
        plyCoords = GetEntityCoords(plyPed)
        
        local Fdistance = 6969.0
        local Fclosest = 0

        for i=1, #knownCrops do
            local info = knownCrops[i]
            if info then
                local knownDistance = #(info['coords'] - plyCoords)

                if knownDistance <= 40 then
                    if knownDistance <= Fdistance then
                        Fdistance = knownDistance
                        Fclosest = i
                    end

                    if knownCrops[i]['object'] == nil then
                        CreateKnownCrop(i)
                    elseif knownCrops[i]['object'] and not DoesEntityExist(knownCrops[i]['object']) then
                        CreateKnownCrop(i)
                    end
                elseif knownCrops[i]['object'] then
                    while knownCrops[i]['object'] ~= nil do
                        DeleteObject(knownCrops[i]['object'])
                        DeleteEntity(knownCrops[i]['object'])
                        if not DoesEntityExist(knownCrops[i]['object']) then
                            knownCrops[i]['object'] = nil
                        end
                        Wait(0)
                    end               
                end
            end
        end

        if Fdistance >= 40 then
            distance = 6969.0
            closest = 0
            closestInfo = {}
        else
            distance = Fdistance
            closest = Fclosest
            closestInfo = knownCrops[Fclosest]
        end
    end
end)


function DrawText3D(coords, text)
    local onScreen,_x,_y=World3dToScreen2d(table.unpack(coords))
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

CreateThread(function()
    while true do
        Wait(0)
        
        if closest ~= 0 and closestInfo then
            local currCrop = closestInfo
            local cropDist = distance
            if cropDist <= 4 and currCrop then
                local num = tonumber(currCrop["status"])
                DrawText3D(currCrop['coords'], "   [E] | " .. TyPes[currCrop["type"]] .. "  Strain | " .. currCrop["growth"] .. "% - " .. cropstatus[num]["info"].."   ")

                if cropDist <= 2 then
                    if IsControlJustReleased(0, 38) then
                        if closestInfo["growth"] >= 100 then
                            TriggerEvent("animation:PlayAnimation","mechanic4")
                            local finished = exports["np-taskbar"]:taskBar(8000,"Picking",false,false)
                            if (finished == 100) then
                                TriggerEvent("animation:PlayAnimation","cancel")
                                ClearPedTasks(PlayerPedId())
                                if currCrop and currCrop["knownId"] then
                                    TriggerEvent("np-weed:destroyPlant")
                                    TriggerEvent("np-weed:DeleteKnownCrops")
                                    TriggerServerEvent('np-weed:killplant', currCrop["knownId"])
                                    DeleteObject(ObjectFound)
                                    DeleteEntity(ObjectFound)
                                  
                                    if currCrop["type"] == 'maleseed' then
                                        TriggerEvent( "player:receiveItem","weedq", math.random(13,17))
                                        if math.random(1, 10) >= 6 then
                                            TriggerEvent( "player:receiveItem","femaleseed", math.random(1,2))
                                        elseif math.random(1, 10) >= 4 then
                                            TriggerEvent( "player:receiveItem","highgradefemaleseed", 1) 
                                        end
                                    elseif currCrop["type"] == 'femaleseed' then
                                        TriggerEvent( "player:receiveItem","weedq", math.random(13,23))
                                        if math.random(1, 10) >= 8 then
                                            TriggerEvent( "player:receiveItem","weedq", 1)
                                        elseif math.random(1, 10) >= 6 then
                                            TriggerEvent( "player:receiveItem","highgradefemaleseed", math.random(1, 2)) 
                                        end
                                    elseif currCrop["type"] == 'highgradefemaleseed' then
                                        TriggerEvent( "player:receiveItem","weedq",math.random(17,35))
                                        TriggerEvent( "player:receiveItem","maleseed",math.random(1,3))
                                        TriggerEvent( "player:receiveItem","femaleseed",math.random(1,3))
                                    end
                                else
                                    print("Unknown crop?")
                                end
                            end 
                        elseif num == 1 then 
							TriggerEvent('DoLongHudText', "This Crop Does Not Need To Be Cared For!", 2)
                        elseif num == 2 then
                            if exports["np-inventory"]:hasEnoughOfItem("water",1,false) then
                                TriggerEvent("inventory:removeItem", "water", 1)
                                local nerfer = ShouldDeduct(currCrop["type"])
                                local new = math.ceil(currCrop["growth"] + math.random(14,17) / nerfer)
                                TriggerServerEvent("np-weed:updateStatus", 'update', currCrop["knownId"], new, 'water')
                                TriggerEvent("DoLongHudText", "Watering the plant",1)
                            else
								TriggerEvent('DoLongHudText', "You're Missing some Water", 2)
                            end
                        end
                        Wait(1000)
                    end
                end
            else
                Wait(500)
            end
        else
            Wait(500)
        end
    end
end)