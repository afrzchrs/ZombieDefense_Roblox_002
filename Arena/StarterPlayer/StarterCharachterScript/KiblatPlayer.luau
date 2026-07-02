local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()


local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")


humanoid.AutoRotate = false


RunService.RenderStepped:Connect(function()

	if humanoid.Health > 0 and mouse.Hit then
		local mousePos = mouse.Hit.Position


		local lookTarget = Vector3.new(mousePos.X, rootPart.Position.Y, mousePos.Z)


		rootPart.CFrame = CFrame.lookAt(rootPart.Position, lookTarget)
	end
end)