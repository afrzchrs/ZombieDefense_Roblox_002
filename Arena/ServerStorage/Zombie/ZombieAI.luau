local Players = game:GetService("Players")
local Debris = game:GetService("Debris") 
local TweenService = game:GetService("TweenService")

local zombie = script.Parent
local rootPart = zombie:WaitForChild("HumanoidRootPart")
local humanoid = zombie:WaitForChild("Humanoid")
local base = workspace:WaitForChild("BaseTarget")

local SimplePath = require(script:WaitForChild("SimplePath"))
local path = SimplePath.new(zombie)

local attackTrack = humanoid.Animator:LoadAnimation(script:WaitForChild("AttackAnim"))
attackTrack.Priority = Enum.AnimationPriority.Action

local deathTrack = humanoid.Animator:LoadAnimation(script:WaitForChild("DeathAnim"))
deathTrack.Priority = Enum.AnimationPriority.Action

local deathSound = zombie:WaitForChild("Sound"):WaitForChild("DeathSound")

local AGGRO_RADIUS = 20
local ZOMBIE_DAMAGE = zombie:GetAttribute("CustomDamage") or 10
local ATTACK_COOLDOWN = 1.5

local isAttackingBase = false
local isAttackingPlayer = false
local isAttackingTurret = false 
local canAttackPlayer = true
local isZombieDead = false

local lockedTarget = nil 
local previousTarget = nil  
local lastPathUpdate = 0    
local lastStuckPos = rootPart.Position

humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) 
humanoid.UseJumpPower = false
humanoid.JumpHeight = 2.5
humanoid.BreakJointsOnDeath = false

local function getBestTarget()
	if isZombieDead then return nil end

	local BaseStatus = game:GetService("ReplicatedStorage"):FindFirstChild("BaseStatus")
	local isBaseHancur = (BaseStatus and (BaseStatus.Value == "Hancur"))

	if lockedTarget and lockedTarget ~= base and lockedTarget.Parent then
		local isStillValid = false
		local distanceToLocked = (rootPart.Position - lockedTarget.Position).Magnitude

		local turretAncestor = lockedTarget:FindFirstAncestor("mgTurret")
		if turretAncestor then
			local turretHp = turretAncestor:FindFirstChild("Health")
			if turretHp and turretHp.Value > 0 and distanceToLocked <= (AGGRO_RADIUS * 1.5) then
				isStillValid = true
			end
		else

			local hitHumanoid = lockedTarget.Parent:FindFirstChild("Humanoid")

			local jarakToleransi = isBaseHancur and math.huge or (AGGRO_RADIUS * 1.5)

			if hitHumanoid and hitHumanoid.Health > 0 and distanceToLocked <= jarakToleransi then
				isStillValid = true
			end
		end

		if isStillValid then
			return lockedTarget 
		end
	end


	local bestTarget = nil 


	local shortestDistance = isBaseHancur and math.huge or AGGRO_RADIUS

	if not isBaseHancur then
		bestTarget = base 
	end

	for _, obj in ipairs(workspace:GetChildren()) do
		if obj.Name == "mgTurret" then
			local turretPart = obj:FindFirstChild("Target") or obj.PrimaryPart
			local turretHp = obj:FindFirstChild("Health")

			if turretPart and turretHp and turretHp.Value > 0 then
				local distance = (rootPart.Position - turretPart.Position).Magnitude
				if distance < shortestDistance then
					shortestDistance = distance
					bestTarget = turretPart
				end
			end
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") and character.Humanoid.Health > 0 then
			local playerRoot = character.HumanoidRootPart
			local distance = (rootPart.Position - playerRoot.Position).Magnitude
			if distance < shortestDistance then
				shortestDistance = distance
				bestTarget = playerRoot
			end
		end
	end

	if bestTarget ~= base then
		lockedTarget = bestTarget 
	else
		lockedTarget = nil 
	end

	return bestTarget
end

