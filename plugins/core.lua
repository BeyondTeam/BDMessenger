local help_text = [[
*Beyond Messeger Bot Commands :*

*/id*
_Show Your And Chat ID_

*/id [reply]*
_Show User ID_

*/init* 
_Reload Bot_

*/blocklist*
_show Blocked Users List_

*/sudolist*
_Sudo(s) list_

*/clean blocklist*
_Clean Block List_

*/users*
_Number Of Users_

*/setstart* `[text]`
_Set Start Message_

*/setsent* `[text]`
_Set Send Message_

*/setprofiletext* `[text]`
_Set Your Profile Text_

*/block* `[reply|id]`
_Add User To Block List_

*/unblock* `[reply|id]`
_Remove User From Block List_

*/setsudo* `[reply|id]`
_Add User To Sudo Users_

*/remsudo* `[reply|id]`
_Remove User From Sudo Users_

*/setrealm*
_Set A New Realm_

*/antiflood on*
_Enable Flood Protection_

*/antiflood off*
_Disable Flood Protection_

*/autoleave on*
_Enable Auto Leave_

*/autoleave off*
_Disable Auto Leave_

*/setpvflood*
_Set The Maximun Messages In A FloodTime To Be Considered As flood_

*/setpvfloodtime*
_Set The Time That Bot Uses To Check flood_

*/beyond*
_Show About Bot_

*/sendtoall* `[text]`
_Send A Message To All User_

*/fwdtoall* `[reply]`
_Forward A Message To All User_

[Beyond Team Channel](Telegram.Me/BeyondTeam)
_Good Luck_ *:D*

]]

local mem_help = [[
*Welcome To Beyond Messenger Bot :*

*/id*
_Show Your And Chat ID_

*/beyond*
_Show About Bot_

[Beyond Team Channel](Telegram.Me/BeyondTeam)
_Good Luck_ *:D*

]]

local profile_text = [[
@BeyondTeam
]]

local sudo_keyboard = {{"🚦 اطلاعات چت","🎯 اعضای تیم"},{"🔖 راهنما","👥 لیست کاربران"},{"🚷 لیست سیاه","👤 لیست سودو ها"},{"✅ پاک کردن لیست سیاه","🔁 بارگذاری مجدد"}}
local keyboard = {{"📬 پروفایل"},{"🌟 کانال ما","🎯 اعضای تیم"},{"🔖 راهنما","🚦 اطلاعات چت"}}

local function getindex(t,id) 
	for i,v in pairs(t) do 
		if v == id then 
			return i 
		end 
	end 
	return nil 
end 

local function reload_plugins( ) 
	plugins = {} 
	load_plugins() 
end

--By @SoLiD021
local function already_sudo(user_id)
	for k,v in pairs(_config.sudo_users) do
		if user_id == v then
			return k
		end
	end
	-- If not found
	return false
end

--By @SoLiD
local function sudolist(msg)
	local list = _config.sudo_users
	local text = "*Sudo Users :*\n"
	local inline = {}
	local page = 1
	if #list < 11 then
		for i=1,#list do
			local user = send_req(send_api.."/getChat?chat_id="..list[i])
			if user and user.result.username then
				table.insert(inline,{{text=list[i],url="t.me/"..user.result.username},{text="Rem Sudo",callback_data="RemSudo:"..list[i]}})
			else
				table.insert(inline,{{text=list[i],callback_data="nousername"},{text="Rem Sudo",callback_data="RemSudo:"..list[i]}})
			end
		end
	else
		local i = 1
		for i=1,#list do
			if i > (page-1)*10 and i < page*10+1 then
				local user = send_req(send_api.."/getChat?chat_id="..list[i])
				if user and user.result.username then
					table.insert(inline,{{text=list[i],url="t.me/"..user.result.username},{text="Rem Sudo",callback_data="RemSudo:"..list[i]}})
				else
					table.insert(inline,{{text=list[i],callback_data="nousername"},{text="Rem Sudo",callback_data="RemSudo:"..list[i]}})
				end
			end
			i = i + 1
		end
		if page == 1 then
			table.insert(inline,{{text="Next page >>",callback_data="PageSudo:"..page+1}})
		elseif page == #list/10 or page == math.floor(#list/10)+1 then
			table.insert(inline,{{text="<< Previous page",callback_data="PageSudo:"..page-1}})
		else
			table.insert(inline,{{text="<< Previous page",callback_data="PageSudo:"..page-1},{text="Next page >>",callback_data="PageSudo:"..page+1}})
		end
	end
	if #list ~= 0 then table.insert(inline,{{text="Close list",callback_data="Close"}}) end
	send_key(msg.chat.id, text,nil,inline)
	return nil
end
function add_user(msg)
	redis:sadd('users',msg.from.id)
