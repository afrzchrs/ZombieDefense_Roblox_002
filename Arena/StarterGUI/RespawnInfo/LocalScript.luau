local ReplicatedStorage = game:GetService("ReplicatedStorage")
local baseStatus = ReplicatedStorage:WaitForChild("BaseStatus")


local layarUI = script.Parent
local Icon = layarUI:WaitForChild("ImageLabel")

local textInfo = layarUI:WaitForChild("TextLabel") 


Icon.Visible = false
textInfo.Visible = false

baseStatus:GetPropertyChangedSignal("Value"):Connect(function()

	if baseStatus.Value == "Hancur" then


		Icon.Visible = true
		textInfo.Visible = true


	elseif baseStatus.Value == "Playing" then
		Icon.Visible = false
		textInfo.Visible = false
	end

end)