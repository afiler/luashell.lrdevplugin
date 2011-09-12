--[[----------------------------------------------------------------------------

Lightroom Lua Shell
Written in 2011 by Andrew Filer <afiler@afiler.com> 

To the extent possible under law, the author(s) have dedicated all copyright
and related and neighboring rights to this software to the public domain
worldwide. This software is distributed without any warranty. 

You should have received a copy of the CC0 Public Domain Dedication along with
this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

------------------------------------------------------------------------------]]

return {
	LrSdkVersion = 3.0,
	LrSdkMinimumVersion = 1.3,

	LrToolkitIdentifier = 'com.afiler.lightroom.luashell',

	LrPluginName = LOC "$$$/Lua Shell/PluginName=Lua Shell",
	
	LrLibraryMenuItems = {
		{
		    title = LOC "$$$/Lua Shell/Shell=Lua shell window",
		    file = "Shell.lua",
		},
	},
	VERSION = { major=1, minor=0, revision=0, build=100001, },
}


	