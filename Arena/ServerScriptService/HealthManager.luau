local ReplicatedStorage = game:GetService("ReplicatedStorage")
local beliHealth = ReplicatedStorage:WaitForChild("BeliHealthFunction")

beliHealth.OnServerInvoke = function(player)
	local Wallet = player:FindFirstChild("Wallet")
	local uang = Wallet and Wallet:FindFirstChild("Uang")
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")

	if uang and humanoid then
		local dataHealth = player:FindFirstChild("DataHealth")
		if not dataHealth then
			dataHealth = Instance.new("Folder")
			dataHealth.Name = "DataHealth"
			dataHealth.Parent = player

			local harga = Instance.new("IntValue")
			harga.Name = "Harga"
			harga.Value = 5 
			harga.Parent = dataHealth

			local bonusHP = Instance.new("IntValue")
			bonusHP.Name = "BonusHP"
			bonusHP.Value = 0 
			bonusHP.Parent = dataHealth
		end

		local hargaSaatIni = dataHealth.Harga.Value

		if uang.Value >= hargaSaatIni then
			uang.Value = uang.Value - hargaSaatIni

			dataHealth.BonusHP.Value = dataHealth.BonusHP.Value + 20
			humanoid.MaxHealth = 100 + dataHealth.BonusHP.Value
			humanoid.Health = humanoid.Health + 20

			dataHealth.Harga.Value = hargaSaatIni + 10

			return true, dataHealth.Harga.Value, humanoid.MaxHealth
		end
	end

	return false, nil, nil 
end