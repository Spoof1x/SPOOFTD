modifier_build = class({})

function modifier_build:IsPurgable() return false end
function modifier_build:IsHidden() return true end

function modifier_build:CheckState() 
    local state = {
        -- [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        

    }
    return state
end
