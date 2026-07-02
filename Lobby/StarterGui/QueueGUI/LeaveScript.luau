local ReplicatedStorage = game:GetService("ReplicatedStorage")
local queueRemotes = ReplicatedStorage:WaitForChild("QueueRemotes")

local leaveQueue = queueRemotes:WaitForChild("LeaveQueue")
local startNowQueue = queueRemotes:WaitForChild("StartNowQueue")
local queueState = queueRemotes:WaitForChild("QueueState")

-- Mengambil UI Buttons
local leaveButton = script.Parent:WaitForChild("LeaveButton")
local startButton = script.Parent:WaitForChild("StartButton")

-- Sembunyikan kedua tombol saat baru masuk game
leaveButton.Visible = false
startButton.Visible = false

-- Mengatur kapan tombol muncul (hanya saat masuk queue)
queueState.OnClientEvent:Connect(function(isInQueue)
	leaveButton.Visible = isInQueue
	startButton.Visible = isInQueue
end)

-- Aksi tombol Leave
leaveButton.MouseButton1Click:Connect(function()
	leaveButton.Visible = false
	startButton.Visible = false
	leaveQueue:FireServer()
end)

-- Aksi tombol Start Now
startButton.MouseButton1Click:Connect(function()
	leaveButton.Visible = false
	startButton.Visible = false
	startNowQueue:FireServer()
end)