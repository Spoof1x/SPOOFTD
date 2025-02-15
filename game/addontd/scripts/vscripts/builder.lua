LinkLuaModifier("modifier_building", "libraries/modifiers/modifier_building", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_build", "libraries/modifiers/modifier_build", LUA_MODIFIER_MOTION_NONE)
function Build( event )
    local caster = event.caster
    local ability = event.ability
    local ability_name = ability:GetAbilityName()
    local building_name = ability:GetAbilityKeyValues()['UnitName']
    local gold_cost = BuildingHelper.UnitKV[building_name]["sell"]
    local hero = caster:IsRealHero() and caster or caster:GetOwner()
    local playerID = hero:GetPlayerID()
    hero:ModifyGold(BuildingHelper.AbilityKV[ability_name]["AbilityGoldCost"], false, 0)
    
 

    
    -- If the ability has an AbilityGoldCost, it's impossible to not have enough gold the first time it's cast
    -- Always refund the gold here, as the building hasn't been placed yet
    

    -- Makes a building dummy and starts panorama ghosting
    BuildingHelper:AddBuilding(event) 

    -- Additional checks to confirm a valid building position can be performed here
    event:OnPreConstruction(function(vPos)

        -- Check for minimum height if defined
        if not BuildingHelper:MeetsHeightCondition(vPos) then
            BuildingHelper:print("Failed placement of " .. building_name .." - Placement is below the min height required")
            SendErrorMessage(playerID, "#error_invalid_build_position")
            return false
        end
 
        -- If not enough resources to queue, stop
        if PlayerResource:GetGold(playerID) < gold_cost then
            BuildingHelper:print("Failed placement of " .. building_name .." - Not enough gold!")
            SendErrorMessage(playerID, "#error_not_enough_gold")
            return false
        end
        
        return true
    end)

    event:OnBuildingPosChosen(function(vPos)
        
        

        
    end)

    -- The construction failed and was never confirmed due to the gridnav being blocked in the attempted area
    event:OnConstructionFailed(function()
        local playerTable = BuildingHelper:GetPlayerTable(playerID)
        local building_name = playerTable.activeBuilding
        BuildingHelper:print("Failed placement of " .. building_name)
    end)

    -- Cancelled due to ClearQueue
    event:OnConstructionCancelled(function(work)
        
        local name = work.name
        BuildingHelper:print("Cancelled construction of " .. name)
        
        
        
        
    end)

    -- A building unit was created
    event:OnConstructionStarted(function(unit)
        BuildingHelper:print("Started construction of " .. unit:GetUnitName() .. " " .. unit:GetEntityIndex())
        -- Play construction sound
        hero:ModifyGold(-BuildingHelper.AbilityKV[ability_name]["AbilityGoldCost"], false, 0)
        -- If it's an item-ability and has charges, remove a charge or remove the item if no charges left
        if ability.GetCurrentCharges and not ability:IsPermanent() then
            local charges = ability:GetCurrentCharges()
            charges = charges-1
            if charges == 0 then
                ability:RemoveSelf()
            else
                ability:SetCurrentCharges(charges)
            end
        end

        unit.particle = ParticleManager:CreateParticle( "particles/items5_fx/repair_kit.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit );
        ParticleManager:SetParticleControlEnt( unit.particle, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true )
        ParticleManager:SetParticleControlEnt( unit.particle, 1, unit, PATTACH_ABSORIGIN_FOLLOW, nil, unit:GetAbsOrigin(), true  )
        EmitSoundOn( "DOTA_Item.RepairKit.Target", unit )
        -- Units can't attack while building
        unit.original_attack = unit:GetAttackCapability()
        unit:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
        -- unit:AddNewModifier(unit, nil, "modifier_building", {})
        -- unit:RemoveAbility("destroyer")
        -- local abil = unit:AddAbility("cancel_construction")
        -- abil:SetLevel(1)
         for i = 0, unit:GetAbilityCount() - 1 do
             local abilityunit = unit:GetAbilityByIndex(i)
             if abilityunit then
                 abilityunit:SetActivated(false)
            end
         end

       
        unit.gold_cost = gold_cost
        

        -- FindClearSpace for the builder
        FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
        caster:AddNewModifier(caster, nil, "modifier_phased", {duration=0.03})
        unit:AddNewModifier(caster, nil, "modifier_build", {})
        unit:RemoveModifierByName("modifier_invulnerable")
        _G.lua.towers[unit:GetPlayerOwnerID()] = _G.lua.towers[unit:GetPlayerOwnerID()] + 1
        CustomGameEventManager:Send_ServerToTeam(unit:GetTeamNumber(), "update_CountTowers", {
			count  = _G.lua.towers, 
		})
    end)
    -- A building finished construction
    event:OnConstructionCompleted(function(unit)
        BuildingHelper:print("Completed construction of " .. unit:GetUnitName() .. " " .. unit:GetEntityIndex())
        ParticleManager:DestroyParticle(unit.particle, false)
        -- Remove the item
        if unit.item_building_cancel then
            UTIL_Remove(unit.item_building_cancel)
        end
        -- unit:RemoveAbility("cancel_construction")
        -- local abil = unit:AddAbility("destroyer")
        -- abil:SetLevel(1)
        for i = 0, unit:GetAbilityCount() - 1 do
            local abilityunit = unit:GetAbilityByIndex(i)
            if abilityunit  then
                abilityunit:SetActivated(true)
            end
        end
        -- Give the unit their original attack capability
        unit:SetAttackCapability(unit.original_attack)
        unit:RemoveModifierByName("modifier_build")
        if PlayerResource:IsUnitSelected(playerID, unit) then
            PlayerResource:AddToSelection(playerID, unit)
            PlayerResource:RefreshSelection()
        end
    end)
    -- These callbacks will only fire when the state between below half health/above half health changes.
    -- i.e. it won't fire multiple times unnecessarily.
    event:OnBelowHalfHealth(function(unit)
        BuildingHelper:print(unit:GetUnitName() .. " is below half health.")
    end)
    event:OnAboveHalfHealth(function(unit)
        BuildingHelper:print(unit:GetUnitName().. " is above half health.")        
    end)
end
-- Called when the Cancel ability-item is used
function CancelBuilding( keys )
    local building = keys.unit
    local hero = building:GetOwner()
    local playerID = building:GetPlayerOwnerID()
    local construction_size = building.construction_size
    local location = {x = building:GetAbsOrigin().x, y = building:GetAbsOrigin().y}
    BuildingHelper:print("CancelBuilding "..building:GetUnitName().." "..building:GetEntityIndex())
    BuildingHelper:RemoveGridType(construction_size, location, "BLOCKED")
    BuildingHelper:AddGridType(construction_size, location, "BUILDABLE")
    -- Refund here
    if building.gold_cost then
        hero:ModifyGold(building.gold_cost, false, 0)
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, hero, building.gold_cost, nil)
    end
    -- Eject builder
    local builder = building.builder_inside
    if builder then
        BuildingHelper:ShowBuilder(builder)
    end
    UTIL_Remove(building)--This will call RemoveBuilding
    _G.lua.towers[playerID] = _G.lua.towers[playerID] - 1
        CustomGameEventManager:Send_ServerToTeam(hero:GetTeamNumber(), "update_CountTowers", {
		count  = _G.lua.towers, 
	})
end
                      
-- Requires notifications library from bmddota/barebones
function SendErrorMessage( pID, string )
    Notifications:ClearBottom(pID)
    Notifications:Bottom(pID, {text=string, style={color='#E62020'}, duration=2})
    EmitSoundOnClient("General.Cancel", PlayerResource:GetPlayer(pID))
end
