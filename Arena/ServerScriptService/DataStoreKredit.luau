local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local kreditStore = DataStoreService:GetDataStore("KreditData_V1")

local function muatDataPemain(player)
	local lobbyData = player:WaitForChild("LobbyData")
	local kredit = lobbyData:WaitForChild("Kredit")

	local playerKey = "Player_" .. player.UserId

	local success, savedData = pcall(function()
		return kreditStore:GetAsync(playerKey)
	end)

	if success then
		if savedData ~= nil then
			kredit.Value = savedData
			print("Data Kredit dimuat untuk " .. player.Name .. ": " .. savedData)
		end
	else
		warn("GAGAL memuat data untuk: " .. player.Name)
	end
end

local function simpanDataPemain(player)
	task.wait(0.1) 

	local lobbyData = player:FindFirstChild("LobbyData")
	if lobbyData and lobbyData:FindFirstChild("Kredit") then
		local kredit = lobbyData.Kredit.Value
		local playerKey = "Player_" .. player.UserId

		local success, errorMessage = pcall(function()
			kreditStore:SetAsync(playerKey, kredit)
		end)

		if success then
			print("Data Kredit BERHASIL disimpan untuk: " .. player.Name .. " | Saldo Terakhir: " .. kredit)
		else
			warn("GAGAL menyimpan data " .. player.Name .. ": " .. errorMessage)
		end
	end
end

Players.PlayerAdded:Connect(muatDataPemain)
Players.PlayerRemoving:Connect(simpanDataPemain)