local SoundService = game:GetService("SoundService")


local bgm1 = SoundService:WaitForChild("BGM1")
local bgm2 = SoundService:WaitForChild("BGM2")


bgm1.Volume = 0.4
bgm2.Volume = 0.4


bgm1.Looped = false
bgm2.Looped = false

local function putarPlaylist()

	while true do


		if not bgm1.IsLoaded then 
			bgm1.Loaded:Wait() 
		end
		bgm1:Play()
		bgm1.Ended:Wait()


		if not bgm2.IsLoaded then 
			bgm2.Loaded:Wait() 
		end
		bgm2:Play()
		bgm2.Ended:Wait() 


	end
end


task.spawn(putarPlaylist)