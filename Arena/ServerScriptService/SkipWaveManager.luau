local ReplicatedStorage = game:GetService("ReplicatedStorage")
local skipEvent = ReplicatedStorage:WaitForChild("SkipWaveEvent")
local skipActive = ReplicatedStorage:WaitForChild("SkipActive")

skipEvent.OnServerEvent:Connect(function(player)
	skipActive.Value = not skipActive.Value 
end)