local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris") 


local eventGameOver = ReplicatedStorage:WaitForChild("EventGameOver")
local respawnEvent = ReplicatedStorage:WaitForChild("RespawnTimerEvent")

local dataSisaZombie = ReplicatedStorage:WaitForChild("SisaZombie")

Players.CharacterAutoLoads = false

local base = workspace:WaitForChild("BaseTarget")
local baseHpValue = base:WaitForChild("HP")
local safeRadiusValue = base:WaitForChild("SafeRadius")
local gameStatus = ReplicatedStorage:WaitForChild("GameStatus")
local zombieTemplate = ServerStorage:WaitForChild("Zombie") 
local SlowZombieTemplate = ServerStorage:WaitForChild("SlowZombie") 
local TankZombieTemplate = ServerStorage:WaitForChild("TankZombie") 
local FastZombieTemplate = ServerStorage:WaitForChild("FastZombie") 
local TitanZombieTemplate = ServerStorage:WaitForChild("TitanZombie")
local currentWave = 5
local isWaveActive = false
local aliveZombies = 0
local isGameOver = false
local INTERMISSION_TIME = 15
local uang = 0

local spawnRadiusMax = 400
local BATCH_SIZE = 20            -
local BATCH_DELAY = 3

local skipEvent = ReplicatedStorage:WaitForChild("SkipWaveEvent")
local isSkipped = false

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local skipEvent = ReplicatedStorage:WaitForChild("SkipWaveEvent")
local BaseStatus = ReplicatedStorage:WaitForChild("BaseStatus")

local isSkipped = false

skipEvent.OnServerEvent:Connect(function(player)
	isSkipped = true
	print(player.Name .. " telah menekan Skip Wave!")
end)

local BASE_KILL_REWARD = 10
local WAVE_MULTIPLIER = 0.5

local function hitungDanBerikanHadiah(p, finalWave)
	local killValue = 0
	local totalHadiah = 0

	local leaderstats = p:FindFirstChild("leaderstats")
	if leaderstats and leaderstats:FindFirstChild("Kill") then
		killValue = leaderstats.Kill.Value
		leaderstats.Kill.Value = 0 
	end

	local lobbyData = p:FindFirstChild("LobbyData")
	if lobbyData and lobbyData:FindFirstChild("Kredit") then
		lobbyData.Kredit.Value = lobbyData.Kredit.Value + totalHadiah
		print("[REWARD] " .. p.Name .. " mendapat " .. totalHadiah .. " Kredit")
	else
		warn("[WARNING] Folder LobbyData belum ada untuk " .. p.Name .. ", tapi UI Game Over akan tetap dimunculkan.")
	end

	eventGameOver:FireClient(p, killValue, finalWave, totalHadiah)
end

local function checkGameOver()
	if isGameOver then return end 

	if baseHpValue.Value > 0 then return end 

	local playersAlive = false
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
			playersAlive = true
			break
		end
	end

	if not playersAlive then
		isGameOver = true
		gameStatus.Value = "GAME OVER! (Semua Player Mati & Base Hancur)"

		local waveTerakhir = currentWave

		for _, p in ipairs(Players:GetPlayers()) do
			hitungDanBerikanHadiah(p, waveTerakhir)
		end
	end
end

baseHpValue.Changed:Connect(function()
	if baseHpValue.Value <= 0 then
		checkGameOver()
	end
end)

Players.PlayerRemoving:Connect(function(player)
	if not isGameOver then
		local waveSaatIni = 5 
		hitungDanBerikanHadiah(player, waveSaatIni)
	end
end)


local function handlePlayerDeath(player)

	local dataHealth = player:FindFirstChild("DataHealth")
	if dataHealth then
		local humanoid = player.Character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.MaxHealth = 100 + dataHealth.BonusHP.Value
			humanoid.Health = humanoid.MaxHealth
		end
	end

	if isGameOver then return end

	checkGameOver()

	if isGameOver then 
		return 
	end


	local respawnTime = 1 + currentWave
	respawnEvent:FireClient(player, respawnTime) -- Memunculkan DeathUI
	gameStatus.Value = player.Name .. " MATI! (" .. respawnTime .. "s)"

	task.wait(respawnTime)

	if baseHpValue.Value > 0 and not isGameOver then
		player:LoadCharacter() 
	else
		checkGameOver()
	end
