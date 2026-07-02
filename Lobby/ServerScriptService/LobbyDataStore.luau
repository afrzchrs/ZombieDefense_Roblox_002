local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local kreditStore = DataStoreService:GetDataStore("KreditData_V1")

local function setupDataLobby(player)
	local lobbyData = Instance.new("Folder")
	lobbyData.Name = "LobbyData"
	lobbyData.Parent = player

	local kredit = Instance.new("IntValue")
	kredit.Name = "Kredit"
	kredit.Value = 0 
	kredit.Parent = lobbyData

	local playerKey = "Player_" .. player.UserId

	local success, savedData = pcall(function()
		return kreditStore:GetAsync(playerKey)
	end)

	if success and savedData ~= nil then
		kredit.Value = savedData
		print("Data Kredit Lobby dimuat untuk: " .. player.Name .. " | Saldo: " .. savedData)
	end
end

local function simpanDataLobby(player)
	local lobbyData = player:FindFirstChild("LobbyData")
	if lobbyData and lobbyData:FindFirstChild("Kredit") then
		local playerKey = "Player_" .. player.UserId

		pcall(function()
			kreditStore:SetAsync(playerKey, lobbyData.Kredit.Value)
		end)
	end
end

Players.PlayerAdded:Connect(setupDataLobby)
Players.PlayerRemoving:Connect(simpanDataLobby)print("Hello world!")
