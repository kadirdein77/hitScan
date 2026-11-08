--!native
--!optimize 2

--// Services
local replicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

--// Libs
local maid = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("modules"):WaitForChild("maid"))
local spr = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("modules"):WaitForChild("spr"))

--// Variables
local camera = workspace.CurrentCamera

local _maid = maid.new()
local viewModel
local posValue
local rotValue

local swayCF = CFrame.new()

local posDamping = 1
local posFrequency = 6
local rotDamping = 1
local rotFrequency = 5

local maxPos = 0.8
local maxRot = math.rad(6)

--// Lib Decleration
local viewModelController = {}

--// Lib Public Functions
function viewModelController.kick(
	value: Vector3Value,
	offset: Vector3,
	limit: number,
	damping: number,
	frequency: number
)
	local targetValue = value.Value + offset

	if targetValue.Magnitude > limit then
		targetValue = targetValue.Unit * limit
	end

	spr.stop(value)
	value.Value = targetValue
	spr.target(value, damping, frequency, { Value = Vector3.zero })
end

function viewModelController.update()
	local mouseDelta = userInputService:GetMouseDelta() / 50
	local swayX = math.clamp(mouseDelta.X, -0.2, 0.2)
	local swayY = math.clamp(mouseDelta.Y, -0.2, 0.2)

	swayCF = swayCF:Lerp(CFrame.new(swayX, swayY, 0), 0.3)

	local rotation = rotValue.Value
	local recoilCF = CFrame.new(posValue.Value) * CFrame.Angles(rotation.X, rotation.Y, rotation.Z)

	viewModel:PivotTo(camera.CFrame * swayCF * recoilCF)
end

function viewModelController.stopSprings()
	spr.stop(posValue)
	spr.stop(rotValue)
end

function viewModelController.recoil()
	local sideOffset = math.random(-10, 10) / 100

	viewModelController.kick(posValue, Vector3.new(sideOffset * 0.2, 0.01, 0.45), maxPos, posDamping, posFrequency)

	viewModelController.kick(
		rotValue,
		Vector3.new(math.rad(0.4), math.rad(sideOffset * 2), math.rad(sideOffset * 3)),
		maxRot,
		rotDamping,
		rotFrequency
	)
end

function viewModelController.start()
	_maid:DoCleaning()

	swayCF = CFrame.new()

	posValue = _maid:Add(Instance.new("Vector3Value"))
	rotValue = _maid:Add(Instance.new("Vector3Value"))
	_maid:GiveTask(viewModelController.stopSprings)

	viewModel = _maid:Add(replicatedStorage.assets.viewModel:Clone())
	viewModel.Parent = camera

	_maid:GiveTask(runService.RenderStepped:Connect(viewModelController.update))
end

function viewModelController.stop()
	_maid:DoCleaning()
end

return viewModelController
