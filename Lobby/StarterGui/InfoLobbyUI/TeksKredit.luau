local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Mengambil TextLabel tempat script ini berada
local teksKredit = script.Parent 

local function updateUI()
	-- Tunggu sampai server selesai membuat folder dan mengambil data dari DataStore
	local lobbyData = player:WaitForChild("LobbyData")
	local kredit = lobbyData:WaitForChild("Kredit")

	-- Update teks saat pertama kali masuk
	teksKredit.Text = "Kredit: " .. tostring(kredit.Value)

	-- CCTV Perubahan (Jika pemain membeli sesuatu di Lobby, UI akan otomatis ter-update)
	kredit.Changed:Connect(function(nilaiBaru)
		teksKredit.Text = "Kredit: " .. tostring(nilaiBaru)
	end)
end

updateUI()