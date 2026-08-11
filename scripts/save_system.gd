extends RefCounted

const SAVE_PATH := "user://save.json"
const BACKUP_PATH := "user://save_backup.json"
const SCHEMA_VERSION := 2

static func defaults() -> Dictionary:
	return {"schema_version":SCHEMA_VERSION,"night":1,"game_complete":false,"unlocked_endings":[]}

static func load_save() -> Dictionary:
	var data := _read_json(SAVE_PATH)
	if data.is_empty():
		data = _read_json(BACKUP_PATH)
	if data.is_empty():
		return defaults()
	return migrate(data)

static func migrate(input: Dictionary) -> Dictionary:
	var data := input.duplicate(true)
	var night := clampi(int(data.get("night",1)),1,6)
	data["night"] = night
	data["schema_version"] = SCHEMA_VERSION
	if typeof(data.get("unlocked_endings",[])) != TYPE_ARRAY:
		data["unlocked_endings"] = []
	data["game_complete"] = bool(data.get("game_complete",false))
	return data

static func write_save(data: Dictionary) -> bool:
	var safe := migrate(data)
	if FileAccess.file_exists(SAVE_PATH):
		var old := _read_json(SAVE_PATH)
		if not old.is_empty():
			_write_json(BACKUP_PATH, old)
	return _write_json(SAVE_PATH, safe)

static func reset_progress() -> void:
	for path in [SAVE_PATH,BACKUP_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

static func has_progress() -> bool:
	return FileAccess.file_exists(SAVE_PATH) or FileAccess.file_exists(BACKUP_PATH)

static func _read_json(path:String)->Dictionary:
	if not FileAccess.file_exists(path): return {}
	var f:=FileAccess.open(path,FileAccess.READ)
	if f==null:return {}
	var parsed:=JSON.parse_string(f.get_as_text())
	return parsed as Dictionary if typeof(parsed)==TYPE_DICTIONARY else {}

static func _write_json(path:String,data:Dictionary)->bool:
	var f:=FileAccess.open(path,FileAccess.WRITE)
	if f==null:return false
	f.store_string(JSON.stringify(data))
	return true
