LinkLuaModifier("modifier_nocollision","libraries/modifiers/modifier_nocollision",LUA_MODIFIER_MOTION_NONE)
_G.spawners = {
   "path10",
   "path50",
   "path150",
   "path100",

}
_G.spawnersNames = {
    "path10",
    "path50",
    "path150",
    "path100",
 
 }
_G.allcreeps = {
    
    {
        name = "npc_dota_neutral_kobold",
        count = 15,
    },
    {
        name = "npc_dota_creep_goodguys_melee",
        count = 10,
    }
}
if WaveClass == nil then WaveClass = {} end

function WaveClass:Init()
    if not _G.allcreeps then
        _G.allcreeps = {
    
            {
                name = "npc_dota_neutral_kobold",
                count = 15,
            },
            {
                name = "npc_dota_creep_goodguys_melee",
                count = 10,
            }
        }
    end
    if not _G.spawners then
        _G.spawners = {
            "path10",
            "path50",
            "path150",
            "path100",
         
         }
    end
    if not _G.killscreeps then
        _G.killscreeps = {} 
    end
    if not _G.CreepCounter then
        _G.CreepCounter = {} 
    end
    if not _G.Teams then
        _G.Teams = {} 
    end
    if not _G.gamemode then
        _G.gamemode = "no"
    end
    if not _G.Players then
        _G.Players = {}
    end
    if not _G.Cplayers then
        _G.Cplayers = 0
    end
    if not _G.TeamNumber then
        _G.TeamNumber = {}
    end
    if not _G.round then
        _G.round = 1
    end



    WaveClass:StartGameTimer()

    for i=1 ,4 do
        _G.spawners[i] = Entities:FindByName(nil, _G.spawners[i])
    end





end

function WaveClass:StartGameTimer()
    local secunds = 10
    Timers:CreateTimer(0.01, function ()
        if secunds == 0 then 
            CustomGameEventManager:Send_ServerToAllClients("CloseStartGameTimer", {})
            WaveClass:StartRound()
            local countplayers = _G.Cplayers
            if countplayers == 1 then 
                _G.gamemode = "Solo"
            end
            if countplayers == 2 then 
                _G.gamemode = "Duo"
            end
            if countplayers == 3 then 
                _G.gamemode = "Trio"
            end
            if countplayers == 4 then 
                _G.gamemode = "All"
            end
        end
        CustomGameEventManager:Send_ServerToAllClients("UpdateStartGameTimer", {sec = secunds})
        secunds = secunds - 1
        return 1
    end)
end




function WaveClass:StartRound()
    print("ROUND".. _G.round)
    CustomGameEventManager:Send_ServerToAllClients("UpdateCreepCount", {
        round = _G.round, 
        maxcount = _G.allcreeps[_G.round].count, 
        count = _G.allcreeps[_G.round].count,
        name = _G.allcreeps[_G.round].name 
    })
    local countplayers = _G.Cplayers
    if countplayers == 1 then 
        WaveClass:StartWaveSolo()
    end
    if countplayers == 2 then 
        WaveClass:StartWaveDuo()
    end
    if countplayers == 3 then 
        WaveClass:StartWaveTrio()
    end
    if countplayers == 4 then 
        WaveClass:SpawnAllCreeps()
    end

end



function WaveClass:StartWaveSolo()
    local count = _G.allcreeps[_G.round].count
    
    local teamNumber 
    for i, player in pairs(_G.Players) do
        if player then
            teamNumber = player:GetTeamNumber()
        end
    end

    _G.CreepCounter[teamNumber] = count
    local spawner
    local spawnersNames
    if teamNumber == 2 then
        spawner = _G.spawners[1]
        spawnersNames = _G.spawnersNames[1]
    elseif teamNumber == 3 then
        spawner = _G.spawners[4]
        spawnersNames = _G.spawnersNames[4]
    elseif teamNumber == 6 then
        spawner = _G.spawners[2]
        spawnersNames = _G.spawnersNames[2]
    elseif teamNumber == 7 then
        spawner = _G.spawners[3]
        spawnersNames = _G.spawnersNames[3]
    end
    Timers:CreateTimer(0.5 , function ()
        if count == _G.allcreeps[_G.round].count then
            CustomGameEventManager:Send_ServerToTeam(teamNumber, "UpdateCreepCount", {count = count})
        end
        count = count - 1
        local unit = CreateUnitByName(_G.allcreeps[_G.round].name, spawner:GetAbsOrigin(), true, nil,nil, 4)

        unit.teamnumber = teamNumber
        unit:AddNewModifier(unit, nil, "modifier_nocollision", {})
        unit.unitname =  _G.allcreeps[_G.round].name
        unit:SetInitialWaypoint(spawnersNames)
        if count == 0 then
            return 
        end
        return 1
    end)
    
end