local function attackTurretRoutine(turretHp)
	isAttackingTurret = true
	humanoid:MoveTo(rootPart.Position) 

	attackTrack.Looped = true
	if not attackTrack.IsPlaying then attackTrack:Play() end

	while isAttackingTurret and humanoid.Health > 0 and turretHp and turretHp.Parent and turretHp.Value > 0 do
		turretHp.Value -= ZOMBIE_DAMAGE

		local timer = 0
		while timer < ATTACK_COOLDOWN and isAttackingTurret do
			task.wait(0.5)
			timer += 0.5
		end
	end

	attackTrack:Stop()
	isAttackingTurret = false
	previousTarget = nil
end

local function attackBaseRoutine(baseHp)
	isAttackingBase = true
	humanoid:MoveTo(rootPart.Position) 

	attackTrack.Looped = true
	if not attackTrack.IsPlaying then attackTrack:Play() end

	while isAttackingBase and humanoid.Health > 0 and baseHp and baseHp.Parent and baseHp.Value > 0 do
		baseHp.Value -= ZOMBIE_DAMAGE

		local timer = 0
		while timer < ATTACK_COOLDOWN and isAttackingBase do
			task.wait(0.5)
			timer += 0.5
		end
	end

	attackTrack:Stop()
	isAttackingBase = false
	previousTarget = nil
end

local function attackPlayerRoutine(hitHumanoid)
	isAttackingPlayer = true
	canAttackPlayer = false
	humanoid:MoveTo(rootPart.Position)

	attackTrack.Looped = false
	attackTrack:Play()
	hitHumanoid:TakeDamage(ZOMBIE_DAMAGE)

	task.wait(ATTACK_COOLDOWN)

	isAttackingPlayer = false
	canAttackPlayer = true
	previousTarget = nil
end


