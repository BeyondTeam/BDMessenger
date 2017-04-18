package.path = package.path..';.luarocks/share/lua/5.2/?.lua;.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath..';.luarocks/lib/lua/5.2/?.so'
    bot_token = "Token" --Put You Token Here
   send_api = "https://api.telegram.org/bot"..bot_token
sudo_id = 157059515
require('./bot/methods')
http = require('socket.http')
https = require('ssl.https')
url = require('socket.url')
redis = (loadfile "./libs/redis.lua")()
JSON = (loadfile "./libs/dkjson.lua")()
serpent = (loadfile "./libs/serpent.lua")()
function bot_run()
	bot = nil
	while not bot do
		bot = send_req(send_api.."/getMe")
	end
	bot = bot.result
	local runlog = bot.first_name.." [@"..bot.username.."]\nis run in: "..os.date("%F - %H:%M:%S")
	print(runlog)
	send_msg(sudo_id, runlog)
	last_update = last_update or 0
	last_cron = last_cron or os.time()
	startbot = true
end

function send_req(url)
	local dat, res = https.request(url)
	local tab = JSON.decode(dat)
	if res ~= 200 then return false end
	if not tab.ok then return false end
	return tab
end

function bot_updates(offset)
	local url = send_api.."/getUpdates?timeout=10"
	if offset then
		url = url.."&offset="..offset
	end
	return send_req(url)
end

function load_data(filename)
	local f = io.open(filename)
	if not f then
		return {}
	end
	local s = f:read('*all')
	f:close()
	local data = JSON.decode(s)
	return data
end

function save_data(filename, data)
	local s = JSON.encode(data)
	local f = io.open(filename, 'w')
	f:write(s)
	f:close()
end

function msg_valid(msg)
	local msg_time = os.time() - 20
	if msg.date < tonumber(msg_time) then
		print('\27[36m》》OLD MESSAGE《《\27[39m')
		return false
	end
    return true
end

-- Returns a table with matches or nil
function match_pattern(pattern, text, lower_case)
  if text then
    local matches = {}
    if lower_case then
      matches = { string.match(text:lower(), pattern) }
    else
      matches = { string.match(text, pattern) }
    end
      if next(matches) then
        return matches
      end
  end
  -- nil
end
  plugins = {}
function match_plugins(msg)
  for name, plugin in pairs(plugins) do
    match_plugin(plugin, name, msg)
  end
end

function match_plugin(plugin, plugin_name, msg)

  -- Go over patterns. If one matches it's enough.
if plugin.pre_process then
        --If plugin is for privileged users only
		local result = plugin.pre_process(msg)
		if result then
			print("pre process: ", plugin_name)
		end
	end
  for k, pattern in pairs(plugin.patterns) do
    local matches = match_pattern(pattern, msg.text)
    if matches then
      print("msg matches: ", pattern)
      -- Function exists
      if plugin.run then
        -- If plugin is for privileged users only
          local result = plugin.run(msg, matches)
          if result then
            send_msg(msg.chat.id, result, 'markdown', msg.message_id)
        end
      end
      -- One patterns matches
      return
    end
  end
end

-- Save the content of _config to config.lua
function save_config( )
  serialize_to_file(_config, './data/config.lua')
  print ('saved config into ./data/config.lua')
end

-- Create a basic config.json file and saves it.
function create_config( )
  -- A simple config with basic plugins and ourselves as privileged user
  config = {
    enabled_plugins = {
    "core"
    },
    sudo_users = {157059515},--Sudo users
    info_text = [[*》Beyond Messenger V1.0*
`》An messenger bot based on plugin`

》[Beyond Messenger](https://github.com/BeyondTeam/BDMessenger)

*》Admins :*
*》Founder & Developer :* [SoLiD](Telegram.Me/SoLiD)
_》Developer & Sponser :_ [MAKAN](Telegram.Me/MAKAN)
_》Developer :_ [ToOfan](Telegram.Me/ToOfan)
_》Developer :_ [Ehsan](Telegram.Me/CliFather)

*》Special thanks to :*
》[MrHalix](Telegram.Me/MrHalix)
`And Beyond Team Members`

*》Our channel :*
》[BeyondTeam](Telegram.Me/BeyondTeam)

*》Our Site :*
[BeyondTeam](BeyondTeam.ir)
]],
  }
  serialize_to_file(config, './data/config.lua')
  print('saved config into ./data/config.lua')
end

-- Returns the config from config.lua file.
-- If file doesn't exist, create it.
function load_config( )
  local f = io.open('./data/config.lua', "r")
  -- If config.lua doesn't exist
  if not f then
    print ("Created new config file: data/config.lua")
    create_config()
  else
    f:close()
  end
  local config = loadfile ("./data/config.lua")()
  for v,user in pairs(config.sudo_users) do
    print("Sudo user: " .. user)
  end
  return config
end
_config = load_config( )

-- Enable plugins in config.json
function load_plugins()
  for k, v in pairs(_config.enabled_plugins) do
    print("Loading plugin", v)

    local ok, err =  pcall(function()
      local t = loadfile("plugins/"..v..'.lua')()
      plugins[v] = t
    end)

    if not ok then
      print('\27[31mError loading plugin '..v..'\27[39m')
	  print(tostring(io.popen("lua plugins/"..v..".lua"):read('*all')))
      print('\27[31m'..err..'\27[39m')
    end

  end
end

bot_run()
load_plugins()
while startbot do
	local res = bot_updates(last_update+1)
	if res then
		for i,v in ipairs(res.result) do
			last_update = v.update_id
			if v.edited_message then
          if msg_valid(v.edited_message) then
				match_plugins(v.edited_message)
           end
			elseif v.message then
          if msg_valid(v.message) then
				match_plugins(v.message)
          end
			end
		end
	else
		print("error while")
	end
	if last_cron < os.time() - 30 then
  for name, plugin in pairs(plugins) do
		if plugin.cron then
			local res, err = pcall(
				function()
					plugin.cron()
				end
        
			)
      end
			if not res then print('error: '..err) end
		end
		last_cron = os.time()
	end
end
