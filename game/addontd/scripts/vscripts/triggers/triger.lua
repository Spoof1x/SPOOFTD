function triger_good(event)
    local creep = event.activator

    if event.activator:IsRealHero() then return end

    creep:Kill(nil,creep)

    local unitName = event.activator.unitname

    local dmg = BuildingHelper.UnitKV[unitName]["damage"]

    local playerCount = PlayerResource:GetPlayerCount()
    for i = 0, playerCount - 1 do
        local player = PlayerResource:GetPlayer(i)
        if player and player:GetTeamNumber() == 2 then
            _G.lua.incomes[i] = false
            CustomGameEventManager:Send_ServerToTeam(player:GetTeamNumber(), "LockIncome", {})
            local hero = player:GetAssignedHero()
            if hero then
                local currentHealth = hero:GetHealth()
                if currentHealth - dmg <= 0 then
                    -- hero:Kill(nil,creep)
                else
                    hero:SetHealth(currentHealth - dmg)
                end
                
            end
        end
    end
end

function triger_bad(event)
    local creep = event.activator

    if event.activator:IsRealHero() then return end

    creep:Kill(nil,creep)

    local unitName = event.activator.unitname

    local dmg = BuildingHelper.UnitKV[unitName]["damage"]

    local playerCount = PlayerResource:GetPlayerCount()
    for i = 0, playerCount - 1 do
        local player = PlayerResource:GetPlayer(i)
        if player and player:GetTeamNumber() == 3 then
            
            _G.lua.incomes[i] = false
            CustomGameEventManager:Send_ServerToTeam(player:GetTeamNumber(), "LockIncome", {})
            local hero = player:GetAssignedHero()
            if hero then
                local currentHealth = hero:GetHealth()
                if currentHealth > dmg then
                    hero:SetHealth(currentHealth - dmg)
                else
                    -- Герой умирает, делайте необходимые действия, если это нужно
                end
            end
        end
    end
end
function triger_custom1(event)
    local creep = event.activator

    if event.activator:IsRealHero() then return end

    creep:Kill(nil,creep)

    local unitName = event.activator.unitname

    local dmg = BuildingHelper.UnitKV[unitName]["damage"]

    local playerCount = PlayerResource:GetPlayerCount()
    for i = 0, playerCount - 1 do
        local player = PlayerResource:GetPlayer(i)
        if player and player:GetTeamNumber() == 6 then
            _G.lua.incomes[i] = false
            CustomGameEventManager:Send_ServerToTeam(player:GetTeamNumber(), "LockIncome", {})
            local hero = player:GetAssignedHero()
            if hero then
                local currentHealth = hero:GetHealth()
                if currentHealth > dmg then
                    hero:SetHealth(currentHealth - dmg)
                else
                    -- Герой умирает, делайте необходимые действия, если это нужно
                end
            end
        end
    end
end
function triger_custom2(event)
    local creep = event.activator

    if event.activator:IsRealHero() then return end

    creep:Kill(nil,creep)

    local unitName = event.activator.unitname

    local dmg = BuildingHelper.UnitKV[unitName]["damage"]

    local playerCount = PlayerResource:GetPlayerCount()
    for i = 0, playerCount - 1 do
        local player = PlayerResource:GetPlayer(i)
        
        if player and player:GetTeamNumber() == 7 then
            _G.lua.incomes[i] = false
            CustomGameEventManager:Send_ServerToTeam(player:GetTeamNumber(), "LockIncome", {})
            local hero = player:GetAssignedHero()
            if hero then
                local currentHealth = hero:GetHealth()
                if currentHealth > dmg then
                    hero:SetHealth(currentHealth - dmg)
                else
                    -- Герой умирает, делайте необходимые действия, если это нужно
                end
            end
        end
    end
end

 