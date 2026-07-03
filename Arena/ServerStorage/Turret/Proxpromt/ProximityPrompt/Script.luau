local prompt = script.Parent

-- ==========================================
-- HEADER DIPERBAIKI (Pencarian Otomatis)
-- ==========================================
-- Script otomatis memanjat ke atas untuk mencari Model utamanya.
-- Sangat aman meskipun kamu memindah-mindahkan posisi ProximityPrompt nanti!
local turretModel = prompt:FindFirstAncestorWhichIsA("Model")

-- Mencegah error jika terjadi kegagalan sistem saat turret di-spawn
if not turretModel then
	warn("Error: Script tidak bisa menemukan Model Turret induknya!")
	return
end

-- ==========================================
-- KONFIGURASI HARGA
-- ==========================================
local HARGA_BELI_TURRET = 100 
local HARGA_JUAL = math.floor(HARGA_BELI_TURRET * 0.75) 

prompt.ActionText = "Jual"
prompt.ObjectText = "Turret ($" .. HARGA_JUAL .. ")"
prompt.HoldDuration = 1 

-- Mengubah tombol PC menjadi R
prompt.KeyboardKeyCode = Enum.KeyCode.R

-- ==========================================
-- LOGIKA PENJUALAN & ANTI-BUG
-- ==========================================
prompt.Triggered:Connect(function(player)
	-- 1. Sistem Keamanan (Anti-Spam Auto-clicker)
	if turretModel:GetAttribute("IsSold") then return end
	turretModel:SetAttribute("IsSold", true)
	prompt.Enabled = false 

	-- 2. Pencarian Dompet Pemain (Menggunakan "Wallet")
	local Wallet = player:FindFirstChild("Wallet")
	local uang = Wallet and Wallet:FindFirstChild("Uang")

	if uang then
		-- 3. Transaksi Berhasil
		uang.Value += HARGA_JUAL
		turretModel:Destroy()
	else
		-- Jika dompet tidak ditemukan, batalkan status terjual agar bisa dicoba lagi
		turretModel:SetAttribute("IsSold", false)
		prompt.Enabled = true
		warn("Gagal menjual: Sistem Uang tidak ditemukan pada player " .. player.Name)
	end
end)