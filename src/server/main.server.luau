--!optimize 2
--!native

--// Services
local replicatedStorage = game:GetService("ReplicatedStorage")
local serverScriptService = game:GetService("ServerScriptService")
local players = game:GetService("Players")

--// Libs
local hitScanService = require(serverScriptService.Server.services.hitScanService)

--// Variables
local shootEvent = replicatedStorage:WaitForChild("remotes"):WaitForChild("shoot")

shootEvent.OnServerEvent:Connect(hitScanService.shoot)
players.PlayerRemoving:Connect(hitScanService.removePlayer)