end

local function setupPlayer(player)

	local statusSenjata = Instance.new("StringValue")
	statusSenjata.Name = "SenjataSaatIni"
	statusSenjata.Value = "Pistol"
	statusSenjata.Parent = player

	local function onCharacterAdded(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.Died:Connect(function()
			handlePlayerDeath(player)
		end)

		task.wait(0.1) 
		local folderSenjata = ServerStorage:WaitForChild("DaftarSenjata")
		local senjataBawaan = folderSenjata:FindFirstChild(statusSenjata.Value)

		if senjataBawaan then
			for _, item in ipairs(player.Backpack:GetChildren()) do
				if item:IsA("Tool") then item:Destroy() end
			end

			local clone = senjataBawaan:Clone()
			clone.Parent = player.Backpack
		end
	end

	player.CharacterAdded:Connect(onCharacterAdded)
	
	local leaderstats = player:WaitForChild("leaderstats")
	local kill = leaderstats:WaitForChild("Kill")
	kill.Value = 0
	
	local wallet = player:WaitForChild("Wallet")
	local uang = wallet:WaitForChild("Uang")
	uang.Value = 500


	if player.Character then
		onCharacterAdded(player.Character)
	else
		player:LoadCharacter()
	end
end
Players.PlayerAdded:Connect(setupPlayer)

for _, p in ipairs(Players:GetPlayers()) do
	setupPlayer(p)
end

local function calculateZombieAmount(waveNumber)
	local alpha = 2
	local beta = 1.5
	local gamma = 3
	return math.floor(alpha * math.pow(waveNumber, beta)) + gamma
end

local ZOMBIE_TYPES = {
	{
		Name = "Slow",
		BaseHP = 100,
		BaseSpeed = 9,
		BaseDamage = 2,
		Scale = 1,      
		BaseWeight = 50,
		WeightGrowth = 0
	},
	{
		Name = "Normal",
		BaseHP = 100,
		BaseSpeed = 12,
		BaseDamage = 3,
		Scale = 1,      
		BaseWeight = 50, 
		WeightGrowth = 0
	},
	{
		Name = "Tank",
		BaseHP = 300,    
		BaseSpeed = 12,     
		BaseDamage = 5,   
		Scale = 1.65,       
		BaseWeight = 5, 
		WeightGrowth = 5
	},
	{
		Name = "Runner",
		BaseHP = 100,     
		BaseSpeed = 18,    
		BaseDamage = 6,
		Scale = 0.95,      
		BaseWeight = 5,
		WeightGrowth = 7
	},
	{
		Name = "Titan", 
		BaseHP = 700,    
		BaseSpeed = 15.5,    
		BaseDamage = 12,   
		Scale = 2.2,       
		BaseWeight = 0,      
		WeightGrowth = 0.5
	}
}

local function getRandomZombieType(wavenumber)
	local totalWeight = 0
	local currentWeights = {}

	for i, config in ipairs(ZOMBIE_TYPES) do
		local weightdinamis = config.BaseWeight + (wavenumber * config.WeightGrowth)

		weightdinamis = math.max(1, weightdinamis)

		currentWeights[i] = weightdinamis
		totalWeight += weightdinamis
	end

	local randomValue = math.random() * totalWeight 
	local cumulativeWeight = 0

	for i, config in ipairs(ZOMBIE_TYPES) do
		cumulativeWeight += currentWeights[i]
		if randomValue <= cumulativeWeight then
			return config
		end
	end

	return ZOMBIE_TYPES[1]
end

local function spawnZombie(waveNumber)
	local spawnPosition = nil
	local maxAttempts = 15 

	-- (Sistem pencarian platform)
	for i = 1, maxAttempts do
		local sudut = math.rad(math.random(0, 360))
		local jarak = math.random(safeRadiusValue.Value, spawnRadiusMax)
		local x = jarak * math.cos(sudut)
		local z = jarak * math.sin(sudut)

		local originY = base.Position.Y + 100
		local rayOrigin = Vector3.new(base.Position.X + x, originY, base.Position.Z + z)
		local rayDirection = Vector3.new(0, -200, 0) 
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude

		local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
		if raycastResult and raycastResult.Instance then
			spawnPosition = raycastResult.Position + Vector3.new(0, 3, 0)
			break 
		end
	end

	if not spawnPosition then return nil end

	-- jenis zombie
	local zombieConfig = getRandomZombieType(waveNumber)
	local newZombie = nil

	if zombieConfig.Name == "Slow" then
		newZombie = SlowZombieTemplate:Clone()
	elseif zombieConfig.Name == "Normal" then
		newZombie = zombieTemplate:Clone()
	elseif zombieConfig.Name == "Runner" then
		newZombie = FastZombieTemplate:Clone() 
	elseif zombieConfig.Name == "Tank" then
		newZombie = TankZombieTemplate:Clone() 
	elseif zombieConfig.Name == "Titan" then
		newZombie = TitanZombieTemplate:Clone() 
	end 
	newZombie.Name = zombieConfig.Name .. "Zombie"

	-- MODIFIKASI UKURAN & DAMAGE
	if zombieConfig.Scale ~= 1 then
		newZombie:ScaleTo(zombieConfig.Scale)
	end

	local rootPart = newZombie:WaitForChild("HumanoidRootPart")
	local aiScript = newZombie:FindFirstChild("ZombieAI") 
	if aiScript then
		aiScript.Enabled = false
	end

	local finalCFrame = CFrame.new(spawnPosition)
	local startCFrame = finalCFrame * CFrame.new(0, -4.5 * zombieConfig.Scale, 0)

	rootPart.CFrame = startCFrame
	rootPart.Anchored = true

	-- Persiapan Tween Animasi Naik
	local riseTweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local riseTween = TweenService:Create(rootPart, riseTweenInfo, {CFrame = finalCFrame})

	local humanoid = newZombie:FindFirstChild("Humanoid")

	if humanoid then
		-- SISTEM MUTASI WAVE
		local hpMutation = 50 + (waveNumber * 10.5)
		local damageMutation = 1 + (waveNumber * 0.1)
		local speedMutation = waveNumber * 0.1

		humanoid.MaxHealth = zombieConfig.BaseHP + hpMutation
		humanoid.Health = humanoid.MaxHealth 
	
		humanoid.WalkSpeed = zombieConfig.BaseSpeed + speedMutation
		newZombie:SetAttribute("CustomDamage", zombieConfig.BaseDamage + damageMutation)

		-- SISTEM KEMATIAN & JARING PENGAMAN
		humanoid.Died:Connect(function()
			dataSisaZombie.Value -= 1
			aliveZombies -= 1

			if aiScript and aiScript.Enabled == false then

				-- Hentikan animasi naik
				if riseTween then riseTween:Pause() end

				local JEDA_HILANG = 3
				local DURASI_FADE = 2

				Debris:AddItem(newZombie, JEDA_HILANG + DURASI_FADE + 1)

				for _, player in pairs(game.Players:GetPlayers()) do
					local leaderstats = player:FindFirstChild("leaderstats")
					local wallet = player:FindFirstChild("Wallet")
					if leaderstats and wallet then
						local uang = leaderstats:FindFirstChild("Uang")
						local kill = leaderstats:FindFirstChild("Kill")
						if uang and kill then
							uang.Value = uang.Value + 50 
							kill.Value = kill.Value + 1 
						end
					end
				end

				-- Putar Animasi Kematian
				local deathAnimObj = script:FindFirstChild("DeathAnim") or newZombie:FindFirstChild("DeathAnim", true)
				local animator = humanoid:FindFirstChildOfClass("Animator")

				if animator then
					for _, track in pairs(animator:GetPlayingAnimationTracks()) do
						track:Stop()
					end
					if deathAnimObj then
						local deathTrack = animator:LoadAnimation(deathAnimObj)
						deathTrack.Priority = Enum.AnimationPriority.Action
						deathTrack.Looped = false
						deathTrack:Play()

						local animDuration = deathTrack.Length > 0 and deathTrack.Length or 1.5

						task.delay(animDuration * 0.95, function()
							if deathTrack.IsPlaying then
								deathTrack:AdjustSpeed(0)
							end
						end)
					end
				end

				task.delay(JEDA_HILANG, function()
					if not newZombie or not newZombie.Parent then return end 

					local fadeTweenInfo = TweenInfo.new(DURASI_FADE, Enum.EasingStyle.Linear)
					for _, part in ipairs(newZombie:GetDescendants()) do
						if part:IsA("BasePart") or part:IsA("Decal") then
							TweenService:Create(part, fadeTweenInfo, {Transparency = 1}):Play()
						end
					end
				end)
			end
		end)
	end

	rootPart.CanTouch = false 

	newZombie:SetAttribute("IsSpawning", true) 

	newZombie.Parent = workspace

	riseTween:Play()

	task.spawn(function()
		riseTween.Completed:Wait() 

		if humanoid and humanoid.Health > 0 then

			rootPart.Anchored = false
			rootPart.CanTouch = true 

			newZombie:SetAttribute("IsSpawning", false) 

			if aiScript then
				aiScript.Enabled = true
			end
		end
	end)
	return newZombie
end

local function startWave(waveNumber)
	isWaveActive = true

	local totalZombies = calculateZombieAmount(waveNumber)
	dataSisaZombie.Value = totalZombies
	aliveZombies = totalZombies

	task.spawn(function()
		for i = 1, totalZombies, BATCH_SIZE do

			for j = 1, BATCH_SIZE do
				local currentIndex = (i - 1) + j

				if currentIndex <= totalZombies then
					task.spawn(function()
						spawnZombie(waveNumber)
					end)
				end
			end

			task.wait(BATCH_DELAY)
		end
	end)
end


task.spawn(function()
	gameStatus.Value = "MENUNGGU PEMAIN..."
	task.wait(5) 

	while not isGameOver do
		if currentWave > 0 then

			for i = INTERMISSION_TIME, 1, -1 do
				if isGameOver or ReplicatedStorage.SkipActive.Value == true then 
					break 
				end

				if baseHpValue.Value <= 0 then
					local baseStatus = game:GetService("ReplicatedStorage"):WaitForChild("BaseStatus")
					baseStatus.Value = "Hancur"
					
					gameStatus.Value = "BASE HANCUR! PREPARATION: " .. i .. "s"
				else
					gameStatus.Value = "PREPARATION: " .. i .. "s"
				end

				task.wait(1)
			end
		end

		if isGameOver then break end
		currentWave += 1 
		startWave(currentWave)

		repeat
			task.wait(0.5)

			if not isGameOver then
				if baseHpValue.Value <= 0 then
					baseHpValue.Value = 0
					gameStatus.Value = "Wave " .. currentWave .. " | BASE HANCUR!" 
					
					local baseStatus = game:GetService("ReplicatedStorage"):WaitForChild("BaseStatus")
					baseStatus.Value = "Hancur"
					
					local gameStatus = game:GetService("ReplicatedStorage"):WaitForChild("GameStatus")
					gameStatus.Value = "BASE HANCUR !"
				else
					gameStatus.Value = "WAVE " .. currentWave .. " has Started"
				end
			end

			if aliveZombies <= 0 then
				isWaveActive = false
			end

			if baseHpValue.Value <= 0 then
				checkGameOver()
			end

		until not isWaveActive or isGameOver
	end
end)
