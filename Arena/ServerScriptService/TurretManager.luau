local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local beliTurret = ReplicatedStorage:WaitForChild("BeliTurretFunction")

beliTurret.OnServerInvoke = function(player)
	local wallet= player:FindFirstChild("Wallet")
	local uang = wallet and wallet:FindFirstChild("Uang")

	if uang then
		local dataTurret = player:FindFirstChild("DataTurret")

		local hargaSaatIni = dataTurret.Harga.Value

		if uang.Value >= hargaSaatIni then

			local folderSenjata = ServerStorage:FindFirstChild("DaftarSenjata")
			local itemTurret = folderSenjata and folderSenjata:FindFirstChild("Turret")

			if itemTurret then
				uang.Value = uang.Value - hargaSaatIni

				dataTurret.Jumlah.Value = dataTurret.Jumlah.Value + 1
				dataTurret.Harga.Value = hargaSaatIni + 200

				return true, dataTurret.Harga.Value, dataTurret.Jumlah.Value
			else
				warn("Error: Tool 'Turret' tidak ditemukan di ServerStorage.DaftarSenjata!")
				return false
			end
		end
	end

	return false
end