end
function blocked_list(msg)
	local list = redis:smembers('blocked')
	if #list == 0 then
		text = "*Blocked users list is empty!*"
	else
		text = "*Blocked users list:*"
	end
	local inline = {}
	local page = 1
	if #list < 11 then
		for k,v in pairs(list) do
			local user = send_req(send_api.."/getChat?chat_id="..v)
			if user and user.result.username then
				table.insert(inline,{{text=v,url="t.me/"..user.result.username},{text="Unblock",callback_data="Unblock:"..v}})
			else
				table.insert(inline,{{text=v,callback_data="nousername"},{text="Unblock",callback_data="Unblock:"..v}})
			end
		end
	else
		local i = 1
		for k,v in pairs(list) do
			if i > (page-1)*10 and i < page*10+1 then
				local user = send_req(send_api.."/getChat?chat_id="..v)
				if user and user.result.username then
					--temp = {}
					table.insert(inline,{{text=v,url="t.me/"..user.result.username},{text="Unblock",callback_data="Unblock:"..v}})
				else
					table.insert(inline,{{text=v,callback_data="nousername"},{text="Unblock",callback_data="Unblock:"..v}})
				end
			end
			i = i + 1
		end
		if page == 1 then
			table.insert(inline,{{text="Next page >>",callback_data="PageBanned:"..page+1}})
		elseif page == #list/10 or page == math.floor(#list/10)+1 then
			table.insert(inline,{{text="<< Previous page",callback_data="PageBanned:"..page-1}})
		else
			table.insert(inline,{{text="<< Previous page",callback_data="PageBanned:"..page-1},{text="Next page >>",callback_data="PageBanned:"..page+1}})
		end
	end
	if #list ~= 0 then table.insert(inline,{{text="Close list",callback_data="Close"}}) end
	send_key(msg.chat.id, text,nil,inline)
	return nil
end
function user_list(msg)
	local users = redis:scard('users')
	local inline = {}
	local list = redis:smembers('users')
	local banned = redis:smembers('blocked')
	local sudo_users = _config.sudo_users
	local page = 1
	if #list-#banned-#sudo_users < 11 then
		for k,v in pairs(list) do
			if not is_sudo1(tonumber(v)) and not redis:sismember('blocked',v) then
				local user = send_req(send_api.."/getChat?chat_id="..v)
				if user and user.result.username then
					--temp = {}
					table.insert(inline,{{text=v,url="t.me/"..user.result.username},{text="Block",callback_data="Block:"..v},{text="Set Sudo",callback_data="SetSudo:"..v}})
				else
					table.insert(inline,{{text=v,callback_data="nousername"},{text="Block",callback_data="Block:"..v},{text="Set Sudo",callback_data="SetSudo:"..v}})
				end
			else
				users = users - 1
			end
		end
	else
		local i = 1
		for k,v in pairs(list) do
			if not is_sudo1(tonumber(v)) and not redis:sismember('blocked',v) then
				if i > (page-1)*10 and i < page*10+1 then
					local user = send_req(send_api.."/getChat?chat_id="..v)
					if user and user.result.username then
						--temp = {}
						table.insert(inline,{{text=v,url="t.me/"..user.result.username},{text="Block",callback_data="Block:"..v},{text="Set Sudo",callback_data="SetSudo:"..v}})
					else
						table.insert(inline,{{text=v,callback_data="nousername"},{text="Block",callback_data="Block:"..v},{text="Set Sudo",callback_data="SetSudo:"..v}})
					end
				end
				i = i + 1
			else
				users = users - 1
			end
		end
		if page == 1 then
			table.insert(inline,{{text="Next page >>",callback_data="PageUsers:"..page+1}})
		elseif page == users/10 or page == math.floor(users/10)+1 then
			table.insert(inline,{{text="<< Previous page",callback_data="PageUsers:"..page-1}})
		else
			table.insert(inline,{{text="<< Previous page",callback_data="PageUsers:"..page-1},{text="Next page >>",callback_data="PageUsers:"..page+1}})
		end
	end
	if #list-#banned-#sudo_users ~= 0 then table.insert(inline,{{text="Close list",callback_data="Close"}}) end
	local now = ""..((page-1)*10+1) .." - ".. math.min(page*10,users) ..""
	send_key(msg.chat.id, '*> '..now..' / '..users..' User(s)*',nil,inline)
	return nil
end

