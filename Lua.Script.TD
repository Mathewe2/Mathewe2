local wavedata = require(game.ReplicatedStorage.NormalWaves)
local global_ticker = tick()
local original_timer = 30
local wave_db = false
local skipping_players = {}
local quotes = require(game.ReplicatedStorage["Misc Data"].Quotes)
local ended = false



local function end_game(result)
	if ended == true then return end
	ended = true
	if result == "win" then
		game.ReplicatedStorage.Remotes.Game_End:FireAllClients(" Victory!", Color3.new(0, 1, 0.498039), quotes.Win[math.random(#quotes.Win)])
	else
		game.ReplicatedStorage.Remotes.Game_End:FireAllClients(" Defeated.", Color3.new(1, 0, 0), quotes.Loss[math.random(#quotes.Loss)])
	end
end



workspace.Base.WaveNumber.Changed:Connect(function()
	skipping_players = {}
	workspace.Base.SkipCount.Value = 0
	global_ticker = tick()
	local wave_number = workspace.Base.WaveNumber.Value
	if wave_number == 0 then workspace.Base.Timer.Value = 30 original_timer = 30
	else
		workspace.Base.Anti_AutoSkip_Counter.Value += 1
		if wavedata[wave_number] ~= nil then
			if wavedata[wave_number + 1] == nil then
				workspace.Base.CanSkip.Value = false
				workspace.Base.Timer.Value = 5999
				original_timer = 5999
			else
				workspace.Base.Timer.Value = wavedata[wave_number].Duration
				original_timer = wavedata[wave_number].Duration
			end
			for _, v in pairs(wavedata[wave_number].Enemies) do
				for x = 1, v[2] do
					if v[3] == "all" then
						for _, route in pairs(workspace.Checkpoints:GetChildren()) do
							game.ServerScriptService.Events.Spawn_Enemy:Fire(v[1], route.Name)
						end
					elseif v[3] == "random" then
						local routes = workspace.Checkpoints:GetChildren()
						game.ServerScriptService.Events.Spawn_Enemy:Fire(v[1], routes[math.random(#routes)].Name)
					else
						game.ServerScriptService.Events.Spawn_Enemy:Fire(v[1], v[3])
					end
					wait(1)
				end
			end
			workspace.Base.Anti_AutoSkip_Counter.Value -= 1
		else
			if workspace.Base.HP.Value <= 0 then
				end_game("loss")
			else
				end_game("win")	
			end
		end
	end
end)



workspace.Base.HP.Changed:Connect(function()
	if workspace.Base.HP.Value <= 0 then
		end_game("loss")
	end
end)



game:GetService("RunService").Heartbeat:Connect(function()
	if workspace.Base.Timer.Value > 0 then
		workspace.Base.Timer.Value = original_timer - math.floor(tick() - global_ticker)
	else
		if wave_db == false then
			wave_db = true
			wait(1)
			workspace.Base.WaveNumber.Value += 1
			wave_db = false
		end
	end
	if workspace.Base.WaveNumber.Value > 0 and #workspace.Enemies:GetChildren() == 0 and workspace.Base.Anti_AutoSkip_Counter.Value == 0 or workspace.Base.SkipCount.Value >= math.floor((#game.Players:GetChildren())/3 + 1) then
		workspace.Base.Timer.Value = 0
	end
end)



game.ReplicatedStorage.Remotes.RequestSkip.OnServerEvent:Connect(function(plr)
	if workspace.Base.Timer.Value == 0 or (tick() - global_ticker) < 15 or workspace.Base.CanSkip.Value == false then return end
	for _, v in pairs(skipping_players) do
		if v == plr then return end
	end
	skipping_players[#skipping_players + 1] = plr
	workspace.Base.SkipCount.Value += 1
end)
