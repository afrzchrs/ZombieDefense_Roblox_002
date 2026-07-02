local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris") 

local placeLandmineEvent = ReplicatedStorage:WaitForChild("PlaceLandmine")
local landmineTemplate = ServerStorage:WaitForChild("Landmine")

local MINE_DAMAGE = 90
local KNOCKBACK_FORCE = 80
local HARGA_LANDMINE = 50 

placeLandmineEvent.OnServerEvent:Connect(function(player)
	local Wallet = player:FindFirstChild("Wallet")
	local uang = Wallet and Wallet:FindFirstChild("Uang")

	if not uang then
		warn("Peringatan: Sistem uang tidak ditemukan pada player " .. player.Name)
		return
	end

	if uang.Value < HARGA_LANDMINE then
		return 
	end

	uang.Value -= HARGA_LANDMINE

	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end

	local rootPart = character.HumanoidRootPart

	local newMine = landmineTemplate:Clone()
	newMine:PivotTo(rootPart.CFrame * CFrame.new(0, -3, 0)) 
	newMine.Parent = workspace

	local exploded = false

	local sensor = newMine:FindFirstChild("SensorArea")

	if sensor then
		sensor.Touched:Connect(function(hit)
			if exploded then return end

			local hitCharacter = hit.Parent
			local humanoid = hitCharacter:FindFirstChild("Humanoid")
			local hitRootPart = hitCharacter:FindFirstChild("HumanoidRootPart")

			-- Jika yang menyentuh area adalah Zombie
			if humanoid and humanoid.Health > 0 then
				local isPlayer = Players:GetPlayerFromCharacter(hitCharacter)

				if not isPlayer then
					exploded = true 
					local fxPart = Instance.new("Part")
					fxPart.Transparency = 1
					fxPart.Anchored = true
					fxPart.CanCollide = false
					fxPart.Position = sensor.Position 
					fxPart.Parent = workspace

					local explosion = Instance.new("Explosion")
					explosion.Position = fxPart.Position
					explosion.BlastRadius = 12 
					explosion.BlastPressure = 0 
					explosion.DestroyJointRadiusPercent = 0 
					explosion.Parent = workspace

					local sumberSuara = sensor:FindFirstChild("Mine explosion")

					if sumberSuara then
						local soundFX = sumberSuara:Clone()
						soundFX.Parent = fxPart 
						soundFX:Play()
					else
						warn("Error: Suara 'Mine explosion' tidak ditemukan di SensorArea!")
					end

					Debris:AddItem(fxPart, 3)

					humanoid:TakeDamage(MINE_DAMAGE)

					if hitRootPart then 
						local zPos = hitRootPart.Position
						local mPos = sensor.Position

						local flatZombiePos = Vector3.new(zPos.X, 0, zPos.Z)
						local flatMinePos = Vector3.new(mPos.X, 0, mPos.Z)

						local directionVector = flatZombiePos - flatMinePos
						local knockbackDirection

						if directionVector.Magnitude < 0.1 then
							knockbackDirection = Vector3.new(math.random(-10,10), 0, math.random(-10,10)).Unit
						else
							knockbackDirection = directionVector.Unit
						end

						local HORIZONTAL_FORCE = 50 
						local UPWARD_FORCE = 40      

						local finalForce = (knockbackDirection * HORIZONTAL_FORCE) + Vector3.new(0, UPWARD_FORCE, 0)

						humanoid.PlatformStand = true
						task.delay(1, function() 
							if humanoid and humanoid.Health > 0 then
								humanoid.PlatformStand = false
							end
						end)

						hitRootPart.AssemblyLinearVelocity = finalForce
					end

					newMine:Destroy()
				end
			end
		end)
	else
		warn("PERINGATAN: Landmine tidak memiliki Part bernama 'SensorArea' di dalamnya!")
	end
end)