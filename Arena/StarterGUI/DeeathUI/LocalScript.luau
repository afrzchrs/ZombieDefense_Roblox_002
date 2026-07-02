local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local respawnEvent = ReplicatedStorage:WaitForChild("RespawnTimerEvent")
local player = Players.LocalPlayer
local EventGameOver = ReplicatedStorage:WaitForChild("EventGameOver")

local deathUI = script.Parent
local bgFrame = deathUI:WaitForChild("BGFrame")
local textLabel = bgFrame:WaitForChild("TextLabel")

respawnEvent.OnClientEvent:Connect(function(waktuTunggu)

	bgFrame.Visible = true

	for i = waktuTunggu, 1, -1 do
		textLabel.Text = "YOU DIE\nRespawn in: " .. i .. "s"
		task.wait(1)
	end

	textLabel.Text = "Wait till Respawn..."
end)

player.CharacterAdded:Connect(function()
	bgFrame.Visible = false
end)
