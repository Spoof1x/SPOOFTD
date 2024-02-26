LinkLuaModifier("modifier_nocollision","libraries/modifiers/modifier_nocollision",LUA_MODIFIER_MOTION_NONE)

_G.spawners = {[2] = "path10", [3] = "path100",[6] = "path50", [7] = "path150", }
_G.spawnersNames = {[2] = "path10", [3] = "path100",[6] = "path50", [7] = "path150"}
_G.allcreeps = {
[1]  =  {name = "npc_dota_neutral_kobold", count = 15},
[2]  =  {name = "npc_dota_creep_goodguys_melee", count = 10},
[3]  =  {name = "npc_dota_creep_goodguys_melee", count = 10},
[4]  =  {name = "npc_dota_creep_goodguys_melee", count = 10},
[5]  =  {name = "npc_dota_creep_goodguys_melee", count = 10},
[6]  =  {name = "npc_dota_creep_goodguys_melee", count = 10},
[7]  =  {name = "npc_dota_creep_goodguys_melee", count = 10},
}



if WaveClass == nil then WaveClass = {} end

function WaveClass:Init()
    WaveClass:StartGameTimer()
    _G.spawners[2] = Entities:FindByName(nil, _G.spawners[2])
    _G.spawners[3] = Entities:FindByName(nil, _G.spawners[3])
    _G.spawners[6] = Entities:FindByName(nil, _G.spawners[6])
    _G.spawners[7] = Entities:FindByName(nil, _G.spawners[7])
    WaveClass.Settings = LoadKeyValues("scripts/kv/wave_settings.kv")
end

function WaveClass:StartGameTimer()
    local secunds = 10
    Timers:CreateTimer(0.01, function ()
        if secunds == 0 then 
            local countplayers = _G.Cplayers
            if countplayers == 1 then 
                _G.gamemode = "Solo"
                WaveClass:IncomeStart(WaveClass.Settings["income"])
            end
            if countplayers == 2 then 
                _G.gamemode = "Duo"
                WaveClass:IncomeStart(WaveClass.Settings["income"])
            end
            if countplayers == 3 then 
                _G.gamemode = "Trio"
                WaveClass:IncomeStart(WaveClass.Settings["income"])
            end
            if countplayers == 4 then 
                _G.gamemode = "All"
                WaveClass:IncomeStart(WaveClass.Settings["income"])
            end
            CustomGameEventManager:Send_ServerToAllClients("CloseStartGameTimer", {})
            WaveClass:StartRound()
        end
        CustomGameEventManager:Send_ServerToAllClients("UpdateStartGameTimer", {sec = secunds})
        secunds = secunds - 1
        return 1
    end)
end




function WaveClass:StartRound()
    
    -- CustomGameEventManager:Send_ServerToAllClients("update_round", {
    --     round = _G.round, 
    -- })
    -- CustomGameEventManager:Send_ServerToAllClients("update_CreepName", {
    --     name  = _G.allcreeps[_G.round[]].name, 
    -- })
    -- CustomGameEventManager:Send_ServerToAllClients("update_CreepCounts", {
    --     count  = _G.allcreeps[_G.round].count, 
    --     maxcount = _G.allcreeps[_G.round].count
    -- })
    local countplayers = _G.Cplayers
    if _G.gamemode == "Solo" then 
        WaveClass:StartWave(0)
    end
    if _G.gamemode == "Duo" then 

        WaveClass:StartWave(0)
        WaveClass:StartWave(1)
    end
    if _G.gamemode == "Trio" then 
        WaveClass:StartWave(0)
        WaveClass:StartWave(1)
        WaveClass:StartWave(2)
        
    end
    if _G.gamemode == "All" then 
        WaveClass:StartWave(0)
        WaveClass:StartWave(1)
        WaveClass:StartWave(2)
        WaveClass:StartWave(3)
    end

end

function WaveClass:StartWave(playerid)
    if not _G.allcreeps[_G.round[playerid]]  then
        print("NEXT ROUND WAS NOT BE FOUND")
        return
    end
    print("Playerid  ".. playerid .. "  ROUND ".. _G.round[playerid])
    local team = _G.Players[playerid]:GetTeamNumber()
    if _G.AliveTeams[team] then
        local spawner =  GetSpawnerAndSpawnerName(team).spawner
        local spawnerNames = GetSpawnerAndSpawnerName(team).spawnerName
        local count = _G.allcreeps[_G.round[playerid]].count

        CustomGameEventManager:Send_ServerToTeam(team,"update_round", {
        round = _G.round[playerid], 
        team = team
        })
        CustomGameEventManager:Send_ServerToTeam(team,"update_CreepName", {
        name  = _G.allcreeps[_G.round[playerid]].name, 
        team = team
        })
        CustomGameEventManager:Send_ServerToTeam(team,"update_CreepCounts", {
        count  = _G.allcreeps[_G.round[playerid]].count, 
        maxcount = _G.allcreeps[_G.round[playerid]].count,
        team = team
        })



        _G.CreepCounter[team] = count

        Timers:CreateTimer(0.5 , function ()
            count = count - 1
            local unit = CreatUnit(_G.allcreeps[_G.round[playerid]].name,spawner:GetAbsOrigin(),team, _G.allcreeps[_G.round[playerid]].name, spawnerNames, playerid)
            if count == 0 then
                return 
            end
            return 1
        end)
    end
end


function WaveClass:NextWave()
    _G.round = _G.round + 1
    WaveClass:StartRound() 
end

function CreatUnit(name, spawner, teamnumber, unitname, spawnerName, id )
    local unit = CreateUnitByName(name, spawner, true, nil,nil, 4)
    unit.teamnumber = teamnumber
    unit.playerid = id
    unit:AddNewModifier(unit, nil, "modifier_nocollision", {})
    unit.unitname =  unitname
    unit:SetInitialWaypoint(spawnerName)
    table.insert(_G.playercreeps[teamnumber], unit) 
    return unit
end

_G.checkforKill = {}
function WaveClass:KillsAllCreeps(pTEAMNUMBER)
    Timers:CreateTimer(0.01,function ()
            if WaveClass:countCheck(_G.playercreeps[pTEAMNUMBER]) > 0 then
                for i, unit in pairs(_G.playercreeps[pTEAMNUMBER]) do
                    UTIL_Remove(unit)
                end
                
            end
        return 1
    end)
end































function GetSpawnerAndSpawnerName(team)
    data = {
        spawner = _G.spawners[team],
        spawnerName =  _G.spawnersNames[team]
    }
    return data
end
function WaveClass:IncomeStart(percent)
    Timers:CreateTimer(5, function ()

        for i = 0, _G.Cplayers - 1 do
            local player = _G.Players[i]    
            if player then
                
                if _G.incomes[i] then
                   
                    SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, player, percent*player:GetGold(), nil)
                    player:ModifyGold(percent*player:GetGold(), true, 0)
                end
            end
        end
        return 15
    end)
end

function WaveClass:countCheck(table)
    local count = 0
    for _, _ in pairs(table) do
        count = count + 1
    end
    return count
end