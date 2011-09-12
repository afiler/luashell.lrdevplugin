--[[----------------------------------------------------------------------------

Lightroom Lua Shell
Written in 2011 by Andrew Filer <afiler@afiler.com> 

To the extent possible under law, the author(s) have dedicated all copyright
and related and neighboring rights to this software to the public domain
worldwide. This software is distributed without any warranty. 

You should have received a copy of the CC0 Public Domain Dedication along with
this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

------------------------------------------------------------------------------

Shell.lua

------------------------------------------------------------------------------]]

local LrFunctionContext = import 'LrFunctionContext'
local LrBinding = import 'LrBinding'
local LrDialogs = import 'LrDialogs'
local LrView = import 'LrView'
local LrLogger = import 'LrLogger'
local LrColor = import 'LrColor'
local LrApplication = import 'LrApplication'
local LrTasks = import 'LrTasks'

-- Environment for shell
local env = {}
for k, v in pairs(_G) do env[k] = v end

local function dump(var, level)
	if not level then level = 0 end
	if level > 3 then return '#' end
	-- return DataDumper(result, '')
	local t = type(var)
	if t == 'string' or t == 'number' then
		return var
	elseif t == 'table' then
		local output = {}
		local metatable = getmetatable(var)
		if not metatable then metatable = '' end
		for k, v in pairs(var) do
			if k == '_parent' then
				table.insert(output, k..' = duh')
			else
				table.insert(output, k..' = '..dump(v, level+1))
			end
		end
		return metatable..' {'..table.concat(output, ', ')..'}\n'
	else
		return '['..t..']'
	end
end

local function shell()
	LrFunctionContext.callWithContext( "shell", function( context )
		local f = LrView.osFactory()

		env.catalog = LrApplication.activeCatalog()
		env.target = env.catalog:getTargetPhoto()
		env.targets = env.catalog:getTargetPhotos()

		local historyField = f:edit_field { 
			fill_horizontal = 1,
			fill_vertical = 1,
			height = 200,
			value = [[
Lightroom Lua shell
Catalog: ]]..env.catalog:getPath()..[[

]]}

		env.v = historyView
		
		local function clear()
			historyField.value = ""
		end
		env.clear = clear
		
		local function print(val)
			if not val then val = 'nil' end
			historyField.value = historyField.value..val.."\n"
		end
		env.print = print
		
		
		env.keys = function(t)
			s = ''
			for k, v in pairs(t) do s = s..k..' ' end
			print(s)
		end

		local function validator(view, cmd, async)
			if not async then print("> "..cmd) end
			local output, err, f
			--async = true
			
			-- Try first as an immediate value
			local immediate = true
			if async then
				f = loadstring("import('LrTasks').startAsyncTask(function() print('=> '.."..cmd..") end)")
			else
				f = loadstring("return("..cmd..")")
			end

			-- If this doesn't compile, try as a block without a return value
			if not f then
				immediate = false
				if async then
					f, err = loadstring("import('LrTasks').startAsyncTask(function() "..cmd.." end)")
				else
					f, err = loadstring(cmd)
				end
			end

			if not f then
				-- Failed to compile
				print("!! "..err)
			else
				-- Compiled, now run
				if false and async then
					f = function()
						if immediate then
							f = loadstring("print ('=> '..dump("..cmd.."))")
						end
						import('LrTasks').startAsyncTask(f)
					end
				end
				
				local success, result = LrFunctionContext.pcallWithEnvironment(f, env, cmd)
				if success and (result or immediate) then
					print("-> "..dump(result))
				elseif not success then
					if not async and result == 'We can only wait from within a task' then
						validator(view, cmd, true)
					else
						print("## "..result)
					end
				end
			end

			return false, cmd
		end


		local inputField = f:edit_field { 
			immediate = false,
			width_in_chars = 80,
			height_in_lines = 3,
			value = "",
			validate = validator
		}

		
		local c = f:column {
			spacing = f:dialog_spacing(),
			fill_horizontal = 1,
			fill_vertical = 1,

			f:row {
				fill_horizontal = 1,
				fill_vertical = 1,
				historyField,
			}, -- end f:row
			f:row {
				inputField,
			}, -- end row
		} -- end column
		
		LrDialogs.presentModalDialog {
				title = "Lua Shell",
				resizable = true,
				contents = c
			}

	end)


end

shell()