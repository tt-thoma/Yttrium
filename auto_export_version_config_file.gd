extends "res://addons/AutoExportVersion/VersionProvider.gd"

func get_version(_features: PackedStringArray, _is_debug: bool, _path: String, _flags: int) -> String:
	var version: String = ""
	
	version += get_git_branch_name()
	version += "-1."
	version += get_git_commit_count()
	version += "."
	version += get_git_commit_hash()
	if _is_debug:
		version += "-DEBUG"
	else:
		version += "-RELEASE"
#	version += get_export_preset_version()
#	version += get_export_preset_android_version_code() + " " + get_export_preset_android_version_name()
	
	return version
