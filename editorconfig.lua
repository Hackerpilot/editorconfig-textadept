local patternSubs = {
	["*"] = "[^/]*",
	["**"] = ".*",
	["?"] = "."
}

local function loadEditorConfig(path)
	local f = io.open(path, "r")
	local config = {[""] = {}}
	local section = ""
	for line in f:lines() do
		if line:match("^%s*$") or line:match("^%s*[#;]") then
			goto continue
		elseif line:match("^%s*%[") then
			section = line:match("%[(.+)%]")
			config[section] = {}
		else
			local key, value = line:match("([%w_]+)%s*=%s*([%w_]+)")
			config[section][key] = value
		end
		::continue::
	end
	return config
end

local function setBufferProperties(config, filename)
	if filename == nil then return end
	for sectionName, section in pairs(config) do
		if #sectionName == 0 then goto continue end
		local pattern = string.gsub(sectionName, "%*?%*?%??", patternSubs)
		pattern = string.gsub(pattern, "%[%!", "[^")
		local withoutPath = filename:match("[^/\\]+$")
		if string.match(withoutPath, pattern) == nil then goto continue end
		if section["indent_style"] ~= nil then
			if section["indent_style"] == "tab" then
				buffer.use_tabs = true
			elseif section["indent_style"] == "space" then
				buffer.use_tabs = false
			end
		end
		if section["indent_size"] ~= nil then
			if section["indent_size"] == "tab" then
				if section["tab_width"] ~= nil then
					buffer.indent = tonumber(section["tab_width"])
				end
			else
				buffer.indent = tonumber(section["indent_size"])
			end
		end
		if section["tab_width"] ~= nil then
			buffer.tab_width = tonumber(section["tab_width"])
		else
			buffer.tab_width = buffer.indent
		end
		if section["end_of_line"] ~= nil then
			if section["end_of_line"] == "lf" then
				buffer.eol_mode = buffer.EOL_LF
			elseif section["end_of_line"] == "cr" then
				buffer.eol_mode = buffer.EOL_CR
			elseif section["end_of_line"] == "crlf" then
				buffer.eol_mode = buffer.EOL_CRLF
			end
		end
		::continue::
	end
end

events.connect(events.FILE_OPENED, function(filename)
	if filename == nil then return end
	local path = filename
	local configs = {}
	while true do
		path, current = string.match(path, "^(.+[/\\])(.+)")
		if path == nil then break end
		local possiblePath = path .. ".editorconfig"
		local attributes = lfs.attributes(possiblePath)
		if attributes ~= nil then
			configs[#configs + 1] = loadEditorConfig(possiblePath)
			if configs[#configs][""]["root"] then break end
		end
	end
	for i = 1, #configs do
		setBufferProperties(configs[#configs - i + 1], filename)
	end
end)
