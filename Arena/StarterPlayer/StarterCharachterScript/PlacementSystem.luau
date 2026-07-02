local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()


local ghostTemplate = ReplicatedStorage:WaitForChild("GhostTurret")
local placeEvent = ReplicatedStorage:WaitForChild("PlaceTurretEvent")
local baseTarget = workspace:WaitForChild("BaseTarget")
local safeRadiusValue = baseTarget:WaitForChild("SafeRadius")


local GRID_SIZE = 4 
local isBuildMode = false
local currentGhost = nil
local canBuildHere = false

local function snapToGrid(rawPosition)

	local snapX = math.round(rawPosition.X / GRID_SIZE) * GRID_SIZE
	local snapZ = math.round(rawPosition.Z / GRID_SIZE) * GRID_SIZE


	local rayOrigin = Vector3.new(snapX, 500, snapZ) x
	local rayDirection = Vector3.new(0, -1000, 0)    
	
	local rayParams = RaycastParams.new()
	local ignoreList = {}
	

	if currentGhost then table.insert(ignoreList, currentGhost) end
	if baseTarget then table.insert(ignoreList, baseTarget) end
	
	for _, p in pairs(game.Players:GetPlayers()) do
		if p.Character then table.insert(ignoreList, p.Character) end
	end
	
	for _, obj in pairs(workspace:GetChildren()) do
		if obj.Name == "mgTurret" then table.insert(ignoreList, obj) end
	end
	
	rayParams.FilterDescendantsInstances = ignoreList
	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	
	local raycastResult = workspace:Raycast(rayOrigin, rayDirection, rayParams)


	local snapY = 2 


	if raycastResult then

		snapY = raycastResult.Position.Y + 2
	end

	return Vector3.new(snapX, snapY, snapZ)
end

local function updateGhostPosition()
	if not currentGhost then return end

	local mousePos = mouse.Hit.Position
	local snappedPos = snapToGrid(mousePos)

	local flatBasePos = Vector3.new(baseTarget.Position.X, 0, baseTarget.Position.Z)
	local flatGhostPos = Vector3.new(snappedPos.X, 0, snappedPos.Z)
	local distanceFromBase = (flatBasePos - flatGhostPos).Magnitude

	canBuildHere = (distanceFromBase <= safeRadiusValue.Value)


	if canBuildHere then
		for _, object in pairs(workspace:GetChildren()) do

			if object.Name == "mgTurret" and object:IsA("Model") then


				local existingPos = object:GetPivot().Position
				local flatExistingPos = Vector3.new(existingPos.X, 0, existingPos.Z)

				local distanceBetweenTurrets = (flatExistingPos - flatGhostPos).Magnitude

	
				if distanceBetweenTurrets < (GRID_SIZE / 2) then
					canBuildHere = false
					break 
				end

			end
		end
	end


	local targetColor = canBuildHere and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)


	for _, part in pairs(currentGhost:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Color = targetColor
			part.Material = Enum.Material.Neon
			part.Transparency = 0.5
		end
	end

	currentGhost:PivotTo(CFrame.new(snappedPos))
end


UserInputService.InputBegan:Connect(function(input, isProcessed)
	if isProcessed then return end

	-- Tekan 'B' untuk Toggle Mode Bangun
	if input.KeyCode == Enum.KeyCode.F then
		isBuildMode = not isBuildMode

		if isBuildMode then
			currentGhost = ghostTemplate:Clone()
			currentGhost.Parent = workspace
			print("Mode Bangun AKTIF")
		else
			if currentGhost then currentGhost:Destroy() end
			currentGhost = nil
			print("Mode Bangun NONAKTIF")
		end
	end


	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if isBuildMode and currentGhost and canBuildHere then

			local placeCFrame = currentGhost:GetPivot()
			placeEvent:FireServer(placeCFrame)


			isBuildMode = false
			currentGhost:Destroy()
			currentGhost = nil
		elseif isBuildMode and not canBuildHere then
			print("Tidak bisa membangun di luar area aman!")
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if isBuildMode then
		updateGhostPosition()
	end
end)