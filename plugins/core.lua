local help_text = [[
*Beyond Messeger Bot Commands :*

*/id*
_Show Your And Chat ID_

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

*/setstart*
_Set Start Message_

*/setsent*
_Set Send Message_

*/block* `[id]`
_Add User To Block List_

*/unblock* `[id]`
_Remove User From Block List_

*/setsudo* `[id]`
_Add User To Sudo Users_

*/remsudo* `[id]`
_Remove User From Sudo Users_

*/setrealm*
_Set A New Realm_

*/antiflood on*
_Enable Flood Protection_

*/antiflood off*
_Disable Flood Protection_

*/setpvflood*
_Set The Maximun Messages In A FloodTime To Be Considered As flood_

*/setpvfloodtime*
_Set The Time That Bot Uses To Check flood_

*/beyond*
_Show About Bot_

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
local sudo_users = _config.sudo_users
local text = "Sudo Users :\n"
for i=1,#sudo_users do
    text = text..i.." - "..sudo_users[i].."\n"
end
return text
end

function add_user(msg)
	redis:sadd('users',msg.from.id)
end
function blocked_list(msg)
local list = redis:smembers('blocked')
 local text = "*Blocked users list!*\n\n"
 for k,v in pairs(list) do
 local user_info = redis:hgetall('user:'..v)
  if user_info and user_info.print_name then
   local print_name = string.gsub(user_info.print_name, "_", " ")
   local print_name = string.gsub(print_name, "‮", "")
   text = text.."*"..k.." - "..print_name.."* _["..v.."]_\n"
  else
   text = text.."*"..k.." -* _"..v.."_\n"
  end
 end
        return text
end

function user_list()
	local users = '*>* _'..redis:scard('users')..'_ *User*'
return users
end

local function run(msg, matches)
if matches[1] == "id" then
return "*Chat ID* : "..msg.chat.id.."\n*Your ID* : "..msg.from.id
end
if matches[1] == "setrealm" and is_sudo(msg) then
   redis:set("realm",msg.chat.id)
return "*Realm has been add*"
end
if matches[1] == "beyond" then
return send_msg(msg.chat.id, _config.info_text)
end
if matches[1] == "users" and is_sudo(msg) then
return user_list()
end
if matches[1] == "help" and is_sudo(msg) then
return help_text
end
if matches[1] == "help" and not is_sudo(msg) then
return mem_help
end
if matches[1] == "blocklist" and is_sudo(msg) then
return blocked_list(msg)
end
if matches[1] == "sudolist" and is_sudo(msg) then
return sudolist(msg)
end
if matches[1] == "clean blocklist" and is_sudo(msg) then
redis:del('blocked')
return "*Block list has been cleaned*"
end
if matches[1] == "block" and matches[2] and is_sudo(msg) then
redis:sadd('blocked',matches[2])
return "_User_ *"..matches[2].."* _has been blocked_"
end
if matches[1] == "unblock" and matches[2] and is_sudo(msg) then
redis:srem('blocked',matches[2])
return "_User_ *"..matches[2].."* _has been unblocked_"
end
if matches[1] == "setsent" and matches[2] and is_sudo(msg) then
   redis:set("setsent",matches[2])
return "*Sent message has been set*\n_You Can Use :_\n`{name}` ➣ _Sender Name_\n`{username}` ➣ _Sender Username_"
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
if matches[1] == "init" and is_sudo(msg) then
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
		if matches[1]:lower() == "setsudo" and matches[2] then
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
       end
			if matches[1]:lower() == "remsudo" and matches[2] then
      local user_id = tonumber(matches[2]) 
     if not already_sudo(user_id) then
    return 'User '..user_id..' is not sudo users'
         else
          table.remove(_config.sudo_users, getindex( _config.sudo_users, k)) 
      print(user_id..' removed from sudo users') 
     save_config() 
     reload_plugins(true) 
      return "User "..user_id.." removed from sudo users"
           end
       end
   end
end
local function pre_process(msg)
local botcmd = msg.text == "/start" or msg.text == "/init" or msg.text == "/setrealm" or msg.text == "/setstart (.*)" or msg.text == "/id" or msg.text == "/setsent (.*)" or msg.text == "/blocklist" or msg.text == "/users" or msg.text == "/block (%d+)" or msg.text == "/unblock (%d+)" or msg.text == "/clean blocklist" or msg.text == "/setsudo (%d+)" or msg.text == "/remsudo (%d+)" or msg.text == "/antiflood (.*)" or msg.text == "/setpvflood (%d+)" or msg.text == "/setpvfloodtime (%d+)" or msg.text == "/help" or msg.text == "/sudolist" or msg.text == "/sendtoall (.*)" or msg.text == "/beyond"
	if msg.new_chat_participant or msg.new_chat_title or msg.new_chat_photo or msg.left_chat_participant then return end
	if msg.date < os.time() - 5 then
		return
    end
if msg.text == "/start" and msg.chat.type == "private" then
add_user(msg)
if redis:get("setstart") then
    startmsg = redis:get("setstart")
       else
    startmsg = mem_help
  end
startmsg = startmsg:gsub("{name}", check_markdown(msg.from.first_name))
startmsg = startmsg:gsub("{username}", check_markdown((msg.from.username or "")))
send_msg(msg.chat.id, startmsg)
end
if redis:get("realm") then
    realm = redis:get("realm")
       else
    realm = sudo_id
  end
local is_blocked = 	redis:sismember('blocked',msg.from.id)
if redis:get("setsent") then
    sendmsg = redis:get("setsent")
       else
    sendmsg = "Send to my sudoers"
  end
sendmsg = sendmsg:gsub("{name}", check_markdown(msg.from.first_name))
sendmsg = sendmsg:gsub("{username}", check_markdown((msg.from.username or "")))
   if not botcmd then
 if msg.chat.type == "private" then
add_user(msg)
     if not msg.sticker and not msg.forward_from then
if is_blocked then
if redis:get('user:'..msg.from.id..':flooder') then
return
else
send_msg(msg.chat.id, "*You Are Block...!*\n_شما بلاک شده اید_", "markdown")
end
  else
forwardMessage(realm,msg.chat.id,msg.message_id)
send_msg(msg.chat.id, sendmsg)
   end
end
if msg.sticker then
add_user(msg)
if msg.from.username then
    user_name = '@'..msg.from.username
       else
    user_name = msg.from.first_name
  end
if is_blocked then
if redis:get('user:'..msg.from.id..':flooder') then
return
else
send_msg(msg.chat.id, "*You Are Block...!*\n_شما بلاک شده اید_", "markdown")
end
  else
forwardMessage(realm,msg.chat.id,msg.message_id)
send_msg(msg.chat.id, sendmsg)
send_msg(realm, "➣Sticker Sender : "..user_name.." "..msg.from.id)
       end
   end
if msg.forward_from then
add_user(msg)
if msg.from.username then
    user_name = '@'..msg.from.username
       else
    user_name = msg.from.first_name
  end
if is_blocked then
if redis:get('user:'..msg.from.id..':flooder') then
return
else
send_msg(msg.chat.id, "*You Are Block...!*\n_شما بلاک شده اید_", "markdown")
end
  else
forwardMessage(realm,msg.chat.id,msg.message_id)
send_msg(msg.chat.id, sendmsg)
send_msg(realm, "➣Forwarder : "..user_name.." "..msg.from.id)
         end
      end
   end
end
	if not msg.text and msg.reply_to_message and msg.reply_to_message.forward_from then
 if msg.chat.type ~= "private" then
	local user = msg.reply_to_message.forward_from.id
forwardMessage(user,msg.chat.id,msg.message_id)
send_msg(msg.chat.id, "Sent")
end
end
	if msg.text and msg.reply_to_message and msg.reply_to_message.forward_from then
 if msg.chat.type ~= "private" then
	local user = msg.reply_to_message.forward_from.id
send_msg(user, msg.text)
send_msg(msg.chat.id, "Sent")
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
"^[/](id)$",
"^[/](init)$",
"^[/](help)$",
"^[/](blocklist)$",
"^[/](sudolist)$",
"^[/](beyond)$",
"^[/](clean blocklist)$",
"^[/](users)$",
"^[/](setstart) (.*)$",
"^[/](sendtoall) (.*)$",
"^[/](antiflood) (.*)$",
"^[/](setsent) (.*)$",
"^[/](block) (%d+)$",
"^[/](unblock) (%d+)$",
"^[/](setsudo) (%d+)$",
"^[/](remsudo) (%d+)$",
"^[/](setpvflood) (%d+)$",
"^[/](setpvfloodtime) (%d+)$",
"^[/](setrealm)$"
},
run=run,
pre_process=pre_process
}
