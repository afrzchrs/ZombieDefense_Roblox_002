local indicator = script.Parent
local base = indicator.Parent
local safeRadiusValue = base:WaitForChild("SafeRadius")

-- Fungsi untuk menyesuaikan ukuran visual dengan radius di sistem
local function updateSize()
	local radius = safeRadiusValue.Value

	-- Dalam matematika, ukuran cincin/lingkaran penuh (Diameter) adalah Radius * 2
	local diameter = radius * 2

	-- Kita gunakan animasi Tweening agar lingkarannya membesar secara halus, 
	-- bukan membesar secara tiba-tiba/patah-patah.
	local TweenService = game:GetService("TweenService")
	local tweenInfo = TweenInfo.new(
		2, -- Durasi animasi (2 detik)
		Enum.EasingStyle.Sine, 
		Enum.EasingDirection.Out
	)

	-- Ingat, sumbu X (0.2) adalah ketebalan, Y dan Z adalah diameter lingkaran
	local goal = {Size = Vector3.new(0.2, diameter, diameter)}

	local sizeTween = TweenService:Create(indicator, tweenInfo, goal)
	sizeTween:Play()
end

-- 1. Atur ukuran lingkaran saat game baru pertama kali dimulai
updateSize()

-- 2. Pasang sensor: Kapan pun nilai 'SafeRadius' berubah, jalankan fungsi updateSize
safeRadiusValue.Changed:Connect(updateSize)