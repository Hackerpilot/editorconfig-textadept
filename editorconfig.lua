
--indent_style
--    tab
--    space
--indent_size
--    integer
--    tab
--tab_width
--    integer
--end_of_line
--    lf
--    crlf
--    cr
--charset
--    latin1
--    utf-8
--    utf-16be
--    utf-16le
--trim_trailing_whitespace
--    true
--    false
--insert_final_newline
--    true
--    false
--max_line_length
--    integer

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
		if line:match("^%s*$") then
		elseif line:match("^%s*%[") then
			section = line:match("%[(.+)%]")
			config[section] = {}
			print("found section", section)
		else
			local key, value = line:match("([%w_]+)%s*=%s*([%w_]+)")
			print("found key", key, "and value", value)
			config[section][key] = value
		end
	end
	return config
end

local function setBufferProperties(config)
	if config["*"]["indent_style"] ~= nil then
		if config["*"]["indent_style"] == "tab" then
			buffer.use_tabs = true
		elseif config["*"]["indent_style"] == "space" then
			buffer.use_tabs = false
		end
	end
	if config["*"]["indent_size"] ~= nil then
		buffer.indent = tonumber(config["*"]["indent_size"])
	end
	if config["*"]["tab_width"] ~= nil then
		buffer.tab_width = tonumber(config["*"]["tab_width"])
	else
		buffer.tab_width = buffer.indent
	end
	if config["*"]["end_of_line"] ~= nil then
		if config["*"]["end_of_line"] == "lf" then
			buffer.eol_mode = buffer.EOL_LF
		elseif config["*"]["end_of_line"] == "cr" then
			buffer.eol_mode = buffer.EOL_CR
		elseif config["*"]["end_of_line"] == "crlf" then
			buffer.eol_mode = buffer.EOL_CRLF
		end
	end
end

events.connect(events.FILE_OPENED, function(filename)
	local path = filename
    while true do
        path, current = string.match(path, "^(.+/)(.+)")
        if path == nil then break end
		local possiblePath = path .. ".editorconfig"
        local attributes = lfs.attributes(possiblePath)
		if attributes ~= nil then
			print("Found .editorconfig at ", possiblePath)
			local config = loadEditorConfig(possiblePath)
			setBufferProperties(config)
			if config[""]["root"] then break end
		end
    end
	print()
end)
