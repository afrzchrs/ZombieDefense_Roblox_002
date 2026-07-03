local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local turret = script.Parent

local neckModel = turret:WaitForChild("Rotator") 
local headModel = turret:WaitForChild("Motor")   
local muzzleModel = turret:WaitForChild("Muzzle")

local neckCore = neckModel.PrimaryPart
local headCore = headModel.PrimaryPart
local muzzleCore = muzzleModel.PrimaryPart
local shootPart = muzzleModel:FindFirstChild("ShootPart", true)

local fireSound = shootPart:FindFirstChild("FireSound")
local hitSounds = shootPart:FindFirstChild("HitSounds")

local bulletAssets = ReplicatedStorage:WaitForChild("BulletAssets")
local bulletTemplate = bulletAssets:WaitForChild("Bullet") 
local bulletTrailTemplate = bulletAssets:WaitForChild("BulletTrail") 

local healthValue = turret:WaitForChild("Health")
local maxHealthValue = turret:WaitForChild("MaxHealth")
local hpUI = neckCore:WaitForChild("HP_UI")
local fillBar = hpUI:WaitForChild("Background"):WaitForChild("Fill")

local RANGE = 30
local DAMAGE = 60
local FIRE_RATE = 0.05 
local BARREL_SPIN_SPEED = 25 

local lastShootTime = 0
local currentSpin = 0

local headOffset = neckCore.CFrame:ToObjectSpace(headCore.CFrame)
local muzzleOffset = headCore.CFrame:ToObjectSpace(muzzleCore.CFrame)

healthValue.Changed:Connect(function(newHP)

	local hpPercent = math.clamp(newHP / maxHealthValue.Value, 0, 1)
	fillBar.Size = UDim2.new(hpPercent, 0, 1, 0)


	if hpPercent > 0.5 then
		fillBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Hijau
	elseif hpPercent > 0.2 then
		fillBar.BackgroundColor3 = Color3.fromRGB(255, 255, 0) -- Kuning
	else
		fillBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Merah
	end


	if newHP <= 0 then
		print("Turret Hancur!")
		script.Disabled = true 



		local fxPart = Instance.new("Part")
		fxPart.Transparency = 1
		fxPart.Anchored = true
		fxPart.CanCollide = false
		fxPart.Position = neckCore.Position
		fxPart.Parent = workspace
	
		local explosion = Instance.new("Explosion")
		explosion.Position = fxPart.Position
		explosion.BlastPressure = 0
		explosion.DestroyJointRadiusPercent = 0
		explosion.Parent = workspace


		local customSound = turret:FindFirstChild("ExplosionSound", true)
		if customSound then
			local soundClone = customSound:Clone()
			soundClone.Parent = fxPart
			soundClone:Play()
		end

		game:GetService("Debris"):AddItem(fxPart, 3)


		turret:Destroy()
	end
end)


local function createTracer(startPos, endPos)
	local distance = (endPos - startPos).Magnitude

	local bullet = bulletTemplate:Clone()
	local mundurOffset = -4

	bullet.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, mundurOffset)
	bullet.Parent = workspace

	local bulletSpeed = 500
	local travelTime = distance / bulletSpeed

	local tweenInfo = TweenInfo.new(travelTime, Enum.EasingStyle.Linear)

	local flyTween = TweenService:Create(bullet, tweenInfo, {CFrame = CFrame.lookAt(endPos, endPos + (endPos - startPos))})

	flyTween:Play()

	Debris:AddItem(bullet, travelTime)
end


local function getNearestTarget()
	local nearestDistance = RANGE
	local nearestTarget = nil

	for _, object in pairs(workspace:GetChildren()) do
		local humanoid = object:FindFirstChildOfClass("Humanoid")
		local hrp = object:FindFirstChild("HumanoidRootPart")

		if humanoid and hrp and humanoid.Health > 0 and not Players:GetPlayerFromCharacter(object) then
			local distance = (hrp.Position - headCore.Position).Magnitude
			if distance < nearestDistance then
				nearestDistance = distance
				nearestTarget = hrp
			end
		end
	end

	return nearestTarget
end

local function fireAtTarget(targetPos)
	local origin = shootPart.Position
	local direction = (targetPos - origin).Unit * RANGE

	local ignoreList = {turret}
	for _, p in pairs(Players:GetPlayers()) do
		if p.Character then table.insert(ignoreList, p.Character) end
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = ignoreList
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local raycastResult = workspace:Raycast(origin, direction, raycastParams)

	if raycastResult then
		createTracer(origin, raycastResult.Position)
	else
		createTracer(origin, origin + direction)
	end

	local flash = shootPart:FindFirstChildOfClass("ParticleEmitter")
	if flash then flash:Emit(1) end

	if raycastResult then
		local hitPart = raycastResult.Instance
		local model = hitPart:FindFirstAncestorOfClass("Model")

		if model then
			local targetHumanoid = model:FindFirstChildOfClass("Humanoid")
			local hitSounds = hitPart:FindFirstChild("Hit")

			if targetHumanoid then
				targetHumanoid:TakeDamage(DAMAGE)
				if hitSounds then hitSounds:Play() end
				if fireSound then fireSound:Play() end
			end
		end
	end
end

RunService.Heartbeat:Connect(function()

	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")

	if not humanoid or humanoid.Health <= 0 then
		return 
	end

	local gameStatus = game:GetService("ReplicatedStorage"):FindFirstChild("GameStatus")
	if gameStatus and (gameStatus.Value == "GameOver" or gameStatus.Value == "BaseHancur") then
		return
	end

	
	local targetHRP = getNearestTarget()

	if targetHRP then
		local targetPos = targetHRP.Position

		local flatTargetPos = Vector3.new(targetPos.X, neckCore.Position.Y, targetPos.Z)
		local newNeckCFrame = CFrame.lookAt(neckCore.Position, flatTargetPos)
		neckModel:PivotTo(newNeckCFrame)

		local headWorldPos = newNeckCFrame:PointToWorldSpace(headOffset.Position)
		local newHeadCFrame = CFrame.lookAt(headWorldPos, targetPos)
		headModel:PivotTo(newHeadCFrame)

		currentSpin = currentSpin + BARREL_SPIN_SPEED
		local newMuzzleCFrame = newHeadCFrame * muzzleOffset * CFrame.Angles(0, 0, math.rad(currentSpin))
		muzzleModel:PivotTo(newMuzzleCFrame)

		if tick() - lastShootTime >= FIRE_RATE then
			lastShootTime = tick()
			fireAtTarget(targetPos)
		end
	else

		if currentSpin > 0 then
			currentSpin = currentSpin - 1
			local newMuzzleCFrame = headCore.CFrame * muzzleOffset * CFrame.Angles(0, 0, math.rad(currentSpin))
			muzzleModel:PivotTo(newMuzzleCFrame)
		end
	end
end)