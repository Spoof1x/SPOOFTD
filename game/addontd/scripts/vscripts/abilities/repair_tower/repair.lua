LinkLuaModifier("modifier_repair", "abilities/repair_tower/repair", LUA_MODIFIER_MOTION_NONE)
repair = class({})


function repair:GetIntrinsicModifierName()
    return "modifier_repair" 
end



modifier_repair = {
    IsHidden = function (self) return true end, 
    IsPurgable = function (self) return false end, 
    IsDebuff = function (self) return false end, 
    IsBuff= function (self) return true end, 
    RemoveOnDeath = function (self) return false end, 
}


function modifier_repair:OnCreated(keys) 
    
    if not IsServer() then return end
   
    self.ability = self:GetAbility() 
   
    self:StartIntervalThink(0.2)  
end 


function modifier_repair:OnIntervalThink() 
    if not self.ability then return end 
    if self.ability:IsCooldownReady() then 
        if self:GetCaster() then
            if not  self:GetCaster():HasModifier("modifier_build") then
                local caster = self:GetCaster()
                local radius = self.ability:GetSpecialValueFor("radius")
                local healPerSecond =  self.ability:GetSpecialValueFor("healPerSecond")
                local FriendlyUnits = FindUnitsInRadius(caster:GetTeamNumber(),  caster:GetAbsOrigin(), nil,radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_CREEP  , 0,0,false )
                
                if #FriendlyUnits > 0 then
                    
                    for _, unit in pairs(FriendlyUnits) do
                        if unit ~= caster then
                            if unit:GetHealth() ~= unit:GetMaxHealth() then
                                if not unit:HasModifier("modifier_build") then
                                    unit:Heal(healPerSecond , self.ability)
                                    self.ability:StartCooldown(self.ability:GetSpecialValueFor("AbilityCooldown"))
                                end
                            end
                        end
                    end
                end
            end
            
        end
    end 
end 