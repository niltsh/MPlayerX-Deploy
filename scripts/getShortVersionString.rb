require 'osx/cocoa'
include OSX
OSX.require_framework 'ScriptingBridge'

info = NSDictionary.alloc.initWithContentsOfFile_(ARGV[0] + "/Contents/Info.plist")

if info != nil then
	## could read the plist file
	VER = info.objectForKey_("CFBundleShortVersionString")
	$stdout << VER
end