local function run(msg, matches)
	local is_blocked =  redis:sismember('blocked',msg.from.id)
	if is_blocked and msg.chat.type == "private" then
		return false
	end
	if (matches[1] == "id" or  matches[1] == "🚦 اطلاعات چت") then
		if not msg.reply_to_message then
			return "*Chat ID* : "..msg.chat.id.."\n*Your ID* : "..msg.from.id
		elseif msg.reply_to_message then
			return "*"..msg.reply_to_message.from.id.."*"
		end
	end
	if matches[1] == "setrealm" and is_sudo(msg) then
		redis:set("realm",msg.chat.id)
		return "*Realm has been add*"
	end
	if matches[1] == "beyond" or matches[1] == "🎯 اعضای تیم"  then
		return _config.info_text
	end
	if (matches[1] == "users" or matches[1] == "👥 لیست کاربران") and is_sudo(msg) then
		return user_list(msg)
	end
	if (matches[1] == "help" or matches[1] == "🔖 راهنما") and is_sudo(msg) then
		return help_text
	end
	if matches[1] == "help" or matches[1] == "🔖 راهنما" then
		return mem_help
	end
	if matches[1] == "📬 پروفایل" then
		if redis:get("profile") then
			proftext = redis:get("profile")
		else
			proftext = profile_text
		end
		return proftext
	end
	if (matches[1] == "blocklist" or matches[1] == "🚷 لیست سیاه") and is_sudo(msg) then
		return blocked_list(msg)
	end
	if (matches[1] == "sudolist" or matches[1] == "👤 لیست سودو ها") and is_sudo(msg) then
		return sudolist(msg)
	end
	if (matches[1] == "clean blocklist" or matches[1] == "✅ پاک کردن لیست سیاه") and is_sudo(msg) then
		redis:del('blocked')
		return "*Block list has been cleaned*"
	end
	if matches[1] == "block" and is_sudo(msg) then
		if matches[2] then
			redis:sadd('blocked',matches[2])
			send_msg(matches[2], "*You Are Blocked By Admin Command*\n_شما به دستور ادمین بلاک شدید_", "markdown")
			return "_User_ *"..matches[2].."* _has been blocked_"
		end
		if msg.reply_to_message and msg.reply_to_message.forward_from then
			local user = msg.reply_to_message.forward_from.id
			redis:sadd('blocked',user)
			send_msg(user, "*You Are Blocked By Admin Command*\n_شما به دستور ادمین بلاک شدید_", "markdown")
			return "_User_ *"..user.."* _has been blocked_"
		end
	end
	if matches[1] == "unblock" and is_sudo(msg) then
		if matches[2] then
			redis:srem('blocked',matches[2])
			send_msg(matches[2], "*You Are Unblocked By Admin Command*\n_شما به دستور ادمین از بلاک خارج شدید_", "markdown")
			return "_User_ *"..matches[2].."* _has been unblocked_"
		end
		if msg.reply_to_message and msg.reply_to_message.forward_from then
			local user = msg.reply_to_message.forward_from.id
			redis:srem('blocked',user)
			send_msg(user, "*You Are Unblocked By Admin Command*\n_شما به دستور ادمین از بلاک خارج شدید_", "markdown")
			return "_User_ *"..user.."* _has been unblocked_"
		end
	end
	if matches[1] == "setsent" and matches[2] and is_sudo(msg) then
		redis:set("setsent",matches[2])
		return "*Sent message has been set*\n_You Can Use :_\n`{name}` ➣ _Sender Name_\n`{username}` ➣ _Sender Username_"
	end
	if matches[1] == "setprofiletext" and matches[2] and is_sudo(msg) then
		redis:set("profile",matches[2])
		return "*Profile text has been set*"
	end
	if matches[1] == "setstart" and matches[2] and is_sudo(msg) then
		redis:set("setstart",matches[2])
		return "*Start message has been set*\n_You Can Use :_\n`{name}` ➣ _New Member Name_\n`{username}` ➣ _New Member Username_"
	end
	if matches[1] == "sendtoall" and matches[2] and is_sudo(msg) then
		local list = redis:smembers('users')
		for i = 1, #list do
			send_msg(list[i], matches[2], "markdown")
		end
		return "*Sent to "..redis:scard('users').." user*"
	end
	if matches[1] == "fwdtoall" and is_sudo(msg) then
		local list = redis:smembers('users')
		for i = 1, #list do
			forwardMessage(list[i],msg.chat.id,msg.reply_to_message.message_id)
		end
		return "*Sent to "..redis:scard('users').." user*"
	end
	if (matches[1] == "init" or matches[1] == "🔁 بارگذاری مجدد") and is_sudo(msg) then
		bot_run()
		reload_plugins(true)
		return "*Bot Reloaded*"
	end
	if matches[1] == 'antiflood' and is_sudo(msg) then
		local hash = 'anti-flood'
		--Enable Anti-flood
		if matches[2] == 'on' then
			if not redis:get(hash) then
				return '_Private_ *flood protection* _is already_ *enabled*'
			else
				redis:del(hash)
				return '_Private_ *flood protection* _has been_ *enabled*'
			end
		--Disable Anti-flood
		elseif matches[2] == 'off' then
			if redis:get(hash) then
				return '_Private_ *flood protection* _is already_ *disabled*'
			else
				redis:set(hash, true)
				return '_Private_ *flood protection* _has been_ *disabled*'
			end
		end
	end
	if matches[1] == 'autoleave' and is_sudo(msg) then
		local hash = 'AutoLeave'
		--Enable Auto Leave
		if matches[2] == 'on' then
			if not redis:get(hash) then
				return '*Auto Leave* _is already_ *enabled*'
			else
				redis:del(hash)
				return '*Auto Leave* _has been_ *enabled*'
			end
		--Disable Auto Leave
		elseif matches[2] == 'off' then
			if redis:get(hash) then
				return '*Auto Leave* _is already_ *disabled*'
			else
				redis:set(hash, true)
				return '*Auto Leave* _has been_ *disabled*'
			end
		end
	end
	if matches[1] == 'setpvfloodtime' and is_sudo(msg) then
		if not matches[2] then
		else
			hash = 'flood_time'
			redis:set(hash, matches[2])
			return '_Private_ *flood check time* _has been set to :_ *'..matches[2]..'*'
		end
	elseif matches[1] == 'setpvflood' and is_sudo(msg) then
		if not matches[2] then
		else
			hash = 'flood_max'
			redis:set(hash, matches[2])
			return '_Private_ *flood sensitivity* _has been set to :_ *'..matches[2]..'*'
		end
	end
	if tonumber(msg.from.id) == sudo_id then
		if matches[1]:lower() == "setsudo" then
			if matches[2] and not msg.reply_to_message then
				local user_id = matches[2]
				if already_sudo(tonumber(user_id)) then
					return 'User '..user_id..' is already sudo users'
				else
					table.insert(_config.sudo_users, tonumber(user_id)) 
					print(user_id..' added to sudo users') 
					save_config() 
					reload_plugins(true) 
					return "User "..user_id.." added to sudo users" 
				end
			elseif not matches[2] and msg.reply_to_message then
				local user_id = msg.reply_to_message.from.id
				if already_sudo(tonumber(user_id)) then
					return 'User '..user_id..' is already sudo users'
				else
					table.insert(_config.sudo_users, tonumber(user_id)) 
					print(user_id..' added to sudo users') 
					save_config() 
					reload_plugins(true) 
					return "User "..user_id.." added to sudo users" 
				end
			end
		end
		if matches[1]:lower() == "remsudo" then
				if matches[2] and not msg.reply_to_message then
				local user_id = tonumber(matches[2]) 
				if not already_sudo(user_id) then
					return 'User '..user_id..' is not sudo users'
				else
					table.remove(_config.sudo_users, getindex( _config.sudo_users, user_id)) 
					print(user_id..' removed from sudo users') 
					save_config() 
					reload_plugins(true) 
					return "User "..user_id.." removed from sudo users"
				end
			elseif not matches[2] and msg.reply_to_message then
				local user_id = tonumber(msg.reply_to_message.from.id) 
				if not already_sudo(user_id) then
					return 'User '..user_id..' is not sudo users'
				else
					table.remove(_config.sudo_users, getindex( _config.sudo_users, user_id)) 
					print(user_id..' removed from sudo users') 
					save_config() 
					reload_plugins(true) 
					return "User "..user_id.." removed from sudo users"
				end
			end
		end
	end
