local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shootEvent = ReplicatedStorage:WaitForChild("ShootEvent")

local DAMAGE = 75
local MAX_RANGE = 700

shootEvent.OnServerEvent:Connect(function(player, targetPosition, weaponName)

	if weaponName ~= "Riffle" then return end

	local character = player.Character
	if not character then return end

	local tool = character:FindFirstChild("Riffle")
	if not tool then return end
	local shootPart = tool:FindFirstChild("ShootPart")
	if not shootPart then return end

	local origin = shootPart.Position
	local direction = (targetPosition - origin).Unit * MAX_RANGE

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {character}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local raycastResult = workspace:Raycast(origin, direction, raycastParams)

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