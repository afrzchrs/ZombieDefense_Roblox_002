local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local placeEvent = ReplicatedStorage:WaitForChild("PlaceTurretEvent")
local realTurretTemplate = ServerStorage:WaitForChild("mgTurret")

placeEvent.OnServerEvent:Connect(function(player, targetCFrame)
	local dataTurret = player:FindFirstChild("DataTurret")
	local stokTurret = dataTurret and dataTurret:FindFirstChild("Jumlah")

	if not stokTurret or stokTurret.Value <= 0 then
		print(player.Name .. " mencoba memasang turret tanpa membelinya terlebih dahulu!")
		return 
	end
	
	stokTurret.Value = stokTurret.Value - 1


	local newTurret = realTurretTemplate:Clone()

	newTurret:PivotTo(targetCFrame)

	newTurret.Parent = workspace

	local equipSound = newTurret:FindFirstChild("Equip", true)
	if equipSound then
		equipSound:Play()
	end

	print(player.Name .. " berhasil memasang turret! Sisa stok: " .. stokTurret.Value)
end)