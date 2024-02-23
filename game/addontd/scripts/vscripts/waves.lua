LinkLuaModifier("modifier_nocollision","libraries/modifiers/modifier_nocollision",LUA_MODIFIER_MOTION_NONE)
_G.spawners = {
   "path10",
   "path50",
   "path150",
   "path100",

}
_G.allcrips = {
    
    {
        name = "npc_dota_neutral_kobold",
        count = 15,
    },
    {
        name = "",
        count = 15,
    }
}

if WaveClass == nil then WaveClass = {} end



function WaveClass:Init()
    WaveClass:StartGameTimer()

    
    

    
end

function WaveClass:StartGameTimer()
    local secunds = 5
    Timers:CreateTimer(0.01, function ()
        if secunds == 0 then 
            CustomGameEventManager:Send_ServerToAllClients("CloseStartGameTimer", {})
            WaveClass:StartGame()
        end
        CustomGameEventManager:Send_ServerToAllClients("UpdateStartGameTimer", {sec = secunds})
        secunds = secunds - 1
        return 1
    end)
end




function WaveClass:StartGame()
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
        WaveClass:SpawnAllCrips()
    end

end



function WaveClass:StartWaveSolo()
    
    for i=1 ,4 do
        _G.spawners[i] = Entities:FindByName(nil, _G.spawners[i])
    end
    local teamNumber = _G.Players[0]:GetTeamNumber()
    local spawner
    
    if teamNumber == 2 then
        spawner = _G.spawners[1]
    elseif teamNumber == 3 then
        spawner = _G.spawners[4]
    elseif teamNumber == 6 then
        spawner = _G.spawners[2]
    elseif teamNumber == 7 then
        spawner = _G.spawners[3]
    end
    
    
    Timers:CreateTimer(0.5 , function ()
        _G.allcrips[_G.round].count = _G.allcrips[_G.round].count - 1
        local unit = CreateUnitByName(_G.allcrips[_G.round].name, spawner:GetAbsOrigin(), true, nil,nil, 4) 
        unit:AddNewModifier(unit, nil, "modifier_nocollision", {})
        unit.unitname =  _G.allcrips[_G.round].name
        unit:SetInitialGoalEntity(spawner)
        if _G.allcrips[_G.round].count == 0 then
            return 
        end
        return 1
    end)
        
    
    
	
   
   
end
function WaveClass:StartWaveDuo()
    for i=1,4 do
        _G.spawners[i] = Entities:FindByName(nil, _G.spawners[i])
    end
    local teamNumberPlayer1, teamNumberPlayer2 = _G.Players[0]:GetTeamNumber() , _G.Players[1]:GetTeamNumber()
    
    local spawner1 
    local spawner2
    if teamNumberPlayer1 == 2 then
        spawner1 = _G.spawners[1]
    elseif teamNumberPlayer1 == 3 then
        spawner1 = _G.spawners[4]
    elseif teamNumberPlayer1 == 6 then
        spawner1 = _G.spawners[2]
    elseif teamNumberPlayer1 == 7 then
        spawner1 = _G.spawners[3]
    end

    if teamNumberPlayer2 == 2 then
        spawner2 = _G.spawners[1]
    elseif teamNumberPlayer2 == 3 then
        spawner2 = _G.spawners[4]
    elseif teamNumberPlayer2 == 6 then
        spawner2 = _G.spawners[2]
    elseif teamNumberPlayer2 == 7 then
        spawner2 = _G.spawners[3]
    end
    
    count1 = _G.allcrips[_G.round].count
    
    Timers:CreateTimer(0.5 , function ()
       
        count1 = count1 - 1
        local unit1 = CreateUnitByName(_G.allcrips[_G.round].name, spawner1:GetAbsOrigin(), true, nil,nil, 4)
        unit1:AddNewModifier(unit1, nil, "modifier_nocollision", {})
        unit1.unitname =  _G.allcrips[_G.round].name
        unit1:SetInitialGoalEntity(spawner1)

        local unit2 = CreateUnitByName(_G.allcrips[_G.round].name, spawner2:GetAbsOrigin(), true, nil,nil, 4) 
        unit2:AddNewModifier(unit2, nil, "modifier_nocollision", {})
        unit2.unitname =  _G.allcrips[_G.round].name
        unit2:SetInitialGoalEntity(spawner2)

        if count1 == 0 then
            return 
        end
        
        return 1
    end)
end

