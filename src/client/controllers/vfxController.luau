--!native
--!optimize 2

--// Services
local replicatedStorage = game:GetService("ReplicatedStorage")

--// Libs
local spr = require(replicatedStorage.Shared.modules.spr)

--// Variables
local hitFlashTemplate = replicatedStorage:WaitForChild("assets"):WaitForChild("hitFlash")
local hitEffectEvent = replicatedStorage:WaitForChild("remotes"):WaitForChild("hitEffect")

local startTransparency = 0.2
local flashDamping = 1
local flashFrequency = 5
local flashDuration = 1

local flashGoal = { FillTransparency = 1, OutlineTransparency = 1 }

--// Lib Private Functions
function play(character: Model)
	if not character or not character.Parent then
		return
	end

	local highlight = hitFlashTemplate:Clone()
	highlight.FillTransparency = startTransparency
	highlight.OutlineTransparency = startTransparency
	highlight.Adornee = character
	highlight.Parent = character

	spr.target(highlight, flashDamping, flashFrequency, flashGoal)
	task.delay(flashDuration, highlight.Destroy, highlight)
end

--// Lib Decleration
hitEffectEvent.OnClientEvent:Connect(play)

return {
	play = play,
}
