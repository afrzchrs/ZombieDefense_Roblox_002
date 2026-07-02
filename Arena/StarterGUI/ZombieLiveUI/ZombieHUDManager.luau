local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sisaZombie = ReplicatedStorage:WaitForChild("SisaZombie")


local wadahUI = script.Parent
local zombieText = wadahUI:WaitForChild("ImageLabel"):WaitForChild("ZombieText")

local function updateZombieUI()
	zombieText.Text = tostring(sisaZombie.Value)
end


updateZombieUI()


sisaZombie:GetPropertyChangedSignal("Value"):Connect(updateZombieUI)