extends Node

const L = preload("res://scripts/localization.gd")
const SAVE_PATH := "user://save.json"

var game: Node
var completed: bool = false

func _ready() -> void:
	call_deferred("_initialize")

func _initialize() -> void:
	game = get_parent()
	set_process(true)

func _process(_delta: float) -> void:
	if completed or game == null or not is_instance_valid(game):
		return
	var data: Dictionary = _read_save()
	if not bool(data.get("night_3_ready_for_finale", false)):
		return
	var minutes_value: Variant = game.get("shift_minutes")
	var minutes: float = float(minutes_value) if typeof(minutes_value) in [TYPE_FLOAT, TYPE_INT] else 0.0
	if minutes < 205.0:
		return
	completed = true
	call_deferred("_finish_night", data)

func _finish_night(data: Dictionary) -> void:
	var archive_correct: bool = bool(data.get("night_3_archive_correct", false))
	var physical_correct: bool = bool(data.get("night_3_physical_correct", false))
	var score: int = int(archive_correct) + int(physical_correct)
	var threat: int = int(data.get("threat_level", 0))
	var route: String = _night4_route(score, threat)
	if game.has_method("show_message"):
		game.call("show_message", _t(
			"NIGHT 3 COMPLETE\nReliable calls: %d / 2\nThe archive copied a frame that has not happened yet.",
			"НОЧЬ 3 ЗАВЕРШЕНА\nНадёжных решений: %d / 2\nАрхив скопировал кадр, который ещё не произошёл."
		) % score, 7.0)
	var objective_value: Variant = game.get("objective_label")
	if typeof(objective_value) == TYPE_OBJECT and objective_value is Label:
		(objective_value as Label).text = _t(
			"Tomorrow, the store will test whether you trust memory more than sight.",
			"Завтра магазин проверит, чему ты доверяешь больше: памяти или собственным глазам."
		)
	data["night"] = 4
	data["night_3_correct_total"] = score
	data["night_4_route"] = route
	data["night_3_complete"] = true
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))

func _night4_route(score: int, threat: int) -> String:
	if score >= 2 and threat <= 1:
		return "stable_memory"
	if score <= 0 or threat >= 3:
		return "contaminated_memory"
	return "uncertain_memory"

func _read_save() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed as Dictionary if typeof(parsed) == TYPE_DICTIONARY else {}

func _t(en: String, ru: String) -> String:
	return ru if L.get_language() == "ru" else en
