local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gameStatus = ReplicatedStorage:WaitForChild("GameStatus")
local textLabel = script.Parent


textLabel.Text = gameStatus.Value


gameStatus.Changed:Connect(function()
	textLabel.Text = gameStatus.Value
end)