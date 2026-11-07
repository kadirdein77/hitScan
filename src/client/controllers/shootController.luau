--!native
--!optimize 2

--// Services
local replicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

--// Libs
local maid = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("modules"):WaitForChild("maid"))
local weaponConfig = require(replicatedStorage.Shared.config.weaponConfig)
local viewModelController = require(script.Parent.viewModelController)

--// Variables
local camera = workspace.CurrentCamera
local shootEvent = replicatedStorage:WaitForChild("remotes"):WaitForChild("shoot")

local _maid = maid.new()
local currentWeapon = "rifle"

local isHolding = false
local lastShotTime = 0

--// Lib Decleration
local shootController = {}

--// Lib Public Functions
function shootController.shoot()
	local config = weaponConfig[currentWeapon]
	local currentTime = os.clock()

	if currentTime - lastShotTime < config.fireRate then
		return
	end

	lastShotTime = currentTime
	shootEvent:FireServer(currentWeapon, camera.CFrame.Position, camera.CFrame.LookVector)

	viewModelController.recoil()
end

function shootController.update()
	if not isHolding then
		return
	end

	shootController.shoot()
end

function shootController.onInputBegan(input: InputObject, gameProcessed: boolean)
	if gameProcessed then
		return
	end

	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
		return
	end

	isHolding = true
end

function shootController.onInputEnded(input: InputObject)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
		return
	end

	isHolding = false
end

function shootController.start()
	_maid:DoCleaning()

	isHolding = false

	_maid:GiveTask(userInputService.InputBegan:Connect(shootController.onInputBegan))
	_maid:GiveTask(userInputService.InputEnded:Connect(shootController.onInputEnded))
	_maid:GiveTask(runService.Heartbeat:Connect(shootController.update))
end

function shootController.stop()
	isHolding = false
	_maid:DoCleaning()
end

return shootController