local function setupHealthBar()
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "HealthBarUI"
	billboard.Adornee = zombie:FindFirstChild("Head")
	billboard.Size = UDim2.new(3, 0, 0.4, 0)
	billboard.StudsOffset = Vector3.new(0, 2.5, 0) 
	billboard.AlwaysOnTop = true

	local bg = Instance.new("Frame", billboard)
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(40, 40, 40) 
	bg.BorderSizePixel = 0

	local fill = Instance.new("Frame", bg)
	fill.Name = "Fill"
	fill.Size = UDim2.new(1, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(75, 181, 67) 
	fill.BorderSizePixel = 0

	billboard.Parent = zombie:FindFirstChild("Head")
	return fill
end

local fillBar = setupHealthBar()

humanoid.HealthChanged:Connect(function(newHealth)
	local hpPercent = math.clamp(newHealth / humanoid.MaxHealth, 0, 1)
	fillBar.Size = UDim2.new(hpPercent, 0, 1, 0)

	if hpPercent > 0.6 then
		fillBar.BackgroundColor3 = Color3.fromRGB(75, 181, 67) 
	elseif hpPercent > 0.3 then
		fillBar.BackgroundColor3 = Color3.fromRGB(255, 200, 0) 
	else
		fillBar.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	end
end)


rootPart.Touched:Connect(function(hit)

	if isZombieDead or humanoid.Health <= 0 or zombie:GetAttribute("IsSpawning") == true then return end

	local hitCharacter = hit.Parent
	if not hitCharacter then return end

	local hitHumanoid = hitCharacter:FindFirstChild("Humanoid")
	if hitHumanoid and hitHumanoid.Health > 0 and hitCharacter ~= zombie then
		local player = Players:GetPlayerFromCharacter(hitCharacter)

		if player and canAttackPlayer and not isAttackingBase and not isAttackingTurret then
			task.spawn(function() attackPlayerRoutine(hitHumanoid) end)
		end
	end
end)

humanoid.Died:Connect(function()
	isZombieDead = true

	if deathSound then
		deathSound:Play()
	end

	local JEDA_HILANG = 1 
	local DURASI_FADE = 3 
	Debris:AddItem(zombie, JEDA_HILANG + DURASI_FADE + 1)

	-- Distribusi Reward (DIPERBAIKI)
	local creatorTag = humanoid:FindFirstChild("creator")
	if creatorTag and creatorTag.Value and creatorTag.Value:IsA("Player") then
		local p = creatorTag.Value
		local wallet = p:FindFirstChild("Wallet")
		local leaderstats = p:FindFirstChild("leaderstats")
		
		if wallet and leaderstats then
			local uang = wallet:FindFirstChild("Uang")
			local kill = leaderstats:FindFirstChild("Kill")
			if uang and kill then 
				uang.Value += 80 
				kill.Value += 1
			end
		end
	else

		for _, player in pairs(Players:GetPlayers()) do
			local wallet = player:FindFirstChild("Wallet")
			local leaderstats = player:FindFirstChild("leaderstats")
			
			if wallet and leaderstats then 
				local uang = wallet:FindFirstChild("Uang")
				local kill = leaderstats:FindFirstChild("Kill")
				if uang and kill then 
					uang.Value += 80 
					kill.Value += 1
				end
			end
		end
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if animator then
		for _, track in pairs(animator:GetPlayingAnimationTracks()) do 
			track:Stop() 
		end
	end

	if deathTrack then
		deathTrack.Looped = false
		deathTrack:Play()

		local animLength = deathTrack.Length > 0 and deathTrack.Length or 1.5
		task.delay(animLength * 2, function()
			if deathTrack.IsPlaying then
				deathTrack:AdjustSpeed(0) 
			end
		end)
	end

	task.delay(JEDA_HILANG, function()
		if not zombie or not zombie.Parent then return end 
		if path then pcall(function() path:Destroy() end) end

		local fadeTween = TweenInfo.new(DURASI_FADE, Enum.EasingStyle.Linear)
		for _, part in ipairs(zombie:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("Decal") then
				TweenService:Create(part, fadeTween, {Transparency = 1}):Play()
			end
		end
	end)
end)

task.spawn(function()
	while humanoid.Health > 0 and not isZombieDead do
		local currentTarget = getBestTarget()

		if isAttackingBase and currentTarget ~= base then
			isAttackingBase = false 
		end
		if isAttackingTurret and (not currentTarget or not currentTarget:FindFirstAncestor("mgTurret")) then
			isAttackingTurret = false
		end

		if currentTarget == base and not isAttackingBase and not isAttackingPlayer and not isAttackingTurret then
			local distanceToBase = (rootPart.Position - base.Position).Magnitude
			if distanceToBase <= 12 then -- 8 (radius) + 4 (reach)
				local baseHp = base:FindFirstChild("HP")
				if baseHp and baseHp.Value > 0 then
					task.spawn(function() attackBaseRoutine(baseHp) end)
				end
			end
		elseif currentTarget and currentTarget:FindFirstAncestor("mgTurret") then
			if not isAttackingTurret and not isAttackingPlayer and not isAttackingBase then
				local distanceToTurret = (rootPart.Position - currentTarget.Position).Magnitude
				if distanceToTurret <= 9 then -- 6 (radius) + 3 (reach)
					local turretHp = currentTarget:FindFirstAncestor("mgTurret"):FindFirstChild("Health")
					if turretHp and turretHp.Value > 0 then
						task.spawn(function() attackTurretRoutine(turretHp) end)
					end
				end
			end
		end

		if not isAttackingBase and not isAttackingPlayer and not isAttackingTurret then
			if currentTarget then 
				local isPlayer = currentTarget.Parent:FindFirstChild("Humanoid") and Players:GetPlayerFromCharacter(currentTarget.Parent)
				local targetChanged = (currentTarget ~= previousTarget)
				local isStuck = false

				if not isPlayer and (tick() - lastPathUpdate >= 2.0) then
					local distanceMoved = (rootPart.Position - lastStuckPos).Magnitude
					if distanceMoved < 2 then isStuck = true end
					lastStuckPos = rootPart.Position
					lastPathUpdate = tick() + (math.random(-5, 5) * 0.1)
				end

				if targetChanged or (isPlayer and tick() - lastPathUpdate >= 0.5) or isStuck then
					previousTarget = currentTarget
					if isPlayer then lastPathUpdate = tick() end

					if currentTarget == base then
						local direction = (Vector3.new(rootPart.Position.X, 0, rootPart.Position.Z) - Vector3.new(base.Position.X, 0, base.Position.Z)).Unit
						pcall(function() path:Run(base.Position + (direction * 8)) end)
					else
						pcall(function() path:Run(currentTarget) end)
					end
				end
			else 
				if previousTarget ~= nil then
					previousTarget = nil
					humanoid:MoveTo(rootPart.Position)
				end
			end
		end	

		task.wait(0.1)
	end
end)

