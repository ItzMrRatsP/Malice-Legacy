local KnockbackHandler = {}

function KnockbackHandler.CalculateMass(Model: Model)
    assert(Model and Model:IsA("Model"),"Type[Model] Argument Must Be Model!")
    local TotalMass = 0;
    for _,Values in pairs(Model:GetDescendants()) do
        if (Values:IsA("BasePart")) then
            TotalMass += Values.AssemblyMass;
        end
    end
    return TotalMass
end

function KnockbackHandler.Apply(Model, Direction, Range, Height)
    local EnemyCharacter = Model

    EnemyCharacter.PrimaryPart:SetNetworkOwner(nil)
    EnemyCharacter.PrimaryPart:ApplyImpulse(Direction * KnockbackHandler.CalculateMass(EnemyCharacter) * Range + Vector3.new(0, KnockbackHandler.CalculateMass(EnemyCharacter) * Height, 0))
end

return KnockbackHandler