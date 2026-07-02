local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local function setupLeaderstats(player)
	if player:FindFirstChild("leaderstats") then 
		return 
	end

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local kill = Instance.new("IntValue")
	kill.Name = "Kill"
	kill.Value = 0
	kill.Parent = leaderstats

	print("Leaderstats BERHASIL dibuat untuk pemain: " .. player.Name)
end

local function setupWallet(player)
	if player:FindFirstChild("Wallet") then 
		return 
	end
	
	local Wallet = Instance.new("Folder")
	Wallet.Name = "Wallet"
	Wallet.Parent = player
	
	local Uang = Instance.new("IntValue")
	Uang.Name = "Uang"
	Uang.Value = 0
	Uang.Parent = Wallet
	
	print("Wallet BERHASIL dibuat untuk pemain: " .. player.Name)
end

local function setupDataTurret(player)
	if player:FindFirstChild("DataTurret") then 
		return 
	end
	
	dataTurret = Instance.new("Folder")
	dataTurret.Name = "DataTurret"
	dataTurret.Parent = player

	local harga = Instance.new("IntValue")
	harga.Name = "Harga"
	harga.Value = 500 
	harga.Parent = dataTurret

	local jumlah = Instance.new("IntValue")
	jumlah.Name = "Jumlah"
	jumlah.Value = 0 
	jumlah.Parent = dataTurret
	
	print("DataTurret BERHASIL dibuat untuk pemain: " .. player.Name)
end

local function setupLobbyData(player)
	if player:FindFirstChild("LobbyData") then return end

	local lobbyData = Instance.new("Folder")
	lobbyData.Name = "LobbyData"
	lobbyData.Parent = player

	local kredit = Instance.new("IntValue")
	kredit.Name = "Kredit"
	kredit.Value = 0 
	kredit.Parent = lobbyData
end


local function setupPlayer(player)
	setupLeaderstats(player)
	setupWallet(player)
	setupDataTurret(player)
	setupLobbyData(player)
end

Players.PlayerAdded:Connect(setupPlayer)