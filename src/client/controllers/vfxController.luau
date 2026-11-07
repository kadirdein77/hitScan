--!native
--!optimize 2

--// Services
local replicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local debris = game:GetService("Debris")

--// Variables
local hitFlashTemplate = replicatedStorage:WaitForChild("assets"):WaitForChild("hitFlash")
local hitEffectEvent = replicatedStorage:WaitForChild("remotes"):WaitForChild("hitEffect")

local flashDuration = 0.5
local flashTweenInfo = TweenInfo.new(flashDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local flashGoal = { FillTransparency = 1, OutlineTransparency = 1 }

--// Lib Public Functions
function play(character: Model)
	if not character or not character.Parent then
		return
	end

	local highlight = hitFlashTemplate:Clone()
	highlight.Adornee = character
	highlight.Parent = character

	tweenService:Create(highlight, flashTweenInfo, flashGoal):Play()
	debris:AddItem(highlight, flashDuration)
end

--// Lib Decleration
hitEffectEvent.OnClientEvent:Connect(play)

return {
	play = play,
}
