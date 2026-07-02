local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local buyItemEvent = ReplicatedStorage:WaitForChild("BuyItemEvent")

buyItemEvent.OnServerEvent:Connect(function(player, itemName, itemPrice)

	local Wallet = player:FindFirstChild("Wallet")
	if not Wallet then return end

	local uang = Wallet:FindFirstChild("Uang")
	if not uang then return end

	if uang.Value >= itemPrice then
		local weaponModel = ServerStorage:FindFirstChild(itemName)

		if weaponModel then
			uang.Value = uang.Value - itemPrice
			local newWeapon = weaponModel:Clone()
			newWeapon.Parent = player:WaitForChild("Backpack")

			print("TRANSAKSI SUKSES: " .. player.Name .. " membeli " .. itemName)
		else
			warn("ERROR: Senjata " .. itemName .. " tidak ditemukan di ServerStorage!")
		end
	else
		print("TRANSAKSI GAGAL: Uang " .. player.Name .. " tidak cukup untuk " .. itemName)
	end

end)

local upgradeBaseEvent = ReplicatedStorage:WaitForChild("UpgradeBaseEvent")
local baseTarget = workspace:WaitForChild("BaseTarget")
local maxHpValue = baseTarget:WaitForChild("MaxHP")
local safeRadiusValue = baseTarget:WaitForChild("SafeRadius")
local hpValue = baseTarget:WaitForChild("HP")

local baseLevel = baseTarget:FindFirstChild("Level")
if not baseLevel then
	baseLevel = Instance.new("IntValue")
	baseLevel.Name = "Level"
	baseLevel.Value = 1
	baseLevel.Parent = baseTarget
end

local HARGA_UPGRADE = 1500

upgradeBaseEvent.OnServerEvent:Connect(function(player)
	local Wallet = player:FindFirstChild("Wallet")
	local uang = Wallet and Wallet:FindFirstChild("Uang")
	if not uang then return end

	if maxHpValue.Value >= 9000 then
		print("Base sudah mencapai level maksimal!")
		return
	end

	if uang.Value >= HARGA_UPGRADE then
		uang.Value = uang.Value - HARGA_UPGRADE

		maxHpValue.Value = maxHpValue.Value + 2000
		safeRadiusValue.Value = safeRadiusValue.Value + 3
		hpValue.Value = maxHpValue.Value 
		baseLevel.Value = baseLevel.Value + 1

		print(player.Name .. " TELAH MENG-UPGRADE BASE KE LEVEL " .. baseLevel.Value .. "!")
	else
		print("Uang tidak cukup untuk Upgrade Base!")
	end
end)