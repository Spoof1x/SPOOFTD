modifier_nocollision = {}



function modifier_nocollision:IsPurgable() return false end
function modifier_nocollision:IsHidden() return true end

function modifier_nocollision:CheckState() 
    local state = {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
    return state
end