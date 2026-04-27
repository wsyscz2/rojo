if not plugin then
	return
end

local Rojo = script:FindFirstAncestor("Rojo")
local Packages = Rojo.Packages

local function requirePackage(name: string)
	local child = Packages:FindFirstChild(name)
	if child == nil then
		error(
			('[Rojo Plugin] Missing Packages.%s (git submodule not checked out). '
				.. 'From the repo root run: git submodule update --init --recursive '
				.. 'then rebuild: rojo build plugin.project.json --plugin Rojo.rbxm'):format(name),
			2
		)
	end
	return require(child)
end

local Log = requirePackage("Log")
local Roact = requirePackage("Roact")

local Settings = require(script.Settings)
local Config = require(script.Config)
local App = require(script.App)

-- DEBUG: 确认 Studio 加载的是本仓库构建的插件；验证后在 init.server.lua 删掉本段
print(
	string.format(
		"[Rojo Plugin DEBUG] loaded | marker=encodedvalue-int64-msgpack | version=%d.%d.%d%s | devBuild=%s",
		Config.version[1],
		Config.version[2],
		Config.version[3],
		Config.version[4] or "",
		tostring(Config.isDevBuild)
	)
)

Log.setLogLevelThunk(function()
	return Log.Level[Settings:get("logLevel")] or Log.Level.Info
end)

local app = Roact.createElement(App, {
	plugin = plugin,
})
local tree = Roact.mount(app, game:GetService("CoreGui"), "Rojo UI")

plugin.Unloading:Connect(function()
	Roact.unmount(tree)
end)

if Config.isDevBuild then
	local TestEZ = require(script.Parent.TestEZ)

	require(script.runTests)(TestEZ)
end