function WaveClass:StartWaveTrio()
    for i=1,4 do
        _G.spawners[i] = Entities:FindByName(nil, _G.spawners[i])
    end
    local teamNumberPlayer1, teamNumberPlayer2, teamNumberPlayer3 = _G.Players[0]:GetTeamNumber() , _G.Players[1]:GetTeamNumber() , _G.Players[2]:GetTeamNumber() 
    
    local spawner1 
    local spawner2
    local spawner3
    if teamNumberPlayer1 == 2 then
        spawner1 = _G.spawners[1]
    elseif teamNumberPlayer1 == 3 then
        spawner1 = _G.spawners[4]
    elseif teamNumberPlayer1 == 6 then
        spawner1 = _G.spawners[2]
    elseif teamNumberPlayer1 == 7 then
        spawner1 = _G.spawners[3]
    end

    if teamNumberPlayer2 == 2 then
        spawner2 = _G.spawners[1]
    elseif teamNumberPlayer2 == 3 then
        spawner2 = _G.spawners[4]
    elseif teamNumberPlayer2 == 6 then
        spawner2 = _G.spawners[2]
    elseif teamNumberPlayer2 == 7 then
        spawner2 = _G.spawners[3]
    end
    if teamNumberPlayer3 == 2 then
        spawner3 = _G.spawners[1]
    elseif teamNumberPlayer3 == 3 then
        spawner3 = _G.spawners[4]
    elseif teamNumberPlayer3 == 6 then
        spawner3 = _G.spawners[2]
    elseif teamNumberPlayer3 == 7 then
        spawner3 = _G.spawners[3]
    end
    
    
    count1 = _G.allcrips[_G.round].count
    
    Timers:CreateTimer(0.5 , function ()
       
        count1 = count1 - 1

        local unit1 = CreateUnitByName(_G.allcrips[_G.round].name, spawner1:GetAbsOrigin(), true, nil,nil, 4) 
        unit1:AddNewModifier(unit1, nil, "modifier_nocollision", {})
        unit1.unitname =  _G.allcrips[_G.round].name
        unit1:SetInitialGoalEntity(spawner1)

        local unit2 = CreateUnitByName(_G.allcrips[_G.round].name, spawner2:GetAbsOrigin(), true, nil,nil, 4) 
        unit2:AddNewModifier(unit2, nil, "modifier_nocollision", {})
        unit2.unitname =  _G.allcrips[_G.round].name
        unit2:SetInitialGoalEntity(spawner2)

        local unit3 = CreateUnitByName(_G.allcrips[_G.round].name, spawner3:GetAbsOrigin(), true, nil,nil, 4) 
        unit3:AddNewModifier(unit3, nil, "modifier_nocollision", {})
        unit3.unitname =  _G.allcrips[_G.round].name
        unit3:SetInitialGoalEntity(spawner3)

        if count1 == 0 then
            return 
        end
        
        return 1
    end)
end



function WaveClass:SpawnAllCrips()
    for i=1,4 do
        _G.spawners[i] = Entities:FindByName(nil, _G.spawners[i])
    end
    local teamNumberPlayer1, teamNumberPlayer2, teamNumberPlayer3, teamNumberPlayer4 = _G.Players[0]:GetTeamNumber() , _G.Players[1]:GetTeamNumber() , _G.Players[2]:GetTeamNumber() , _G.Players[3]:GetTeamNumber() 
    
    local spawner1 
    local spawner2
    local spawner3
    local spawner4
    if teamNumberPlayer1 == 2 then
        spawner1 = _G.spawners[1]
    elseif teamNumberPlayer1 == 3 then
        spawner1 = _G.spawners[4]
    elseif teamNumberPlayer1 == 6 then
        spawner1 = _G.spawners[2]
    elseif teamNumberPlayer1 == 7 then
        spawner1 = _G.spawners[3]
    end

    if teamNumberPlayer2 == 2 then
        spawner2 = _G.spawners[1]
    elseif teamNumberPlayer2 == 3 then
        spawner2 = _G.spawners[4]
    elseif teamNumberPlayer2 == 6 then
        spawner2 = _G.spawners[2]
    elseif teamNumberPlayer2 == 7 then
        spawner2 = _G.spawners[3]
    end

    if teamNumberPlayer3 == 2 then
        spawner3 = _G.spawners[1]
    elseif teamNumberPlayer3 == 3 then
        spawner3 = _G.spawners[4]
    elseif teamNumberPlayer3 == 6 then
        spawner3 = _G.spawners[2]
    elseif teamNumberPlayer3 == 7 then
        spawner3 = _G.spawners[3]
    end

    if teamNumberPlayer4 == 2 then
        spawner4 = _G.spawners[1]
    elseif teamNumberPlayer4 == 3 then
        spawner4 = _G.spawners[4]
    elseif teamNumberPlayer4 == 6 then
        spawner4 = _G.spawners[2]
    elseif teamNumberPlayer4 == 7 then
        spawner4 = _G.spawners[3]
    end
    
    
    count1 = _G.allcrips[_G.round].count
    
    Timers:CreateTimer(0.5 , function ()
       
        count1 = count1 - 1

        local unit1 = CreateUnitByName(_G.allcrips[_G.round].name, spawner1:GetAbsOrigin(), true, nil,nil, 4) 
        unit1:AddNewModifier(unit1, nil, "modifier_nocollision", {})
        unit1.unitname =  _G.allcrips[_G.round].name
        unit1:SetInitialGoalEntity(spawner1)

        local unit2 = CreateUnitByName(_G.allcrips[_G.round].name, spawner2:GetAbsOrigin(), true, nil,nil, 4) 
        unit2:AddNewModifier(unit2, nil, "modifier_nocollision", {})
        unit2.unitname =  _G.allcrips[_G.round].name
        unit2:SetInitialGoalEntity(spawner2)

        local unit3 = CreateUnitByName(_G.allcrips[_G.round].name, spawner3:GetAbsOrigin(), true, nil,nil, 4) 
        unit3:AddNewModifier(unit3, nil, "modifier_nocollision", {})
        unit3.unitname =  _G.allcrips[_G.round].name
        unit3:SetInitialGoalEntity(spawner3)

        local unit4 = CreateUnitByName(_G.allcrips[_G.round].name, spawner4:GetAbsOrigin(), true, nil,nil, 4) 
        unit4:AddNewModifier(unit4, nil, "modifier_nocollision", {})
        unit4.unitname =  _G.allcrips[_G.round].name
        unit4:SetInitialGoalEntity(spawner4)

        if count1 == 0 then
            return 
        end
        
        return 1
    end)
end