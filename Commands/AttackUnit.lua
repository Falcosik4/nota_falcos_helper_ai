function getInfo()
	return {
		tooltip = "Makes a unit attack another unit",
		parameterDefs = {
			{ 
				name = "attacker",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "nil",
			},
			{ 
				name = "target",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "nil",
			},
		}
	}
end

function Run(self, units, parameter)

    local target = parameter.target -- ID
    local attacker = parameter.attacker -- ID
    if self.isAttacking == nil or self.isAttacking == false then
        -- pick the spring command implementing the attack
        local cmdID = CMD.ATTACK

        Spring.GiveOrderToUnit(attacker, cmdID, { target }, { "shift" }) 

        self.isAttacking = true
    end

    if not Spring.ValidUnitID(attacker) then
        return FAILURE
    end

    if not Spring.ValidUnitID(target) then
        return SUCCESS
    end

    return RUNNING    
end 

function Reset(self)
    self.isAttacking = false
    return self
end