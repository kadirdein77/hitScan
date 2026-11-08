--!native
--!optimize 2

--// Services
local replicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local players = game:GetService("Players")

--// Libs
local maid = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("modules"):WaitForChild("maid"))

--// Variables
local player = players.LocalPlayer
local camera = workspace.CurrentCamera
local velocityTemplate = replicatedStorage:WaitForChild("assets"):WaitForChild("slideAttachment")

local _maid = maid.new()
local humanoid
local root
local rayParams
local slideVelocity

local sprintHeld = false
local isSliding = false

local slideSpeed = 0
local slideDirection = Vector3.zero
local lastSlide = 0

local walkSpeed = 16
local sprintSpeed = 26
local baseFov = 70
local sprintFov = 82

local slideStart = 42
local slideMin = 14
local slideMax = 60
local slideFriction = 30
local airFriction = 8
local slopeGain = 60

--// Lib Decleration
local movementController = {}

--// Lib Private Functions
function getSlope(): number
	local result = workspace:Raycast(root.Position, Vector3.new(0, -5, 0), rayParams)

	if not result then
		return 0
	end

	return slideDirection:Dot(Vector3.new(result.Normal.X, 0, result.Normal.Z))
end

function stopSlide()
	isSliding = false
	slideSpeed = 0
	slideVelocity.Enabled = false
end

function startSlide()
	if slideSpeed > 0 or not sprintHeld or os.clock() - lastSlide < 0.8 then
		return
	end

	if humanoid.MoveDirection.Magnitude == 0 or humanoid.FloorMaterial == Enum.Material.Air then
		return
	end

	lastSlide = os.clock()
	isSliding = true
	slideSpeed = slideStart
	slideDirection = humanoid.MoveDirection.Unit
	slideVelocity.Enabled = true
end

function slide(deltaTime: number)
	local friction = airFriction
	local slope = 0

	if humanoid.FloorMaterial ~= Enum.Material.Air then
		friction = slideFriction
		slope = getSlope()
	end

	slideSpeed = math.min(slideSpeed + (slope * slopeGain - friction) * deltaTime, slideMax)

	if slideSpeed < slideMin then
		stopSlide()
		return
	end

	slideVelocity.PlaneVelocity = Vector2.new(slideDirection.X, slideDirection.Z) * slideSpeed
end

function update(deltaTime: number)
	local speed = walkSpeed
	local fov = baseFov
	local offset = Vector3.zero

	if sprintHeld and humanoid.MoveDirection.Magnitude > 0 then
		speed = sprintSpeed
		fov = sprintFov
	end

	if slideSpeed > 0 then
		speed = sprintSpeed
		fov = sprintFov
		slide(deltaTime)
	end

	if isSliding then
		offset = Vector3.new(0, -1.5, 0)
	end

	humanoid.WalkSpeed += (speed - humanoid.WalkSpeed) * 0.15
	camera.FieldOfView += (fov - camera.FieldOfView) * 0.1
	humanoid.CameraOffset = humanoid.CameraOffset:Lerp(offset, 0.2)
end

function onJumping(active: boolean)
	if not active or not isSliding then
		return
	end

	isSliding = false
	slideSpeed = math.min(slideSpeed * 1.15, slideMax)
end

function onInputBegan(input: InputObject, gameProcessed: boolean)
	if gameProcessed then
		return
	end

	local keyCode = input.KeyCode

	if keyCode == Enum.KeyCode.LeftShift then
		sprintHeld = true
		return
	end

	if keyCode ~= Enum.KeyCode.C and keyCode ~= Enum.KeyCode.LeftControl then
		return
	end

	startSlide()
end

function onInputEnded(input: InputObject)
	local keyCode = input.KeyCode

	if keyCode == Enum.KeyCode.LeftShift then
		sprintHeld = false
		return
	end

	if not isSliding then
		return
	end

	if keyCode ~= Enum.KeyCode.C and keyCode ~= Enum.KeyCode.LeftControl then
		return
	end

	stopSlide()
end

--// Lib Public Functions
function movementController.start()
	_maid:DoCleaning()

	local character = player.Character
	root = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")

	sprintHeld = false
	isSliding = false
	slideSpeed = 0

	rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = { character }

	local attachment = _maid:Add(velocityTemplate:Clone())
	slideVelocity = attachment.slideVelocity
	slideVelocity.MaxForce = math.huge
	attachment.Parent = root

	_maid:GiveTask(runService.Heartbeat:Connect(update))
	_maid:GiveTask(humanoid.Jumping:Connect(onJumping))
	_maid:GiveTask(userInputService.InputBegan:Connect(onInputBegan))
	_maid:GiveTask(userInputService.InputEnded:Connect(onInputEnded))
end

function movementController.stop()
	sprintHeld = false
	isSliding = false
	slideSpeed = 0

	_maid:DoCleaning()
	camera.FieldOfView = baseFov
end

return movementController