function WaveClass:StartWaveDuo()
    
    local spawner1 
    local spawner2
    local teams = {}
    for i = 0, _G.Cplayers do
        local player = _G.Players[i]
        if player then
            local team = player:GetTeamNumber()
            table.insert(teams,team)
        end
    end
    
    
    local teamNumberPlayer1, teamNumberPlayer2 = teams[1] , teams[2]
    local spawnersNames1
    if teamNumberPlayer1 == 2 then
        spawner1 = _G.spawners[1]
        spawnersNames1 = _G.spawnersNames[1]
    elseif teamNumberPlayer1 == 3 then
        spawner1 = _G.spawners[4]
        spawnersNames1 = _G.spawnersNames[4]
    elseif teamNumberPlayer1 == 6 then
        spawner1 = _G.spawners[2]
        spawnersNames1 = _G.spawnersNames[2]
    elseif teamNumberPlayer1 == 7 then
        spawner1 = _G.spawners[3]
        spawnersNames1 = _G.spawnersNames[3]
    end

    local spawnersNames2
    if teamNumberPlayer2 == 2 then
        spawner2 = _G.spawners[1]
        spawnersNames2 = _G.spawnersNames[1]
    elseif teamNumberPlayer2 == 3 then
        spawner2 = _G.spawners[4]
        spawnersNames2 = _G.spawnersNames[4]
    elseif teamNumberPlayer2 == 6 then
        spawner2 = _G.spawners[2]
        spawnersNames2 = _G.spawnersNames[2]
    elseif teamNumberPlayer2 == 7 then
        spawner2 = _G.spawners[3]
        spawnersNames2 = _G.spawnersNames[3]
    end

    count1 = _G.allcreeps[_G.round].count
    count2 = _G.allcreeps[_G.round].count
    _G.CreepCounter[teamNumberPlayer1] = count1
    _G.CreepCounter[teamNumberPlayer2] = count2
    Timers:CreateTimer(0.5 , function ()
        if count1 == _G.allcreeps[_G.round].count then
            CustomGameEventManager:Send_ServerToTeam(teamNumberPlayer1, "UpdateCreepCount", {count = count1})
        end
        if count2 == _G.allcreeps[_G.round].count then
            CustomGameEventManager:Send_ServerToTeam(teamNumberPlayer2, "UpdateCreepCount", {count = count2})
        end

        count1 = count1 - 1
        count2 = count2 - 1

        local unit1 = CreateUnitByName(_G.allcreeps[_G.round].name, spawner1:GetAbsOrigin(), true, nil,nil, 4)
        unit1.teamnumber = teamNumberPlayer1
        unit1:AddNewModifier(unit1, nil, "modifier_nocollision", {})
        unit1.unitname =  _G.allcreeps[_G.round].name
        unit1:SetInitialWaypoint(spawnersNames1)

        local unit2 = CreateUnitByName(_G.allcreeps[_G.round].name, spawner2:GetAbsOrigin(), true, nil,nil, 4) 
        unit2.teamnumber = teamNumberPlayer2
        unit2:AddNewModifier(unit2, nil, "modifier_nocollision", {})
        unit2.unitname =  _G.allcreeps[_G.round].name
        unit2:SetInitialWaypoint(spawnersNames2)

        if count1 == 0 then
            return 
        end
        
        return 1
    end)
end

