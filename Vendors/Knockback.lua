local KnockbackHandler = {}

function KnockbackHandler.addEffect(
	Entity: Model,
	KBforce: number,
	removeTime: number
)
	-- Entity model knockback
	if Entity.PrimaryPart.Anchored then return end

	local hmrpt = Entity:FindFirstChild("HumanoidRootPart")
	if not hmrpt then return end
    
	local backDirection = Entity
end

return KnockbackHandler
