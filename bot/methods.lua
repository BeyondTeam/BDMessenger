function send_msg(chat_id, text, use_markdown, reply_to_message_id)

	local url = send_api .. '/sendMessage?chat_id=' .. chat_id .. '&text=' .. url.escape(text)

	if reply_to_message_id then
		url = url .. '&reply_to_message_id=' .. reply_to_message_id
	end

	if use_markdown then
		url = url .. '&parse_mode=Markdown'
	end

	return send_req(url)

end

function send_document(chat_id, name)
	local send = send_api.."/sendDocument"
	local curl_command = 'curl -s "'..send..'" -F "chat_id='..chat_id..'" -F "document=@'..name..'"'
	return io.popen(curl_command):read("*all")
end

function forwardMessage(chat_id, from_chat_id, message_id)

	local url = send_api .. '/forwardMessage?chat_id=' .. chat_id .. '&from_chat_id=' .. from_chat_id .. '&message_id=' .. message_id

	return send_req(url)

end

function send_key(chat_id, text, keyboard, resize, mark)
	local response = {}
	response.keyboard = keyboard
	response.inline_keyboard = inline
	response.resize_keyboard = resize
	response.one_time_keyboard = false
	response.selective = false
	local responseString = JSON.encode(response)
	if mark then
		sended = send_api.."/sendMessage?chat_id="..chat_id.."&text="..url.escape(text).."&disable_web_page_preview=true&reply_markup="..url.escape(responseString)
	else
		sended = send_api.."/sendMessage?chat_id="..chat_id.."&text="..url.escape(text).."&parse_mode=Markdown&disable_web_page_preview=true&reply_markup="..url.escape(responseString)
	end
	return send_req(sended)
end

function edit_key( chat_id, message_id, text, keyboard, inline, resize, mark)
	local response = {}
	response.keyboard = keyboard
	response.inline_keyboard = inline
	response.resize_keyboard = resize
	response.one_time_keyboard = false
	response.selective = false
	local responseString = JSON.encode(response)
	local Rep =  send_api.. '/editMessageText?&chat_id='..chat_id..'&message_id='..message_id..'&text=' .. url.escape(text)
	Rep=Rep .. '&parse_mode=Markdown'
	if keyboard or inline then
		Rep=Rep..'&reply_markup='..url.escape(responseString)
	end
	return send_req(Rep)
end

function alert(callback_query_id, text, show_alert)
	local Rep = send_api .. '/answerCallbackQuery?callback_query_id=' .. callback_query_id .. '&text=' .. url.escape(text)
	if show_alert then
		Rep = Rep..'&show_alert=true'
	end
	return send_req(Rep)
end

function string:input()
	if not self:find(' ') then
		return false
	end
	return self:sub(self:find(' ')+1)
end

function serialize_to_file(data, file, uglify)
  file = io.open(file, 'w+')
  local serialized
  if not uglify then
    serialized = serpent.block(data, {
        comment = false,
        name = '_'
      })
  else
    serialized = serpent.dump(data)
  end
  file:write(serialized)
  file:close()
end

function is_sudo(msg)
  local var = false
  -- Check users id in config
  for v,user in pairs(_config.sudo_users) do
    if user == msg.from.id then
      var = true
    end
  end
  if sudo_id == msg.from.id then
		var = true
  end
  return var
end

function is_sudo1(sudoo)
  local var = false
  -- Check users id in config
  for v,user in pairs(_config.sudo_users) do
    if user == sudoo then
      var = true
    end
  end
  if sudo_id == sudoo then
		var = true
  end
  return var
end

function check_markdown(text) --markdown escape ( when you need to escape markdown , use it like : check_markdown('your text')
		str = text
		if str:match('_') then
			output = str:gsub('_',[[\_]])
		elseif str:match('*') then
			output = str:gsub('*','\\*')
		elseif str:match('`') then
			output = str:gsub('`','\\`')
		else
			output = str
		end
	return output
end

function getChatMember(chat_id, user_id)
 local url = send_api .. '/getChatMember?chat_id=' .. chat_id .. '&user_id=' .. user_id
   return send_req(url)
end

function LeaveGroup(chat_id)
  local url = send_api .. '/leaveChat?chat_id=' .. chat_id
  return send_req(url)
end
