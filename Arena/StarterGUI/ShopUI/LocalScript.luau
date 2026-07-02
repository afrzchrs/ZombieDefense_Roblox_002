local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local shopUI = script.Parent
local mainFrame = shopUI:WaitForChild("MainFrame")
local closeButton = mainFrame:WaitForChild("CloseButton")

local openShopEvent = ReplicatedStorage:WaitForChild("OpenShopEvent")


openShopEvent.OnClientEvent:Connect(function()

	mainFrame.Visible = true
end)


closeButton.MouseButton1Click:Connect(function()

	mainFrame.Visible = false
end)


local buyItemEvent = ReplicatedStorage:WaitForChild("BuyItemEvent")



local upgradeButton = mainFrame:WaitForChild("UpgradeBaseButton")
local upgradeEvent = ReplicatedStorage:WaitForChild("UpgradeBaseEvent")

upgradeButton.MouseButton1Click:Connect(function()

	upgradeEvent:FireServer()
end)


local baseTarget = workspace:WaitForChild("BaseTarget")
local baseLevel = baseTarget:WaitForChild("Level")


local teksLevel = mainFrame:WaitForChild("TeksLevel") 

local function updateTeksLevel()

	local targetLevelSelanjutnya = baseLevel.Value + 1 


	if targetLevelSelanjutnya > 5 then 
		teksLevel.Text = "BASE MAX LEVEL"
	else
		teksLevel.Text = "Upgrade Tower to level " .. targetLevelSelanjutnya .. "?"
	end
end

updateTeksLevel()

baseLevel:GetPropertyChangedSignal("Value"):Connect(updateTeksLevel)