function WaveClass:StartWaveTrio()
    
    local teams = {}
    for i = 0, _G.Cplayers do
        local player = _G.Players[i]
        if player then
            local team = player:GetTeamNumber()
            table.insert(teams,team)
        end
    end
    local teamNumberPlayer1, teamNumberPlayer2,teamNumberPlayer3 = teams[1] , teams[2], teams[3]
    local spawner1 
    local spawnersNames1
    if teamNumberPlayer1 == 2 then
        spawner1 = _G.spawners[1]
        spawnersNames1 = _G.spawnersNames[1]
    elseif teamNumberPlayer1 == 3 then
        spawner1 = _G.spawners[4]
        spawnersNames1 = _G.spawnersNames[4]
    elseif teamNumberPlayer1 == 6 then
        spawner1 = _G.spawners[2]
        spawnersNames1 = _G.spawnersNames[2]
    elseif teamNumberPlayer1 == 7 then
        spawner1 = _G.spawners[3]
        spawnersNames1 = _G.spawnersNames[3]
    end
    local spawner2
    local spawnersNames2
    if teamNumberPlayer2 == 2 then
        spawner2 = _G.spawners[1]
        spawnersNames2 = _G.spawnersNames[1]
    elseif teamNumberPlayer2 == 3 then
        spawner2 = _G.spawners[4]
        spawnersNames2 = _G.spawnersNames[4]
    elseif teamNumberPlayer2 == 6 then
        spawner2 = _G.spawners[2]
        spawnersNames2 = _G.spawnersNames[2]
    elseif teamNumberPlayer2 == 7 then
        spawner2 = _G.spawners[3]
        spawnersNames2 = _G.spawnersNames[3]
    end


    local spawner3
    local spawnersNames3
    if teamNumberPlayer3 == 2 then
        spawner3 = _G.spawners[1]
        spawnersNames3 = _G.spawnersNames[1]
    elseif teamNumberPlayer3 == 3 then
        spawner3 = _G.spawners[4]
        spawnersNames3 = _G.spawnersNames[4]
    elseif teamNumberPlayer3 == 6 then
        spawner3 = _G.spawners[2]
        spawnersNames3 = _G.spawnersNames[2]
    elseif teamNumberPlayer3 == 7 then
        spawner3 = _G.spawners[3]
        spawnersNames3 = _G.spawnersNames[3]
    end
    
    
    count1 = _G.allcreeps[_G.round].count
    count2 = _G.allcreeps[_G.round].count
    count3 = _G.allcreeps[_G.round].count
    
    _G.CreepCounter[teamNumberPlayer1] = count1
    _G.CreepCounter[teamNumberPlayer2] = count2
    _G.CreepCounter[teamNumberPlayer3] = count3
    
    Timers:CreateTimer(0.5 , function ()
        if count1 == _G.allcreeps[_G.round].count then
            CustomGameEventManager:Send_ServerToTeam(teamNumberPlayer1, "UpdateCreepCount", {count = count1})
        end
        if count2 == _G.allcreeps[_G.round].count then
            CustomGameEventManager:Send_ServerToTeam(teamNumberPlayer2, "UpdateCreepCount", {count = count2})
        end
        if count3 == _G.allcreeps[_G.round].count then
            CustomGameEventManager:Send_ServerToTeam(teamNumberPlayer3, "UpdateCreepCount", {count = count3})
        end
        count1 = count1 - 1
        count2 = count2 - 1
        count3 = count3 - 1


        local unit1 = CreateUnitByName(_G.allcreeps[_G.round].name, spawner1:GetAbsOrigin(), true, nil,nil, 4) 

        unit1.teamnumber = teamNumberPlayer1
        
        unit1:AddNewModifier(unit1, nil, "modifier_nocollision", {})
        unit1.unitname =  _G.allcreeps[_G.round].name
        unit1:SetInitialWaypoint(spawnersNames1)

        local unit2 = CreateUnitByName(_G.allcreeps[_G.round].name, spawner2:GetAbsOrigin(), true, nil,nil, 4) 
        
        unit2.teamnumber = teamNumberPlayer2
        
        unit2:AddNewModifier(unit2, nil, "modifier_nocollision", {})
        unit2.unitname =  _G.allcreeps[_G.round].name
        unit1:SetInitialWaypoint(spawnersNames2)

        local unit3 = CreateUnitByName(_G.allcreeps[_G.round].name, spawner3:GetAbsOrigin(), true, nil,nil, 4) 
        
        unit3.teamnumber = teamNumberPlayer3

        unit3:AddNewModifier(unit3, nil, "modifier_nocollision", {})
        unit3.unitname =  _G.allcreeps[_G.round].name
        unit1:SetInitialWaypoint(spawnersNames3)

        if count1 == 0 then
            return 
        end
        
        return 1
    end)
end