end

local function pre_process(msg)

	if not getindex( _config.sudo_users, sudo_id) then table.insert(_config.sudo_users, sudo_id) end 
	
	for k,v in pairs(_config.sudo_users) do
		redis:sadd('users',v)
	end

	local botcmd = msg.text == "/start" or msg.text == "/init" or msg.text == "/setrealm" or msg.text == "/setstart (.*)" or msg.text == "/id" or msg.text == "/setsent (.*)" or msg.text == "/blocklist" or msg.text == "/users" or msg.text == "/block (%d+)" or msg.text == "/unblock (%d+)" or msg.text == "/clean blocklist" or msg.text == "/setsudo (%d+)" or msg.text == "/remsudo (%d+)" or msg.text == "/antiflood (.*)" or msg.text == "/setpvflood (%d+)" or msg.text == "/setpvfloodtime (%d+)" or msg.text == "/help" or msg.text == "/sudolist" or msg.text == "/sendtoall (.*)" or msg.text == "/beyond" or msg.text == "🚦 اطلاعات چت" or msg.text == "📬 پروفایل" or msg.text == "🎯 اعضای تیم" or msg.text == "🌟 کانال ما" or msg.text == "🔖 راهنما" or msg.text == "/block" or msg.text == "/unblock" or msg.text == "/setsudo" or msg.text == "/remsudo" or msg.text == "/autoleave (.*)" or msg.text == "/fwdtoall" or msg.text == "/setprofiletext (.*)" or msg.text == "🚷 لیست سیاه" or msg.text == "👤 لیست سودو ها" or msg.text == "✅ پاک کردن لیست سیاه" or msg.text == "🔁 بارگذاری مجدد" or msg.text == "👥 لیست کاربران"
	
	
	--by @Xamarin_Developer
	if msg.callback_query then
		local Xamarin = msg.callback_query
		--if Xamarin.message.date < os.time() - 5 then return end
		local xamarin = Xamarin.data
		local msg_id = Xamarin.message.message_id
		local chat_id = Xamarin.message.chat.id
		local user_id = Xamarin.from.id
		local work_with_user = xamarin:match("(%d+)") or '0000000'
		local page = tonumber(xamarin:match("(%d+)") or '0000000')
		if is_sudo1(tonumber(user_id)) then
			if xamarin == 'Block:'..work_with_user then
				redis:sadd('blocked',work_with_user)
				send_msg(work_with_user, "*You Are Blocked By Admin Command*\n_شما به دستور ادمین بلاک شدید_", "markdown")
				local users = redis:scard('users')
				local inline = {}
				local list = redis:smembers('users')
				local banned = redis:smembers('blocked')
				local sudo_users = _config.sudo_users
				local page = 1
				if #list-#banned-#sudo_users < 11 then
					for k,v in pairs(list) do
						if not is_sudo1(tonumber(v)) and not redis:sismember('blocked',v) then
							local user = send_req(send_api.."/getChat?chat_id="..v)
							if user and user.result.username then
								--temp = {}
								table.insert(inline,{{text=v,url="t.me/"..user.result.username},{text="Block",callback_data="Block:"..v},{text="Set Sudo",callback_data="SetSudo:"..v}})
							else
								table.insert(inline,{{text=v,callback_data="nousername"},{text="Block",callback_data="Block:"..v},{text="Set Sudo",callback_data="SetSudo:"..v}})
							end
						else
							users = users - 1
						end
					end
				else
					local i = 1
					for k,v in pairs(list) do
						if not is_sudo1(tonumber(v)) and not redis:sismember('blocked',v) then
							if i > (page-1)*10 and i < page*10+1 then
								local user = send_req(send_api.."/getChat?chat_id="..v)
								if user and user.result.username then
									--temp = {}
									table.insert(inline,{{text=v,url="t.me/"..user.result.username},{text="Block",callback_data="Block:"..v},{text="Set Sudo",callback_data="SetSudo:"..v}})
								else
									table.insert(inline,{{text=v,callback_data="nousername"},{text="Block",callback_data="Block:"..v},{text="Set Sudo",callback_data="SetSudo:"..v}})
								end
							end
							i = i + 1
						else
							users = users - 1
						end
					end
					if page == 1 then
						table.insert(inline,{{text="Next page >>",callback_data="PageUsers:"..page+1}})
					elseif page == users/10 or page == math.floor(users/10)+1 then
						table.insert(inline,{{text="<< Previous page",callback_data="PageUsers:"..page-1}})
					else
						table.insert(inline,{{text="<< Previous page",callback_data="PageUsers:"..page-1},{text="Next page >>",callback_data="PageUsers:"..page+1}})
					end
				end
				if #list-#banned-#sudo_users ~= 0 then table.insert(inline,{{text="Close list",callback_data="Close"}}) end
				local now = ""..((page-1)*10+1) .." - ".. math.min(page*10,users) ..""
				edit_key(chat_id,msg_id, '*> '..now..' / '..users..' User(s)*',nil,inline)
				return nil--"_User_ *"..work_with_user.."* _has been blocked_"
			end
			if xamarin == 'Unblock:'..work_with_user then
				redis:srem('blocked',work_with_user)
				send_msg(work_with_user, "*You Are Unblocked By Admin Command*\n_شما به دستور ادمین از بلاک خارج شدید_", "markdown")
				local list = redis:smembers('blocked')
				local page = 1
				if #list == 0 then
					text = "*Blocked users list is empty!*"
				else
					text = "*Blocked users list:*"
				end
				local inline = {}
				if #list < 11 then
					for k,v in pairs(list) do
						local user = send_req(send_api.."/getChat?chat_id="..v)
						if user and user.result.username then
							--temp = {}
							table.insert(inline,{{text=v,url="t.me/"..user.result.username},{text="Unblock",callback_data="Unblock:"..v}})
						else
							table.insert(inline,{{text=v,callback_data="nousername"},{text="Unblock",callback_data="Unblock:"..v}})
						end
					end
				else
					local i = 1
					for k,v in pairs(list) do
						if i > (page-1)*10 and i < page*10+1 then
							local user = send_req(send_api.."/getChat?chat_id="..v)
							if user and user.result.username then
								--temp = {}
								table.insert(inline,{{text=v,url="t.me/"..user.result.username},{text="Unblock",callback_data="Unblock:"..v}})
							else
								table.insert(inline,{{text=v,callback_data="nousername"},{text="Unblock",callback_data="Unblock:"..v}})
							end
						end
						i = i + 1
					end
					if page == 1 then
						table.insert(inline,{{text="Next page >>",callback_data="PageBanned:"..page+1}})
					elseif page == #list/10 or page == math.floor(#list/10)+1 then
						table.insert(inline,{{text="<< Previous page",callback_data="PageBanned:"..page-1}})
					else
						table.insert(inline,{{text="<< Previous page",callback_data="PageBanned:"..page-1},{text="Next page >>",callback_data="PageBanned:"..page+1}})
					end
				end
				if #list ~= 0 then table.insert(inline,{{text="Close list",callback_data="Close"}}) end
				edit_key(chat_id,msg_id, text,nil,inline)
				return nil
			end
			if xamarin == 'SetSudo:'..work_with_user then
				if user_id == sudo_id then
					table.insert(_config.sudo_users, tonumber(work_with_user)) 
					print(work_with_user..' added to sudo users') 
					save_config() 
					local users = redis:scard('users')
					local inline = {}
					local list = redis:smembers('users')
					local banned = redis:smembers('blocked')
					local sudo_users = _config.sudo_users
					local page = 1
					if #list-#banned-#sudo_users < 11 then
						for k,v in pairs(list) do
							if not is_sudo1(tonumber(v)) and not redis:sismember('blocked',v) then
								local user = send_req(send_api.."/getChat?chat_id="..v)
								if user and user.result.username then
									--temp = {}
									table.insert(inline,{{text=v,url="t.me/"..user.result.username},{text="Block",callback_data="Block:"..v},{text="Set Sudo",callback_data="SetSudo:"..v}})
								else
									table.insert(inline,{{text=v,callback_data="nousername"},{text="Block",callback_data="Block:"..v},{text="Set Sudo",callback_data="SetSudo:"..v}})
								end
							else
								users = users - 1
							end
						end
					else
						local i = 1
						for k,v in pairs(list) do
							if not is_sudo1(tonumber(v)) and not redis:sismember('blocked',v) then
								if i > (page-1)*10 and i < page*10+1 then
									local user = send_req(send_api.."/getChat?chat_id="..v)
									if user and user.result.username then
										--temp = {}
										table.insert(inline,{{text=v,url="t.me/"..user.result.username},{text="Block",callback_data="Block:"..v},{text="Set Sudo",callback_data="SetSudo:"..v}})
									else
										table.insert(inline,{{text=v,callback_data="nousername"},{text="Block",callback_data="Block:"..v},{text="Set Sudo",callback_data="SetSudo:"..v}})
									end
								end
								i = i + 1
							else
								users = users - 1
							end
						end
						if page == 1 then
							table.insert(inline,{{text="Next page >>",callback_data="PageUsers:"..page+1}})
						elseif page == users/10 or page == math.floor(users/10)+1 then
							table.insert(inline,{{text="<< Previous page",callback_data="PageUsers:"..page-1}})
						else
							table.insert(inline,{{text="<< Previous page",callback_data="PageUsers:"..page-1},{text="Next page >>",callback_data="PageUsers:"..page+1}})
						end
					end
					if #list-#banned-#sudo_users ~= 0 then table.insert(inline,{{text="Close list",callback_data="Close"}}) end
					local now = ""..((page-1)*10+1) .." - ".. math.min(page*10,users) ..""
					edit_key(chat_id,msg_id, '*> '..now..' / '..users..' User(s)*',nil,inline)
					reload_plugins(true) 
					return nil--"_User_ *"..work_with_user.."* _has been blocked_"
				else
					alert(Xamarin.id,"You are not full sudo",true)
				end
			end
			if xamarin == 'RemSudo:'..work_with_user then
				if user_id == sudo_id then
					if tonumber(work_with_user) ~= sudo_id then
						table.remove(_config.sudo_users, getindex( _config.sudo_users, tonumber(work_with_user)))
						print(work_with_user..' removed from sudo users') 
						save_config() 
						local list = _config.sudo_users
						local text = "*Sudo Users :*\n"
						local inline = {}
						local page = 1
						if #list < 11 then
							for i=1,#list do
								local user = send_req(send_api.."/getChat?chat_id="..list[i])
								if user and user.result.username then
									table.insert(inline,{{text=list[i],url="t.me/"..user.result.username},{text="Rem Sudo",callback_data="RemSudo:"..list[i]}})
								else
									table.insert(inline,{{text=list[i],callback_data="nousername"},{text="Rem Sudo",callback_data="RemSudo:"..list[i]}})
								end
							end
						else
							local i = 1
							for i=1,#list do
								if i > (page-1)*10 and i < page*10+1 then
									local user = send_req(send_api.."/getChat?chat_id="..list[i])
									if user and user.result.username then
										table.insert(inline,{{text=list[i],url="t.me/"..user.result.username},{text="Rem Sudo",callback_data="RemSudo:"..list[i]}})
									else
										table.insert(inline,{{text=list[i],callback_data="nousername"},{text="Rem Sudo",callback_data="RemSudo:"..list[i]}})
									end
								end
								i = i + 1
							end
							if page == 1 then
								table.insert(inline,{{text="Next page >>",callback_data="PageSudo:"..page+1}})
							elseif page == #list/10 or page == math.floor(#list/10)+1 then
								table.insert(inline,{{text="<< Previous page",callback_data="PageSudo:"..page-1}})
							else
								table.insert(inline,{{text="<< Previous page",callback_data="PageSudo:"..page-1},{text="Next page >>",callback_data="PageSudo:"..page+1}})
							end
						end
						if #list ~= 0 then table.insert(inline,{{text="Close list",callback_data="Close"}}) end
						edit_key(chat_id,msg_id, text,nil,inline)
						reload_plugins(true) 
						return nil
					else
						alert(Xamarin.id,"You can't remove full sudo",true)
					end
				else
					alert(Xamarin.id,"You are not full sudo",true)
				end
			end
			if xamarin == 'PageUsers:'..page then
				local users = redis:scard('users')
				local inline = {}
				local list = redis:smembers('users')
				local banned = redis:smembers('blocked')
				local sudo_users = _config.sudo_users
				if #list-#banned-#sudo_users < 11 then
					for k,v in pairs(list) do
						if not is_sudo1(tonumber(v)) and not redis:sismember('blocked',v) then
							local user = send_req(send_api.."/getChat?chat_id="..v)
							if user and user.result.username then
								--temp = {}
								table.insert(inline,{{text=v,url="t.me/"..user.result.username},{text="Block",callback_data="Block:"..v},{text="Set Sudo",callback_data="SetSudo:"..v}})
							else
								table.insert(inline,{{text=v,callback_data="nousername"},{text="Block",callback_data="Block:"..v},{text="Set Sudo",callback_data="SetSudo:"..v}})
							end
						else
							users = users - 1
						end
					end
				else
					local i = 1
					for k,v in pairs(list) do
						if not is_sudo1(tonumber(v)) and not redis:sismember('blocked',v) then
							if i > (page-1)*10 and i < page*10+1 then
								local user = send_req(send_api.."/getChat?chat_id="..v)
								if user and user.result.username then
									--temp = {}
									table.insert(inline,{{text=v,url="t.me/"..user.result.username},{text="Block",callback_data="Block:"..v},{text="Set Sudo",callback_data="SetSudo:"..v}})
								else
									table.insert(inline,{{text=v,callback_data="nousername"},{text="Block",callback_data="Block:"..v},{text="Set Sudo",callback_data="SetSudo:"..v}})
								end
							end
							i = i + 1
						else
							users = users - 1
						end
					end
					if page == 1 then
						table.insert(inline,{{text="Next page >>",callback_data="PageUsers:"..page+1}})
					elseif page == users/10 or page == math.floor(users/10)+1 then
						table.insert(inline,{{text="<< Previous page",callback_data="PageUsers:"..page-1}})
					else
						table.insert(inline,{{text="<< Previous page",callback_data="PageUsers:"..page-1},{text="Next page >>",callback_data="PageUsers:"..page+1}})
					end
				end
				if #list-#banned-#sudo_users ~= 0 then table.insert(inline,{{text="Close list",callback_data="Close"}}) end
				local now = ""..((page-1)*10+1) .." - ".. math.min(page*10,users) ..""
				edit_key(chat_id,msg_id, '*> '..now..' / '..users..' User(s)*',nil,inline)
				return nil--"_User_ *"..work_with_user.."* _has been blocked_"
			end
			if xamarin == 'PageBanned:'..page then
				local list = redis:smembers('blocked')
				if #list == 0 then
					text = "*Blocked users list is empty!*"
				else
					text = "*Blocked users list:*"
				end
				local inline = {}
				if #list < 11 then
					for k,v in pairs(list) do
						local user = send_req(send_api.."/getChat?chat_id="..v)
						if user and user.result.username then
							--temp = {}
							table.insert(inline,{{text=v,url="t.me/"..user.result.username},{text="Unblock",callback_data="Unblock:"..v}})
						else
							table.insert(inline,{{text=v,callback_data="nousername"},{text="Unblock",callback_data="Unblock:"..v}})
						end
					end
				else
					local i = 1
					for k,v in pairs(list) do
						if i > (page-1)*10 and i < page*10+1 then
							local user = send_req(send_api.."/getChat?chat_id="..v)
							if user and user.result.username then
								--temp = {}
								table.insert(inline,{{text=v,url="t.me/"..user.result.username},{text="Unblock",callback_data="Unblock:"..v}})
							else
								table.insert(inline,{{text=v,callback_data="nousername"},{text="Unblock",callback_data="Unblock:"..v}})
							end
						end
						i = i + 1
					end
					if page == 1 then
						table.insert(inline,{{text="Next page >>",callback_data="PageBanned:"..page+1}})
					elseif page == #list/10 or page == math.floor(#list/10)+1 then
						table.insert(inline,{{text="<< Previous page",callback_data="PageBanned:"..page-1}})
					else
						table.insert(inline,{{text="<< Previous page",callback_data="PageBanned:"..page-1},{text="Next page >>",callback_data="PageBanned:"..page+1}})
					end
				end
				if #list ~= 0 then table.insert(inline,{{text="Close list",callback_data="Close"}}) end
				edit_key(chat_id,msg_id, text,nil,inline)
			end
			if xamarin == 'PageSudo:'..page then
				local list = _config.sudo_users
				local text = "*Sudo Users :*\n"
				local inline = {}
				if #list < 11 then
					for i=1,#list do
						local user = send_req(send_api.."/getChat?chat_id="..list[i])
						if user and user.result.username then
							table.insert(inline,{{text=list[i],url="t.me/"..user.result.username},{text="Rem Sudo",callback_data="RemSudo:"..list[i]}})
						else
							table.insert(inline,{{text=list[i],callback_data="nousername"},{text="Rem Sudo",callback_data="RemSudo:"..list[i]}})
						end
					end
				else
					local i = 1
					for i=1,#list do
						if i > (page-1)*10 and i < page*10+1 then
							local user = send_req(send_api.."/getChat?chat_id="..list[i])
							if user and user.result.username then
								table.insert(inline,{{text=list[i],url="t.me/"..user.result.username},{text="Rem Sudo",callback_data="RemSudo:"..list[i]}})
							else
								table.insert(inline,{{text=list[i],callback_data="nousername"},{text="Rem Sudo",callback_data="RemSudo:"..list[i]}})
							end
						end
						i = i + 1
					end
					if page == 1 then
						table.insert(inline,{{text="Next page >>",callback_data="PageSudo:"..page+1}})
					elseif page == #list/10 or page == math.floor(#list/10)+1 then
						table.insert(inline,{{text="<< Previous page",callback_data="PageSudo:"..page-1}})
					else
						table.insert(inline,{{text="<< Previous page",callback_data="PageSudo:"..page-1},{text="Next page >>",callback_data="PageSudo:"..page+1}})
					end
				end
				if #list ~= 0 then table.insert(inline,{{text="Close list",callback_data="Close"}}) end
				edit_key(chat_id,msg_id, text,nil,inline)
				return nil
			end
			if xamarin == 'Close' then
				edit_key(chat_id,msg_id, "*List was closed*")
			end
		else
			alert(Xamarin.id,"You are not sudo",true)
		end
		return nil
	end
	
	if msg.new_chat_participant or msg.new_chat_title or msg.new_chat_photo or msg.left_chat_participant then return end
	if msg.date and msg.date < os.time() - 5 then return end
	
	if msg.chat.type ~= "private" and not redis:get('AutoLeave') and redis:get("realm") and tonumber(msg.chat.id) ~= tonumber(redis:get("realm")) and not is_sudo(msg) then
		send_msg(msg.chat.id, "_This Is Not My_ *Realm*", "markdown")
		LeaveGroup(msg.chat.id)
	end
	if msg.text == "🌟 کانال ما"  then
		return send_key(msg.chat.id, "[our channel](http://telegram.me/BeyondTeam)",nil,{{{text="👤ارتباط با ما",url="T.Me/BDMessengerBot"}}})
	end
	if msg.text == "/start" and msg.chat.type == "private" then
		if is_sudo(msg) then
			if not redis:get("setstart") then
				startmsg = "Welmcome To Official Messenger Bot Of Beyond Team  [our channel](http://telegram.me/BeyondTeam)"
			else
				startmsg = redis:get("setstart")
			end
			
			startmsg = startmsg:gsub("{name}", check_markdown(msg.from.first_name))
			startmsg = startmsg:gsub("{username}", check_markdown((msg.from.username or "")))
			
			send_key(msg.from.id, startmsg, sudo_keyboard)

		else
			add_user(msg)
			
			if not redis:get("setstart") then
				startmsg = "Welmcome To Official Messenger Bot Of Beyond Team  [our channel](http://telegram.me/BeyondTeam)"
			else
				startmsg = redis:get("setstart")
			end
			
			startmsg = startmsg:gsub("{name}", check_markdown(msg.from.first_name))
			startmsg = startmsg:gsub("{username}", check_markdown((msg.from.username or "")))
			
			send_key(msg.from.id, startmsg, keyboard)
		end
	end
	
	if redis:get("realm") then
		realm = redis:get("realm")
	else
		realm = sudo_id
	end
	
	local is_blocked =  redis:sismember('blocked',msg.from.id)
	
	if redis:get("setsent") then
		sendmsg = redis:get("setsent")
	else
		sendmsg = "Send to my sudoers"
	end
	
	sendmsg = sendmsg:gsub("{name}", check_markdown(msg.from.first_name))
	sendmsg = sendmsg:gsub("{username}", check_markdown((msg.from.username or "")))
	
	if not botcmd then
		if msg.chat.type == "private" and not is_sudo(msg) then
			add_user(msg)
			if is_blocked then
				if redis:get('user:'..msg.from.id..':flooder') then
					return
				else
					send_msg(msg.chat.id, "*You Are Block...!*\n_شما بلاک شده اید_", "markdown")
				end
			else
				if not msg.sticker and not msg.forward_from and not msg.forward_from_chat then
					forwardMessage(realm,msg.chat.id,msg.message_id)
					send_msg(msg.chat.id, sendmsg, "markdown")
				elseif msg.sticker then
					if msg.from.username then
						user_name = '@'..msg.from.username
					else
						user_name = msg.from.first_name
					end
					forwardMessage(realm,msg.chat.id,msg.message_id)
					send_msg(msg.chat.id, sendmsg, "markdown")
					send_msg(realm, "➣Sticker Sender : "..check_markdown(user_name).." "..msg.from.id.."\n\n*Reply this message for answer*","markdown")
				elseif msg.forward_from or msg.forward_from_chat then
					if msg.from.username then
						user_name = '@'..msg.from.username
					else
						user_name = msg.from.first_name
					end
					forwardMessage(realm,msg.chat.id,msg.message_id)
					send_msg(msg.chat.id, sendmsg, "markdown")
					send_msg(realm, "➣Forwarder : "..check_markdown(user_name).." "..msg.from.id.."\n\n*Reply this message for answer*","markdown")
				end
			end
		end
	end

	if not botcmd and (is_sudo(msg) or msg.chat.id == realm) then
		if msg.reply_to_message and not msg.reply_to_message.forward_from and msg.reply_to_message.from.id == bot.id then
			if msg.reply_to_message.text:match("➣.*") then
				local user = msg.reply_to_message.text:match(".* (%d+)\n\nReply this message for answer")
				if msg.text then
					send_msg(user, msg.text)
					send_msg(msg.chat.id, "Sent")
				else
					forwardMessage(user,msg.chat.id,msg.message_id)
					send_msg(msg.chat.id, "Sent")
				end
			end
		end
		if msg.reply_to_message and msg.reply_to_message.forward_from and msg.reply_to_message.from.id == bot.id then
			local user = msg.reply_to_message.forward_from.id
			if msg.text then
				send_msg(user, msg.text)
				send_msg(msg.chat.id, "Sent")
			else
				forwardMessage(user,msg.chat.id,msg.message_id)
				send_msg(msg.chat.id, "Sent")
			end
		end
	end
	
	local hash = 'flood_max'
	if not redis:get(hash) then
		MSG_NUM_MAX = 5
	else
		MSG_NUM_MAX = tonumber(redis:get(hash))
	end

	local hash = 'flood_time'
	if not redis:get(hash) then
		TIME_CHECK = 2
	else
		TIME_CHECK = tonumber(redis:get(hash))
	end
	
	if msg.chat.type == 'private' then
		--Checking flood
		local hashse = 'anti-flood'
		if not redis:get(hashse) then
			print('anti-flood enabled')
			-- Check flood
			if not is_sudo(msg) then
				-- Increase the number of messages from the user on the chat
				local hash = 'flood:'..msg.from.id..':msg-number'
				local msgs = tonumber(redis:get(hash) or 0)
				if msgs > MSG_NUM_MAX then
					if msg.from.username then
						user_name = "@"..msg.from.username
					else
						user_name = msg.from.first_name
					end
					if redis:get('user:'..msg.from.id..':flooder') then
						return
					else
						send_msg(msg.chat.id, "_You are_ *blocked* _because of_ *flooding...!*", "markdown")
						redis:sadd("blocked", msg.from.id)
						send_msg(realm, 'User [ '..user_name..' ] '..msg.from.id..' has been blocked because of flooding!')
						redis:setex('user:'..msg.from.id..':flooder', 15, true)
					end
				end
				redis:setex(hash, TIME_CHECK, msgs+1)
			end
		end
	end
	
