--// Services
local players = game:GetService("Players")

--// Libs
local viewModelController = require(script.Parent.controllers.viewModelController)
local shootController = require(script.Parent.controllers.shootController)
local vfxController = require(script.Parent.controllers.vfxController)
local movementController = require(script.Parent.controllers.movementController)

--// Variables
local player = players.LocalPlayer

player.CameraMode = Enum.CameraMode.LockFirstPerson

--// Lib Private Functions
function setupCharacter()
	viewModelController.start()
	shootController.start()
	movementController.start()
end

function cleanCharacter()
	viewModelController.stop()
	shootController.stop()
	movementController.stop()
end

--// Connections
player.CharacterAdded:Connect(setupCharacter)
player.CharacterRemoving:Connect(cleanCharacter)

if not player.Character then
	return
end

setupCharacter()
