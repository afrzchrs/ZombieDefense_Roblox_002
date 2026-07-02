local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local placeLandmineEvent = ReplicatedStorage:WaitForChild("PlaceLandmine")

local tombol = script.Parent 

local canPlace = true
local COOLDOWN = 1.0 

local function requestLandmine()
	if canPlace then
		canPlace = false
		placeLandmineEvent:FireServer()
		task.wait(COOLDOWN)
		canPlace = true
	end
end

if tombol:IsA("GuiButton") then
	tombol.MouseButton1Click:Connect(requestLandmine)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end 

	if input.KeyCode == Enum.KeyCode.C then
		requestLandmine()
	end
end)