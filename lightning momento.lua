--"pain." -hunter, 2/26/21, 11:18PM(EST)
wait(1)
local replicated = game:GetService("ReplicatedStorage")
local remote = replicated:WaitForChild("Logic"):WaitForChild("lightning")

local part = Instance.new("Part")
part.Size = Vector3.new(.2,.2,.2)
part.BrickColor = BrickColor.new("Persimmon") -- maybe lapis?, or persimmon for the fog
part.CanCollide = false
part.Anchored = true
part.Material = "Neon"

local function shoot(from,too)
	local lastpos = from
	local step = 2
	local off = 2
	local range = 100
	local distance = (from - too).magnitude
	
	if distance > range then distance = range end
	for i = 0,distance, step do
		local from = lastpos
		local offset = Vector3.new(
			math.random(-off,off),
			math.random(-off,off),
			math.random(-off,off)
		)/10
		local too = from +- (from - too).unit * step + offset
		local p = part:Clone()
		local debris = workspace:FindFirstChild("debris") Instance.new("Folder",workspace)
		debris.Name = "debris"
		p.Parent = debris
		p.Size = Vector3.new(p.Size.x,p.Size.y,(from - too).magnitude)
		p.CFrame = CFrame.new(from:Lerp(too,.5),too)
		game.Debris:AddItem(p,.1)
		lastpos = too
	end
end

local function scale(Part)
	local ts = game:GetService("TweenService")
	local ti = TweenInfo.new(
		.2,
		Enum.EasingStyle.Linear,
		Enum.EasingStyle.Out,
		0,
		false,
		0
	)
	local properties = {
		size = Vector3.new(2.901,2.722,35)
	}
	local tween = ts:Create(Part,ti,properties)
	tween:Play()
end

remote.OnServerEvent:Connect(function(Player,Aim,MousePos)
	local char = Player.Character
	local root = char:WaitForChild("HumanoidRootPart")
	local hand = char:WaitForChild("RightHand")
	local humanoid = char:WaitForChild("Humanoid")
	
	if Aim then
		local debris = workspace:FindFirstChild("debris") or Instance.new("Folder",workspace)
		debris.Name = "debris"
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://6450371953"
		local loadAnim = char.Humanoid:LoadAnimation(anim)
		loadAnim:Play()
		local clap = workspace:WaitForChild(Player.Name).UpperTorso.clap
		clap:Play()
		local particle = workspace:WaitForChild(Player.Name).UpperTorso.lightning
		particle.Enabled = true
		wait(.3)
		particle.Enabled = false
		local bodpos = Instance.new("BodyPosition")
		bodpos.MaxForce = Vector3.new(5000000,5000000,5000000)
		bodpos.P = 50000
		bodpos.Position = root.Position
		bodpos.Parent = root
		
		spawn(function()
			wait(3)
			bodpos:Destroy()
		end)
		local YCFrame = root.Position.Y - humanoid.HipHeight
		local charparts = char:GetChildren()
		
		math.randomseed(tick())
		spawn(function()
			for i = 1,#charparts do
				local current = charparts[i]
				if current.ClassName == "Part" or current.ClassName == "MeshPart" then
					shoot(Vector3.new(root.Position.X - math.random(-5,5), YCFrame,root.Position.Z - math.random(-5,5)), current.Position)
					shoot(Vector3.new(root.Position.X - math.random(-5,5), YCFrame,root.Position.Z - math.random(-5,5)), current.Position)
					wait()
				end
			end
		end)
		
	else
		local debris = workspace:FindFirstChild("debris") or Instance.new("Folder",workspace)
		debris.Name = "debris"
		local hitbox = Instance.new("Part")
		hitbox.Anchored = false
		hitbox.Transparency = 1
		hitbox.CanCollide = false
		hitbox.BrickColor = BrickColor.new("Copper")
		hitbox.Size = Vector3.new(5,5,5)
		hitbox.Parent = debris
		
		spawn(function()
			local repeatnum = 22
			for i = 1,repeatnum do
				shoot(hand.Position,MousePos.Position)
				shoot(hand.Position,MousePos.Position)
				wait()
			end
			hitbox:Destroy()
		end)
		local mag = (hand.Position - MousePos.Position).magnitude
		if mag > 100 then
			mag = 100
		end
		hitbox.Size = Vector3.new(5,5,mag)
		hitbox.Position = hand.Position
		hitbox.CFrame = CFrame.new(hand.Position,MousePos.Position)
		hitbox.CFrame = hitbox.CFrame * CFrame.new(0,0,-mag/2)
		
		spawn(function()
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://821439273"
			sound.Parent = root
			sound.PlaybackSpeed = .8
			sound.MaxDistance = 300
			sound.Volume = 4
			sound:Play()
			wait(5)
			sound:Destroy()
		end)
		
		local hitppl = {}
		
		wait(.05)
		hitbox.Touched:Connect(function(hit)
			if not hit.Parent:FindFirstChild("Humanoid") then return end
			if hit.Parent.Name ~= char.Name then
				local newChar = hit.Parent
				if hitppl[Player.Name] then return end
				hitppl[char.Name] = true
				
				local bodpos = Instance.new("BodyPosition")
				bodpos.MaxForce = Vector3.new(5000000,5000000,5000000)
				bodpos.P = 50000
				bodpos.Position = newChar:FindFirstChild("HumanoidRootPart").Position
				bodpos.Parent = newChar:FindFirstChild("HumanoidRootPart")
				newChar:FindFirstChild("Humanoid"):TakeDamage(250)
				wait(.1)
				
				if hit.Parent:FindFirstChild("Humanoid").Health <= 0 then
					game.Debris:AddItem(bodpos,.1)
				else
					game.Debris:AddItem(bodpos,2)
				end
			end
		end)
	end
	
end)