function WaveClass:SpawnAllCreeps()
    
    local teamNumberPlayer1, teamNumberPlayer2, teamNumberPlayer3, teamNumberPlayer4 = _G.Players[0]:GetTeamNumber() , _G.Players[1]:GetTeamNumber() , _G.Players[2]:GetTeamNumber() , _G.Players[3]:GetTeamNumber() 
    
    

    local spawner1
    local spawnersNames1
    if teamNumberPlayer1 == 2 then
        spawner1 = _G.spawners[1]
        spawnersNames1 = _G.spawnersNames[1]
    elseif teamNumberPlayer1 == 3 then
        spawner1 = _G.spawners[4]
        spawnersNames1 = _G.spawnersNames[4]
    elseif teamNumberPlayer1 == 6 then
        spawner1 = _G.spawners[2]
        spawnersNames1 = _G.spawnersNames[2]
    elseif teamNumberPlayer1 == 7 then
        spawner1 = _G.spawners[3]
        spawnersNames1 = _G.spawnersNames[3]
    end
    

    local spawner2
    local spawnersNames2
    if teamNumberPlayer2 == 2 then
        spawner2 = _G.spawners[1]
        spawnersNames2 = _G.spawnersNames[1]
    elseif teamNumberPlayer2 == 3 then
        spawner2 = _G.spawners[4]
        spawnersNames2 = _G.spawnersNames[4]
    elseif teamNumberPlayer2 == 6 then
        spawner2 = _G.spawners[2]
        spawnersNames2 = _G.spawnersNames[2]
    elseif teamNumberPlayer2 == 7 then
        spawner2 = _G.spawners[3]
        spawnersNames2 = _G.spawnersNames[3]
    end

    local spawner3
    local spawnersNames3
    if teamNumberPlayer3 == 2 then
        spawner3 = _G.spawners[1]
        spawnersNames3 = _G.spawnersNames[1]
    elseif teamNumberPlayer3 == 3 then
        spawner3 = _G.spawners[4]
        spawnersNames3 = _G.spawnersNames[4]
    elseif teamNumberPlayer3 == 6 then
        spawner3 = _G.spawners[2]
        spawnersNames3 = _G.spawnersNames[2]
    elseif teamNumberPlayer3 == 7 then
        spawner3 = _G.spawners[3]
        spawnersNames3 = _G.spawnersNames[3]
    end

    local spawner4
    local spawnersNames4
    if teamNumberPlayer4 == 2 then
        spawner4 = _G.spawners[1]
        spawnersNames4 = _G.spawnersNames[1]
    elseif teamNumberPlayer4 == 3 then
        spawner4 = _G.spawners[4]
        spawnersNames4 = _G.spawnersNames[4]
    elseif teamNumberPlayer4 == 6 then
        spawner4 = _G.spawners[2]
        spawnersNames4 = _G.spawnersNames[2]
    elseif teamNumberPlayer4 == 7 then
        spawner4 = _G.spawners[3]
        spawnersNames4 = _G.spawnersNames[3]
    end
    
    count1 = _G.allcreeps[_G.round].count
    count2 = _G.allcreeps[_G.round].count
    count3 = _G.allcreeps[_G.round].count
    count4 = _G.allcreeps[_G.round].count
    
    _G.CreepCounter[teamNumberPlayer1] = count1
    _G.CreepCounter[teamNumberPlayer2] = count2
    _G.CreepCounter[teamNumberPlayer3] = count3
    _G.CreepCounter[teamNumberPlayer4] = count4

    Timers:CreateTimer(0.5 , function ()
        if count1 == _G.allcreeps[_G.round].count then
            CustomGameEventManager:Send_ServerToTeam(teamNumberPlayer1, "UpdateCreepCount", {count = count1})
        end
        if count2 == _G.allcreeps[_G.round].count then
            CustomGameEventManager:Send_ServerToTeam(teamNumberPlayer2, "UpdateCreepCount", {count = count2})
        end
        if count3 == _G.allcreeps[_G.round].count then
            CustomGameEventManager:Send_ServerToTeam(teamNumberPlayer3, "UpdateCreepCount", {count = count3})
        end
        if count4 == _G.allcreeps[_G.round].count then
            CustomGameEventManager:Send_ServerToTeam(teamNumberPlayer4, "UpdateCreepCount", {count = count4})
        end
        count1 = count1 - 1
        count2 = count2 - 1
        count3 = count3 - 1
        count4 = count4 - 1
        

        local unit1 = CreateUnitByName(_G.allcreeps[_G.round].name, spawner1:GetAbsOrigin(), true, nil,nil, 4) 
        unit1.teamnumber = teamNumberPlayer1

        unit1:AddNewModifier(unit1, nil, "modifier_nocollision", {})
        unit1.unitname =  _G.allcreeps[_G.round].name
        unit1:SetInitialWaypoint(spawnersNames1)

        local unit2 = CreateUnitByName(_G.allcreeps[_G.round].name, spawner2:GetAbsOrigin(), true, nil,nil, 4) 
        unit2.teamnumber = teamNumberPlayer2
        unit2:AddNewModifier(unit2, nil, "modifier_nocollision", {})
        unit2.unitname =  _G.allcreeps[_G.round].name
        unit2:SetInitialWaypoint(spawnersNames2)

        local unit3 = CreateUnitByName(_G.allcreeps[_G.round].name, spawner3:GetAbsOrigin(), true, nil,nil, 4) 
        unit3.teamnumber = teamNumberPlayer3
        unit3:AddNewModifier(unit3, nil, "modifier_nocollision", {})
        unit3.unitname =  _G.allcreeps[_G.round].name
        unit3:SetInitialWaypoint(spawnersNames3)

        local unit4 = CreateUnitByName(_G.allcreeps[_G.round].name, spawner4:GetAbsOrigin(), true, nil,nil, 4) 
        unit4.teamnumber = teamNumberPlayer4
        unit4:AddNewModifier(unit4, nil, "modifier_nocollision", {})
        unit4.unitname =  _G.allcreeps[_G.round].name
        unit4:SetInitialWaypoint(spawnersNames4)

        if count1 == 0 then
            return 
        end
        
        return 1
    end)
end

function WaveClass:NextWave()
    _G.round = _G.round + 1
    WaveClass:StartRound()
    
end
