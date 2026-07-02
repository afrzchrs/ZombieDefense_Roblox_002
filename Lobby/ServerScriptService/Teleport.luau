local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local queuesFolder = workspace:WaitForChild("Queues")
local queueRemotes = ReplicatedStorage:WaitForChild("QueueRemotes")
local leaveQueue = queueRemotes:WaitForChild("LeaveQueue")
local startNowQueue = queueRemotes:WaitForChild("StartNowQueue")
local queueState = queueRemotes:WaitForChild("QueueState")

local MAX_PLAYERS = 4
local MIN_PLAYERS = 1
local COUNTDOWN_TIME = 30 

local queuesData = {}

for _, queue in ipairs(queuesFolder:GetChildren()) do
	queuesData[queue] = {
		players = {},
		isCounting = false,
		timer = COUNTDOWN_TIME
	}

	local zone = queue:WaitForChild("Zone") 
	local exitPart = queue:WaitForChild("Exit")
	-- Mengambil target part InsidePort yang baru
	local insidePort = queue:WaitForChild("InsidePort") 
	local display = queue:WaitForChild("Display")
	local destinationId = queue:WaitForChild("DestinationPlaceId").Value

	local function updateDisplay()
		local billboardGui = display:FindFirstChildOfClass("BillboardGui")
		if billboardGui and billboardGui:FindFirstChild("TextLabel") then
			local label = billboardGui.TextLabel
			local playerCount = #queuesData[queue].players

			if queuesData[queue].isCounting then
				if queuesData[queue].timer == 0 then
					label.Text = "Teleporting...\n" .. playerCount .. "/" .. MAX_PLAYERS
				else
					label.Text = queuesData[queue].timer .. "s\n" .. playerCount .. "/" .. MAX_PLAYERS
				end
			else
				label.Text = "Waiting...\n" .. playerCount .. "/" .. MAX_PLAYERS
			end
		end
	end

	local function startCountdown()
		if queuesData[queue].isCounting then return end
		queuesData[queue].isCounting = true

		task.spawn(function()
			while queuesData[queue].timer > 0 and #queuesData[queue].players >= MIN_PLAYERS do
				task.wait(1)
				if queuesData[queue].timer > 0 then
					queuesData[queue].timer -= 1
				end
				updateDisplay()
			end

			if #queuesData[queue].players >= MIN_PLAYERS then
				local playersToTeleport = {}
				for _, p in ipairs(queuesData[queue].players) do
					table.insert(playersToTeleport, p)
					queueState:FireClient(p, false)
				end

				updateDisplay()
				task.wait(1)

				-- Reset Data
				queuesData[queue].players = {}
				queuesData[queue].isCounting = false
				queuesData[queue].timer = COUNTDOWN_TIME
				updateDisplay()

				local success, err = pcall(function()
					TeleportService:TeleportAsync(destinationId, playersToTeleport)
				end)
				if not success then
					warn("Teleport gagal: " .. err)
				end
			else
				queuesData[queue].isCounting = false
				queuesData[queue].timer = COUNTDOWN_TIME
				updateDisplay()
			end
		end)
	end

	-- Event Masuk Queue
	zone.Touched:Connect(function(hit)
		local character = hit.Parent
		local player = Players:GetPlayerFromCharacter(character)

		if player then
			local inAnyQueue = false
			for _, qData in pairs(queuesData) do
				if table.find(qData.players, player) then
					inAnyQueue = true
					break
				end
			end

			if not inAnyQueue and #queuesData[queue].players < MAX_PLAYERS then
				table.insert(queuesData[queue].players, player)

				-- Hentikan momentum lari karakter
				local rootPart = character:FindFirstChild("HumanoidRootPart")
				if rootPart then
					rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				end

				-- Pindahkan pemain ke titik InsidePort
				character:PivotTo(insidePort.CFrame + Vector3.new(0, 3, 0))

				updateDisplay()
				queueState:FireClient(player, true)

				if #queuesData[queue].players >= MIN_PLAYERS then
					startCountdown()
				end
			end
		end
	end)

	exitPart.Touched:Connect(function(hit)
		local character = hit.Parent
		local player = Players:GetPlayerFromCharacter(character)
		if player then
			local index = table.find(queuesData[queue].players, player)
			if index then
				table.remove(queuesData[queue].players, index)
				updateDisplay()
				queueState:FireClient(player, false)
			end
		end
	end)

	updateDisplay()
end

startNowQueue.OnServerEvent:Connect(function(player)
	for queue, data in pairs(queuesData) do
		if table.find(data.players, player) then
			if data.isCounting then
				data.timer = 0
			end
			break
		end
	end
end)

leaveQueue.OnServerEvent:Connect(function(player)
	for queue, data in pairs(queuesData) do
		local index = table.find(data.players, player)
		if index then
			table.remove(data.players, index)
			queueState:FireClient(player, false)

			local exitPart = queue:FindFirstChild("Exit")
			if exitPart and player.Character then
				player.Character:PivotTo(exitPart.CFrame + Vector3.new(0, 3, 0))
			end

			local display = queue:WaitForChild("Display")
			local billboardGui = display:FindFirstChildOfClass("BillboardGui")
			if billboardGui and billboardGui:FindFirstChild("TextLabel") then
				if data.isCounting then
					billboardGui.TextLabel.Text = data.timer .. "s\n" .. #data.players .. "/" .. MAX_PLAYERS
				else
					billboardGui.TextLabel.Text = "Waiting...\n" .. #data.players .. "/" .. MAX_PLAYERS
				end
			end
			break
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	for queue, data in pairs(queuesData) do
		local index = table.find(data.players, player)
		if index then
			table.remove(data.players, index)
			local display = queue:FindFirstChild("Display")
			if display then
				local billboardGui = display:FindFirstChildOfClass("BillboardGui")
				if billboardGui and billboardGui:FindFirstChild("TextLabel") then
					if data.isCounting then
						billboardGui.TextLabel.Text = data.timer .. "s\n" .. #data.players .. "/" .. MAX_PLAYERS
					else
						billboardGui.TextLabel.Text = "Waiting...\n" .. #data.players .. "/" .. MAX_PLAYERS
					end
				end
			end
			break
		end
	end
end)