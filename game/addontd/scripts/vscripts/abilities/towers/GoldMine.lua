LinkLuaModifier("modifier_GoldMine", "abilities/towers/GoldMine", LUA_MODIFIER_MOTION_NONE)

GoldMine = {}

function GoldMine:GetIntrinsicModifierName()
    return "modifier_GoldMine" 
end


modifier_GoldMine = class({ 
    IsHidden = function (self) return true end, 
    IsPurgable = function (self) return false end, 
    IsDebuff = function (self) return false end, 
    IsBuff= function (self) return true end, 
    RemoveOnDeath = function (self) return false end, 

})

function modifier_GoldMine:OnCreated(keys) 
    
    if not IsServer() then return end
   
    self.ability = self:GetAbility() 
   
    self:StartIntervalThink(0.2)  
end 

function modifier_GoldMine:OnIntervalThink() 
    if not self.ability then return end 
    if self.ability:IsCooldownReady() then 
        if self:GetCaster() then
            if self:GetCaster():HasModifier("modifier_building") then
                return
            end
            if self:GetCaster():GetOwner() then
                local particle = "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_midas_coinshower.vpcf"
                local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
                ParticleManager:SetParticleControlEnt(effect, 1 , self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW , "attach_hitoc", self:GetCaster():GetOrigin(), true)
                self:GetCaster():EmitSound("DOTA_Item.Hand_Of_Midas")
                self.ability:StartCooldown(self.ability:GetSpecialValueFor("AbilityCooldown"))
                self:GetCaster():GetOwner():ModifyGold(self.ability:GetSpecialValueFor("GoldPerSecond"), true, 0)
            end
        end
    end 
end 
