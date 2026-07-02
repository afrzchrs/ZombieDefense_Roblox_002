local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local skipEvent = ReplicatedStorage:WaitForChild("SkipWaveEvent")
local skipActive = ReplicatedStorage:WaitForChild("SkipActive") 
local tombol = script.Parent

local tombolText = tombol:FindFirstChild("TextLabel")
local indicator = tombol.Parent:WaitForChild("ImageLabel") 
local indicatorText = indicator:WaitForChild("TextLabel")

local warnaNormal = Color3.fromRGB(255, 255, 255)
local warnaHover = Color3.fromRGB(200, 200, 200) 
local warnaDitekan = Color3.fromRGB(120, 120, 120) 
local warnaTombolAktif = Color3.fromRGB(100, 255, 100) 

local warnaTeksON = Color3.fromRGB(0, 170, 0)       
local warnaTeksOFF = Color3.fromRGB(170, 0, 0)


local warnabackgroundON = Color3.fromRGB(0, 212, 0) 
local warnabackgroundOFF = Color3.fromRGB(255, 0, 0) 

local function ubahWarna(targetWarna)
	local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(tombol, tweenInfo, {ImageColor3 = targetWarna}):Play()
end


tombol.MouseEnter:Connect(function()
	ubahWarna(warnaHover)
end)

tombol.MouseLeave:Connect(function()
	if skipActive.Value then
		ubahWarna(warnaTombolAktif)
	else
		ubahWarna(warnaNormal)
	end
end)

tombol.MouseButton1Down:Connect(function()
	ubahWarna(warnaDitekan)
end)

tombol.MouseButton1Click:Connect(function()
	skipEvent:FireServer()
end)


skipActive.Changed:Connect(function(isActive)
	if isActive then

		ubahWarna(warnaTombolAktif)
		if tombolText then tombolText.Text = "SkipWave" end

		if indicatorText then
			indicatorText.Text = "ON"
			indicatorText.TextColor3 = warnaTeksON
		end


		indicator.BackgroundColor3 = warnabackgroundON
		indicator.ImageColor3 = warnabackgroundON
	else

		ubahWarna(warnaNormal)
		if tombolText then tombolText.Text = "SkipWave" end

		if indicatorText then
			indicatorText.Text = "OFF"
			indicatorText.TextColor3 = warnaTeksOFF
		end

	
		indicator.BackgroundColor3 = warnabackgroundOFF
		indicator.ImageColor3 = warnabackgroundOFF
	end
end)


if not skipActive.Value then
	if indicatorText then
		indicatorText.Text = "OFF"
		indicatorText.TextColor3 = warnaTeksOFF
	end

	-- ?? SETELAN BACKGROUND AWAL (MERAH)
	indicator.BackgroundColor3 = warnabackgroundOFF
	indicator.ImageColor3 = warnabackgroundOFF
end


if not skipActive.Value then
	if indicatorText then
		indicatorText.Text = "OFF"
		indicatorText.TextColor3 = warnaTeksOFF
	end

	-- ?? Setelan Background Awal (OFF)
	indicator.ImageColor3 = warnabackgroundOFF
end