local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local beliSenjata = ReplicatedStorage:WaitForChild("BeliSenjataFunction")

beliSenjata.OnServerInvoke = function(player, hargaSenjata, namaSenjata)
	local Wallet = player:FindFirstChild("Wallet")
	local uang = Wallet and Wallet:FindFirstChild("Uang")

	if uang and uang.Value >= hargaSenjata then
		local folderSenjata = ServerStorage:FindFirstChild("DaftarSenjata")
		local toolSenjata = folderSenjata and folderSenjata:FindFirstChild(namaSenjata)

		if toolSenjata then
			local statusSenjata = player:FindFirstChild("SenjataSaatIni")

			if statusSenjata then
				uang.Value = uang.Value - hargaSenjata

				local namaSenjataLama = statusSenjata.Value
				if namaSenjataLama ~= "" then

					local character = player.Character
					if character then
						local humanoid = character:FindFirstChild("Humanoid")
						if humanoid then
							humanoid:UnequipTools()
						end
					end

					task.wait(0.1) 

					local diBackpack = player.Backpack:FindFirstChild(namaSenjataLama)
					if diBackpack then 
						diBackpack:Destroy() 
					end
				end

				statusSenjata.Value = namaSenjata

				local senjataBaru = toolSenjata:Clone()
				senjataBaru.Parent = player.Backpack

				print(player.Name .. " sukses upgrade Slot 3 ke " .. namaSenjata)
				return true 
			end
		else
			warn("Senjata " .. namaSenjata .. " tidak ditemukan di ServerStorage.DaftarSenjata!")
			return false
		end
	end

	return false 
end