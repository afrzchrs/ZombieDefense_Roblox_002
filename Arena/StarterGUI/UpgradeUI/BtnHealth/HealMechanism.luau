local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local beliHealthEvent = ReplicatedStorage:WaitForChild("BeliHealthFunction")

local tombol = script.Parent
local hargaTeks = tombol:WaitForChild("HargaText") 
local infoTeks = tombol:WaitForChild("InfoText") 

local isProcessing = false


local function cobaBeliHealth()

	if isProcessing then return end
	isProcessing = true


	local sukses, hargaBaru, maxHealthBaru = beliHealthEvent:InvokeServer()

	if sukses then

		hargaTeks.Text = hargaBaru .. "$"
		infoTeks.Text = "Health : " .. maxHealthBaru


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


tombol.MouseButton1Click:Connect(function()Teks
	print("Tombol Health berhasil diklik mouse!") 
	cobaBeliHealth()
end)


UserInputService.InputBegan:Connect(function(input, isTyping)

	if isTyping then return end

	if input.KeyCode == Enum.KeyCode.Q then
		cobaBeliHealth()
	end
end)


local player = game:GetService("Players").LocalPlayer

local function pantauKondisiPemain(character)
	local humanoid = character:WaitForChild("Humanoid")


	local function perbaruiTeksHealth()
		infoTeks.Text = "Health : " .. humanoid.MaxHealth
	end


	perbaruiTeksHealth()

	humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(perbaruiTeksHealth)


	task.wait(0.5) 
	local dataHealth = player:FindFirstChild("DataHealth")
	if dataHealth then
		hargaTeks.Text = dataHealth.Harga.Value .. "$"
	else
		hargaTeks.Text = "5$"
	end
end


if player.Character then
	pantauKondisiPemain(player.Character)
end


player.CharacterAdded:Connect(pantauKondisiPemain)