end

return {
	patterns ={
		"^(🚷 لیست سیاه)$",
		"^(👥 لیست کاربران)$",
		"^(👤 لیست سودو ها)$",
		"^(🔁 بارگذاری مجدد)$",
		"^(✅ پاک کردن لیست سیاه)$",
		"^(📬 پروفایل)$",
		"^[/](id)$",
		"^[/](userid)$",
		"^(🚦 اطلاعات چت)$",
		"^[/](init)$",
		"^[/](help)$",
		"^(🔖 راهنما)$",
		"^(🌟 کانال ما)$",
		"^[/](blocklist)$",
		"^[/](sudolist)$",
		"^[/](beyond)$",
		"^(🎯 اعضای تیم)$",
		"^[/](clean blocklist)$",
		"^[/](users)$",
		"^[/](setstart) (.*)$",
		"^[/](setprofiletext) (.*)$",
		"^[/](sendtoall) (.*)$",
		"^[/](fwdtoall)$",
		"^[/](antiflood) (.*)$",
		"^[/](autoleave) (.*)$",
		"^[/](setsent) (.*)$",
		"^[/](block) (%d+)$",
		"^[/](unblock) (%d+)$",
		"^[/](block)$",
		"^[/](unblock)$",
		"^[/](setsudo)$",
		"^[/](remsudo)$",
		"^[/](setsudo) (%d+)$",
		"^[/](remsudo) (%d+)$",
		"^[/](setpvflood) (%d+)$",
		"^[/](setpvfloodtime) (%d+)$",
		"^[/](setrealm)$"
	},
	run=run,
	pre_process=pre_process
}
