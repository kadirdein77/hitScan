--!optimize 2
--!native

--// Lib Services
local replicatedStorage = game:GetService("ReplicatedStorage")
local serverScriptService = game:GetService("ServerScriptService")
local players = game:GetService("Players")

--// Lib Modules
local hitScanService = require(serverScriptService.Server.services.hitScanService)

--// Lib Variables
local shootEvent = replicatedStorage:WaitForChild("remotes"):WaitForChild("shoot")

shootEvent.OnServerEvent:Connect(hitScanService.shoot)
players.PlayerRemoving:Connect(hitScanService.removePlayer)
