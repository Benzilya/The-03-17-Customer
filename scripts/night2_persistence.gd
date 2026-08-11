extends Node

# M9 persistence bridge. Keeps Night 2 consequence data in save.json so
# Nights 3–4 can react to how safely the player handled anomaly verification.

const SAVE_PATH := "user://save.json"

var game: Node
var written: bool = false

func _ready() -> void:
	call_deferred("_initialize")

func _initialize() -> void:
	game = get_parent()
	set_process(true)

func _process(_delta: float) -> void:
	if written or game == null or not is_instance_valid(game):
		return
	var locked_value: Variant = game.get("night_locked")
	var total_value: Variant = game.get("total_decisions")
	if typeof(locked_value) != TYPE_BOOL or typeof(total_value) != TYPE_INT:
		return
	if not bool(locked_value) or int(total_value) < 4:
		return
	written = true
	call_deferred("_write_carryover")

func _write_carryover() -> void:
	# Let Night2 write its basic result first, then merge consequence fields.
	await get_tree().process_frame
	await get_tree().process_frame
	var data: Dictionary = _read_save()
	var correct_value: Variant = game.get("correct_decisions")
	var total_value: Variant = game.get("total_decisions")
	var correct: int = int(correct_value) if typeof(correct_value) == TYPE_INT else 0
	var total: int = int(total_value) if typeof(total_value) == TYPE_INT else 4
	var wrong: int = maxi(0, total - correct)
	var threat: int = clampi(wrong, 0, 4)
	data["night"] = 3
	data["night_2_correct"] = correct
	data["night_2_total"] = total
	data["night_2_wrong"] = wrong
	data["threat_level"] = threat
	data["ignored_anomaly"] = wrong > 0
	data["night_3_opening"] = _opening_key(threat)
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))

func _read_save() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed as Dictionary if typeof(parsed) == TYPE_DICTIONARY else {}

func _opening_key(threat: int) -> String:
	if threat <= 0:
		return "clean_shift"
	if threat == 1:
		return "minor_breach"
	if threat <= 3:
		return "active_breach"
	return "critical_breach"
