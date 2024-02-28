
function UpgradeBuilding2(building, newName)
    local oldBuildingName = building:GetUnitName()
    local newName = newName
    if not newName then
        local upgradeName = BuildingHelper.UnitKV[oldBuildingName]["Upgrade"]
        newName = upgradeName
    end
    local gold_cost = BuildingHelper.UnitKV[newName]["sell"]
    BuildingHelper:print("Upgrading Building: "..oldBuildingName.." -> "..newName)
    local playerID = building:GetPlayerOwnerID()
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local position = building:GetAbsOrigin()
    local model_offset = BuildingHelper.UnitKV[newName]["ModelOffset"] or 0
    local old_offset = BuildingHelper.UnitKV[oldBuildingName]["ModelOffset"] or 0
    position.z = position.z + model_offset - old_offset
    
    local newBuilding = CreateUnitByName(newName, position, false, nil, nil, building:GetTeamNumber()) 
    newBuilding:SetOwner(hero)
    newBuilding:SetControllableByPlayer(playerID, true)
    newBuilding:SetNeverMoveToClearSpace(true)
    newBuilding:SetAbsOrigin(position)
    newBuilding.state = "building"
    newBuilding.upgradedFrom = building:GetUnitName()
    local build_time = BuildingHelper.UnitKV[newName]["BuildTime"]
    -- Выдача модификаторов на строительство заменена на отключение абилок
    -- newBuilding:AddNewModifier(building, nil, "modifier_building", {})
    -- newBuilding:AddNewModifier(building, nil, "modifier_build", {})


    -- Kill the old building
    building:AddEffects(EF_NODRAW) --Hide it, so that it's still accessible after this script
    building.upgraded = true --Skips visual effects
    UTIL_Remove(building)

    -- Block the grid
    newBuilding.construction_size = BuildingHelper:GetConstructionSize(newName)
    newBuilding.blockers = BuildingHelper:BlockGridSquares(newBuilding.construction_size, BuildingHelper:GetBlockPathingSize(newName), position)

    if not newBuilding:HasAbility("ability_building") then
        newBuilding:AddAbility("ability_building")
    end
    newBuilding.gold_cost = gold_cost
    return newBuilding
end












function CancelConstruction(event)
    local ability = event.ability
    local tower = event.caster
    local hero = tower:GetOwner()
    local playerID = hero:GetPlayerID()
    local goldCost = BuildingHelper.UnitKV[tower:GetUnitName()]["GoldCost"]
    if tower.upgradedFrom then
        local newTower = UpgradeBuilding2(tower, tower.upgradedFrom)
        newTower:AddNewModifier(newTower, nil, "modifier_no_health_bar", {})
    else
        -- Sounds:EmitSoundOnClient(playerID, "Gold.CoinsBig") 
        local coins = ParticleManager:CreateParticle("particles/econ/items/alchemist/alchemist_midas_knuckles/alch_knuckles_lasthit_coins.vpcf", PATTACH_CUSTOMORIGIN, tower)
        ParticleManager:SetParticleControl(coins, 1, tower:GetAbsOrigin())
        tower:Kill(nil, tower)
    end
    hero:ModifyGold(goldCost, true, 0)
    -- playerData.towers[tower:entindex()] = nil -- remove this tower index from the player's tower list
end