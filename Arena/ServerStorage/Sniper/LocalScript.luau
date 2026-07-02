local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local bulletAssets = ReplicatedStorage:WaitForChild("BulletAssets")
local bulletTemplate = bulletAssets:WaitForChild("Bullet") 
local bulletTrailTemplate = bulletAssets:WaitForChild("BulletTrail") 

local tool = script.Parent
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local shootEvent = ReplicatedStorage:WaitForChild("ShootEvent")

local handle = tool:WaitForChild("Handle")
local fireSound = handle:WaitForChild("FireSound")
local hitSoundsFolder = handle:WaitForChild("HitSounds")

local barrel = tool:WaitForChild("ShootPart")
local mainEffectPart = tool:WaitForChild("Main") 

local animationsFolder = tool:WaitForChild("Animations")
local fireAnimation = animationsFolder:WaitForChild("Fire")
local idlePistolAnimation = animationsFolder:WaitForChild("Idle") 
local fireAnimTrack = nil 
local idleAnimTrack = nil 

local isShooting = false
local FIRE_RATE = 1.3-

local function createTracer(startPos, endPos)
	local distance = (endPos - startPos).Magnitude

	local bullet = bulletTemplate:Clone()
	local mundurOffset = 13

	bullet.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, mundurOffset)
	bullet.Parent = workspace

	local bulletSpeed = 1000
	local travelTime = distance / bulletSpeed

	local tweenInfo = TweenInfo.new(travelTime, Enum.EasingStyle.Linear)
	local flyTween = TweenService:Create(bullet, tweenInfo, {CFrame = CFrame.lookAt(endPos, endPos + (endPos - startPos))})

	flyTween:Play()
	Debris:AddItem(bullet, travelTime)
end

shootEvent.OnClientEvent:Connect(function(action)
	if action == "Hit" then
		local availableSounds = hitSoundsFolder:GetChildren()
		if #availableSounds > 0 then
			local randomSound = availableSounds[math.random(1, #availableSounds)]
			if randomSound:IsA("Sound") then
				randomSound:Play()
			end
		end
	end
end)

tool.Equipped:Connect(function()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local animator = humanoid:WaitForChild("Animator")

	if animator then

		if idlePistolAnimation then
			idleAnimTrack = animator:LoadAnimation(idlePistolAnimation)
			idleAnimTrack.Looped = true -- Tangan terus menahan pistol
			idleAnimTrack:Play() 
		end


		if fireAnimation then
			fireAnimTrack = animator:LoadAnimation(fireAnimation)
			fireAnimTrack.Looped = false 
		end
	end

	local equipSound = handle:FindFirstChild("Equip")
	if equipSound then equipSound:Play() end

	-- crosshair custom
	mouse.Icon = "rbxassetid://18334793111" 
end)

tool.Unequipped:Connect(function()
	isShooting = false

	if fireAnimTrack then fireAnimTrack:Stop() end
	if idleAnimTrack then idleAnimTrack:Stop() end
	mouse.Icon = "rbxasset://textures/GunCursor.png" 
end)

tool.Activated:Connect(function()

	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")

	if not humanoid or humanoid.Health <= 0 then
		return 
	end

	local gameStatus = game:GetService("ReplicatedStorage"):FindFirstChild("GameStatus")
	if gameStatus and (gameStatus.Value == "GameOver" or gameStatus.Value == "BaseHancur") then
		return
	end

	if isShooting then return end 
	isShooting = true

	if not mouse.Hit then 
		isShooting = false
		return 
	end

	while isShooting do
		if not mouse.Hit then break end

		if fireSound then fireSound:Play() end
		if fireAnimTrack then 
			fireAnimTrack:Play() 
		end

		if mainEffectPart then

			for _, effect in pairs(mainEffectPart:GetDescendants()) do

				if effect:IsA("ParticleEmitter") then
					effect:Emit(1) 

				elseif effect:IsA("Light") then
					effect.Enabled = true

					task.delay(0.05, function() 
						effect.Enabled = false 
					end)

				elseif effect:IsA("Decal") then
					effect.Transparency = 0

					task.delay(0.05, function() 
						effect.Transparency = 1 
					end)
				end
			end
		end

		local targetPosition = mouse.Hit.Position
		createTracer(barrel.Position, targetPosition)

		shootEvent:FireServer(targetPosition, tool.Name)

		task.wait(FIRE_RATE)

		isShooting=false
	end
end)


tool.Deactivated:Connect(function()
	-- Kosong
end)