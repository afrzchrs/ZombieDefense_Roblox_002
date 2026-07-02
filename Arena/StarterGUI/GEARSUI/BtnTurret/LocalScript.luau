local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local beliTurretEvent = ReplicatedStorage:WaitForChild("BeliTurretFunction")

local tombol = script.Parent
local hargaTeks = tombol:WaitForChild("HargaText")
local infoTeks = tombol:WaitForChild("InfoText")

local isProcessing = false


local function cobaBeliTurret()
	if isProcessing then return end
	isProcessing = true

	local sukses, hargaBaru, jumlahBaru = beliTurretEvent:InvokeServer()

	if sukses then

		hargaTeks.Text = hargaBaru .. "$"
		infoTeks.Text = "Turret: " .. jumlahBaru

		tombol.ImageColor3 = Color3.fromRGB(150, 255, 150)
		task.wait(0.1)
		tombol.ImageColor3 = Color3.fromRGB(255, 255, 255)
	else

		local warnaAsli = hargaTeks.TextColor3
		hargaTeks.TextColor3 = Color3.fromRGB(255, 0, 0)
		task.wait(0.2)
		hargaTeks.TextColor3 = warnaAsli
	end

	task.wait(0.1)
	isProcessing = false
end


tombol.MouseButton1Click:Connect(cobaBeliTurret)


UserInputService.InputBegan:Connect(function(input, isTyping)
	if isTyping then return end
	if input.KeyCode == Enum.KeyCode.E then
		cobaBeliTurret()
	end
end)


local player = game:GetService("Players").LocalPlayer


task.spawn(function()

	local dataTurret = player:WaitForChild("DataTurret", 5) 

	if dataTurret then

		hargaTeks.Text = dataTurret.Harga.Value .. "$"
		infoTeks.Text = "Turret: " .. dataTurret.Jumlah.Value


		dataTurret.Jumlah:GetPropertyChangedSignal("Value"):Connect(function()
			infoTeks.Text = "Turret: " .. dataTurret.Jumlah.Value
		end)

		dataTurret.Harga:GetPropertyChangedSignal("Value"):Connect(function()
			hargaTeks.Text = dataTurret.Harga.Value .. "$"
		end)
	end
end)