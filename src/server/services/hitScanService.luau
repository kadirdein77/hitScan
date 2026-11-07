--!native
--!optimize 2

--// Services
local replicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local weaponConfig = require(replicatedStorage.Shared.config.weaponConfig)

--// Types
type weaponData = {
	damage: number,
	range: number,
	fireRate: number,
}

--// Variables
local maxOriginOffset = 10
local lastShotTimes = {}

--// Lib Private Functions
function isValidShot(player: Player, config: weaponData, origin: any, direction: any): boolean
	if typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3" then
		return false
	end

	if direction.Magnitude < 0.01 then
		return false
	end

	local currentTime = os.clock()
	local lastShotTime = lastShotTimes[player]

	if lastShotTime and currentTime - lastShotTime < config.fireRate then
		return false
	end

	local character = player.Character
	local characterHead = character and character:FindFirstChild("Head")

	if not characterHead then
		return false
	end

	if (origin - characterHead.Position).Magnitude > maxOriginOffset then
		return false
	end

	lastShotTimes[player] = currentTime

	return true
end

function castRay(player: Player, origin: Vector3, direction: Vector3, range: number): RaycastResult?
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { player.Character }

	return workspace:Raycast(origin, direction.Unit * range, raycastParams)
end

function applyDamage(raycastResult: RaycastResult, damage: number)
	local hitModel = raycastResult.Instance:FindFirstAncestorOfClass("Model")
	local hitHumanoid = hitModel and hitModel:FindFirstChildOfClass("Humanoid")

	if not hitHumanoid then
		return
	end

	hitHumanoid:TakeDamage(damage)
end

--// Lib Decleration
local hitScanService = {}

--// Lib Public Functions
function hitScanService.shoot(player: Player, weaponName: any, origin: any, direction: any)
	local config = type(weaponName) == "string" and weaponConfig[weaponName]

	if not config then
		return
	end

	if not isValidShot(player, config, origin, direction) then
		return
	end

	local raycastResult = castRay(player, origin, direction, config.range)

	if not raycastResult then
		return
	end

	applyDamage(raycastResult, config.damage)
end

function hitScanService.removePlayer(player: Player)
	lastShotTimes[player] = nil
end

return hitScanService
