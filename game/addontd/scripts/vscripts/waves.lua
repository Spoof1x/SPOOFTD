LinkLuaModifier("modifier_nocollision","libraries/modifiers/modifier_nocollision",LUA_MODIFIER_MOTION_NONE)
if WaveClass == nil then WaveClass = {} end
function WaveClass:Init()
    WaveClass:StartGameTimer()
    WaveClass.Settings = LoadKeyValues("scripts/kv/wave_settings.kv")
end
gamemods = {[1] = "Solo", [2] = "Duo", [3] = "Trio", [4] = "All"}
function WaveClass:StartGameTimer()
    local secunds = 15
    Timers:CreateTimer(0.01, function ()
        if secunds == 0 then 
            _G.lua.gamemode = gamemods[_G.lua.Cplayers]
            CustomGameEventManager:Send_ServerToAllClients("CloseStartGameTimer", {})
            WaveClass:StartRound()
        end
        CustomGameEventManager:Send_ServerToAllClients("UpdateStartGameTimer", {sec = secunds})
        secunds = secunds - 1
        return 1
    end)
end
-- local a = "print('Hello, world!')"
-- loadstring(a)()

function WaveClass:StartRound()
    WaveClass:IncomeStart(WaveClass.Settings["income"])
    _G.lua.spawners[2] = Entities:FindByName(nil, _G.lua.spawners[2])
    _G.lua.spawners[3] = Entities:FindByName(nil, _G.lua.spawners[3])
    _G.lua.spawners[6] = Entities:FindByName(nil, _G.lua.spawners[6])
    _G.lua.spawners[7] = Entities:FindByName(nil, _G.lua.spawners[7])
    if _G.lua.gamemode == "Solo" then 
        WaveClass:StartWave(0)
    end
    if _G.lua.gamemode == "Duo" then 

        WaveClass:StartWave(0)
        WaveClass:StartWave(1)
    end
    if _G.lua.gamemode == "Trio" then 
        WaveClass:StartWave(0)
        WaveClass:StartWave(1)
        WaveClass:StartWave(2)
    end
    if _G.lua.gamemode == "All" then 
        WaveClass:StartWave(0)
        WaveClass:StartWave(1)
        WaveClass:StartWave(2)
        WaveClass:StartWave(3)
    end
end
function WaveClass:StartWave(playerid)
    if not _G.lua.allcreeps[_G.lua.round[playerid]]  then
        print("NEXT ROUND WAS NOT BE FOUND")
        return
    end
    print("Playerid  ".. playerid .. "  ROUND ".. _G.lua.round[playerid])
    local team = _G.lua.Players[playerid]:GetTeamNumber()
    if _G.lua.AliveTeams[playerid] then
        local spawner =  GetSpawnerAndSpawnerName(team).spawner
        local spawnerNames = GetSpawnerAndSpawnerName(team).spawnerName
        local count = _G.lua.allcreeps[_G.lua.round[playerid]].count
        CustomGameEventManager:Send_ServerToTeam(team,"update_round", {
        round = _G.lua.round[playerid], 
        team = team
        })
        CustomGameEventManager:Send_ServerToTeam(team,"update_CreepName", {
        name  = _G.lua.allcreeps[_G.lua.round[playerid]].name, 
        team = team
        })
        CustomGameEventManager:Send_ServerToTeam(team,"update_CreepCounts", {
        count  = _G.lua.allcreeps[_G.lua.round[playerid]].count, 
        maxcount = _G.lua.allcreeps[_G.lua.round[playerid]].count,
        team = team
        })
        _G.lua.CreepCounter[playerid] = count
        spawner_unit = CreateUnitByName("npc_dota_companion", spawner:GetAbsOrigin(), false, nil, nil, 0)
        spawner_unit:AddNewModifier(spawner_unit, nil, "modifier_phased", {})
        spawner_unit:AddNewModifier(spawner_unit, nil, "modifier_invulnerable", {})
        spawner_unit:AddNewModifier(spawner_unit, nil, "modifier_unselect", {})
        local particle = ParticleManager:CreateParticle("particles/wave_part.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl( particle, 0, spawner:GetAbsOrigin())
        Timers:CreateTimer(0.5 , function ()
            count = count - 1
            local unit = CreatUnit(_G.lua.allcreeps[_G.lua.round[playerid]].name,spawner:GetAbsOrigin(),team, _G.lua.allcreeps[_G.lua.round[playerid]].name, spawnerNames, playerid)
            if count == 0 then
                ParticleManager:DestroyParticle(particle, true)
                spawner_unit:Kill(nil,nil)
                return 
            end
            return 1
        end)
    end
end
function WaveClass:NextWave()
    _G.lua.round = _G.lua.round + 1
    WaveClass:StartRound() 
end

function CreatUnit(name, spawner, teamnumber, unitname, spawnerName, id )
    local unit = CreateUnitByName(name, spawner, true, nil,nil, 4)
    unit.teamnumber = teamnumber
    unit.playerid = id
    unit:AddNewModifier(unit, nil, "modifier_nocollision", {})
    unit.unitname =  unitname
    unit:SetInitialWaypoint(spawnerName)
    table.insert(_G.lua.playercreeps[id], unit) 
    return unit
end

function WaveClass:KillsAllCreeps(pID)
    Timers:CreateTimer(0.01,function ()
            if WaveClass:countCheck(_G.lua.playercreeps[pID]) > 0 then
                for i, unit in pairs(_G.lua.playercreeps[pID]) do
                    UTIL_Remove(unit)
                end
                
            end
        return 1
    end)
end
function GetSpawnerAndSpawnerName(pTeam)
    data = {
        spawner = _G.lua.spawners[pTeam],
        spawnerName =  _G.lua.spawnersNames[pTeam]
    }
    return data
end
function WaveClass:IncomeStart(percent)
    Timers:CreateTimer(0, function ()

        for i = 0, _G.lua.Cplayers - 1 do
            local player = _G.lua.Players[i]    
            if player then
                
                if _G.lua.incomes[i] then
                   
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

function HeroIsReadyReal(_,event)
    _G.lua.Teams[event.id] = true
    _G.lua.RealReady[event.id] = true
    _G.lua.TimeRealReady[event.id] = 6
    Timers:CreateTimer(0.00001, function ()
        if _G.lua.RealReady[event.id] then
            
            _G.lua.TimeRealReady[event.id] = _G.lua.TimeRealReady[event.id] - 1
            CustomGameEventManager:Send_ServerToTeam(_G.lua.Players[event.id]:GetTeamNumber(),"UpdateReadyTimer", {
                sec = _G.lua.TimeRealReady[event.id],
            })
            if _G.lua.TimeRealReady[event.id] == 0 then
                _G.lua.stoptimer[event.id] = false
                _G.lua.RealReady[event.id] = false
                _G.lua.timerswaves[event.id].secund = 30
	            _G.lua.timerswaves[event.id].fullsecund = 30
                _G.lua.round[event.id] = _G.lua.round[event.id] + 1
                _G.lua.incomes[event.id] = true
                WaveClass:StartWave(event.id)
                CustomGameEventManager:Send_ServerToTeam(_G.lua.Players[event.id]:GetTeamNumber(),"EndReadyTimer", {})
                
            end
            return 1

        end
    end)
end

function HeroIsReadyCancel(_,event)
    _G.lua.RealReady[event.id] = false
    _G.lua.Teams[event.id] = false
end