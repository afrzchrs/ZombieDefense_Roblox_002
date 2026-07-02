local Players = game:GetService("Players")
local player = Players.LocalPlayer

local wadahUI = script.Parent
local uangText = wadahUI:WaitForChild("ImageLabel"):WaitForChild("UangText")

local function setupUang()
	local Wallet = player:WaitForChild("Wallet")
	local uang = Wallet:WaitForChild("Uang")

	local function updateUangUI()
		uangText.Text = tostring(uang.Value)
	end

	updateUangUI()

	uang:GetPropertyChangedSignal("Value"):Connect(updateUangUI)
end

setupUang()