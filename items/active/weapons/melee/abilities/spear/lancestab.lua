require "/items/active/weapons/melee/meleeslash.lua"
require("/scripts/FRHelper.lua")

SpearStab = MeleeSlash:new()

function SpearStab:init()
	MeleeSlash.init(self)
	self.holdDamageConfig = sb.jsonMerge(self.damageConfig, self.holdDamageConfig)
    velocityAdded = mcontroller.xVelocity()    
    self.holdDamageConfig.baseDamage = self.damageConfig.baseDamage / 2
    self.holdDamageConfig.baseDamage = self.holdDamageMultiplier * self.damageConfig.baseDamage   
end

function SpearStab:fire()
	MeleeSlash.fire(self)

	if self.fireMode == "primary" and self.allowHold ~= false then
        self:setState(self.hold)
        if self.blockCount == nil then
            self.blockCount = 5
        end
        if self.blockCount2 == nil then
            self.blockCount2 = 0
        end
        if self.blockCount3 == nil then
            self.blockCount3 = 0
        end

        if status.isResource("food") then
            self.foodValue = status.resource("food")
        else
            self.foodValue = 60
        end

        setupHelper(self, "spearstab-fire")
        if self.helper then
            self.helper:runScripts("spearstab-fire", self)
        end
    end
end

function SpearStab:hold()
	self.weapon:setStance(self.stances.hold)
	self.weapon:updateAim()
	while self.fireMode == "primary" do
        velocityAdded = mcontroller.xVelocity() 
        if velocityAdded > 0 or velocityAdded < 0 then
            self.holdDamageConfig.baseDamage = self.damageConfig.baseDamage / 2
            self.holdDamageConfig.knockback =  28   -- stable knockback so a charge can do some real damage
        else
            self.holdDamageConfig.baseDamage = self.holdDamageMultiplier * self.damageConfig.baseDamage
        end  

        local damageArea = partDamageArea("blade")
        self.weapon:setDamage(self.holdDamageConfig, damageArea)
        coroutine.yield()
	end

	self.cooldownTimer = self:cooldownTime()
end

function SpearStab:uninit()
	if self.helper then
        self.helper:clearPersistent()
    end
	self.blockCount = 0
end
