local ReplicatedStorage = game:GetService("ReplicatedStorage")
local eventGameOver = ReplicatedStorage:WaitForChild("EventGameOver")
local TeleportService = game:GetService("TeleportService")

local uiUtama = script.Parent 
local bgFrame = uiUtama:WaitForChild("BGOverFrame")
local tombolLobby = bgFrame:WaitForChild("backToLobby")


eventGameOver.OnClientEvent:Connect(function(jumlahKill, jumlahWave, totalKredit)


	local playerGui = uiUtama.Parent 
	local deathUI = playerGui:FindFirstChild("DeathUI")
	if deathUI then
		deathUI.Enabled = false
	end


	bgFrame.Visible = true


	bgFrame.Wave.Text = "Wave Tercapai: " .. tostring(jumlahWave)
	bgFrame.Kill.Text = "Total Kill: " .. tostring(jumlahKill)
	bgFrame.Kredit.Text = "+ " .. tostring(totalKredit) .. " Kredit"

end)

local LOBBY_PLACE_ID = 134615269781686 

tombolLobby.MouseButton1Click:Connect(function()
	TeleportService:Teleport(LOBBY_PLACE_ID)
end)