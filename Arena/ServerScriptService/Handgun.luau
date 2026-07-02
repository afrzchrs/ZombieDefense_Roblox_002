local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shootEvent = ReplicatedStorage:WaitForChild("ShootEvent")

local DAMAGE = 25
local MAX_RANGE = 200

shootEvent.OnServerEvent:Connect(function(player, targetPosition)
	local character = player.Character
	if not character then return end

	local head = character:FindFirstChild("Head")
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not head or not humanoid or humanoid.Health <= 0 then return end

	local direction = (targetPosition - head.Position).Unit * MAX_RANGE

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {character}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local raycastResult = workspace:Raycast(head.Position, direction, raycastParams)

	if raycastResult then
		local hitPart = raycastResult.Instance
		local model = hitPart:FindFirstAncestorOfClass("Model")

		if model then
			local targetHumanoid = model:FindFirstChildOfClass("Humanoid")
			local isTargetAPlayer = Players:GetPlayerFromCharacter(model)

			if targetHumanoid and targetHumanoid.Health > 0 and not isTargetAPlayer then

				local creatorTag = targetHumanoid:FindFirstChild("creator")

				if not creatorTag then
					creatorTag = Instance.new("ObjectValue")
					creatorTag.Name = "creator"
					creatorTag.Parent = targetHumanoid
				end

				creatorTag.Value = player

				targetHumanoid:TakeDamage(DAMAGE)

				shootEvent:FireClient(player, "Hit")
			end
		end
	end
end)