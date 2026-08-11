extends RefCounted

const SETTINGS_PATH := "user://settings.cfg"
const DEFAULT_LANGUAGE := "en"
const SUPPORTED_LANGUAGES := ["en", "ru"]

const TEXT := {
	"en": {
		"title":"THE 03:17\nCUSTOMER", "subtitle":"EVERY CUSTOMER LOOKS HUMAN.\nNOT EVERY CUSTOMER IS.",
		"new_shift":"NEW SHIFT", "continue":"CONTINUE", "settings":"SETTINGS", "credits":"CREDITS", "quit":"QUIT",
		"system_settings":"SYSTEM SETTINGS", "master_volume":"MASTER VOLUME", "fullscreen":"FULLSCREEN", "language":"LANGUAGE",
		"english":"ENGLISH", "russian":"RUSSIAN", "back":"BACK", "settings_note":"More graphics, controls and accessibility settings will be added as the vertical slice grows.",
		"no_save":"No saved shift found.", "resume_save":"Resume your last shift.", "cam_parking":"CAM 05 / PARKING LOT",
		"signal_ok":"SIGNAL OK", "tracking":"TRACKING...", "no_motion":"NO MOTION", "event_pending":"03:17 EVENT PENDING",
		"security_footer":"MORROW MARKET SECURITY SYSTEM / BUILD 0.1",
		"night_intro":"NIGHT 1 — 00:00\nYour first shift at Morrow Market.", "objective_note":"OBJECTIVE: Read the manager's note beside the register.",
		"manager_note":"MANAGER'S NOTE\n\nDo the normal closing tasks.\nLock the stockroom after 02:00.\nIf the cameras cut out, stay inside.\n\nIf a customer arrives at 03:17 — DO NOT SERVE THEM.",
		"objective_continue":"OBJECTIVE: Continue your shift.", "warning_0230":"02:30\nThe fluorescent lights buzz louder than before.",
		"objective_watch":"OBJECTIVE: Keep an eye on the entrance and CCTV.", "quiet_0310":"03:10\nThe parking lot has gone completely quiet.",
		"arrival_0317":"03:17\nThe entrance chime rings.\nNo footsteps follow it.", "objective_check":"OBJECTIVE: Check the customer. Remember the manager's rule.",
		"unknown_line":"Unknown Customer: \"Long night?\"\n\nA bottle of water rests on the counter.", "night_complete":"NIGHT 1 COMPLETE\nSomething is wrong with Morrow Market.",
		"serve":"SERVE CUSTOMER", "refuse":"REFUSE SERVICE", "credits_body":"THE 03:17 CUSTOMER\n\nCreated by Benzilya\n\nPrototype development\nOpenAI / ChatGPT collaboration\n\nEngine\nGodot 4\n\nAll art and audio used in release builds will be original, licensed, or properly attributed."
	},
	"ru": {
		"title":"ПОКУПАТЕЛЬ\n03:17", "subtitle":"КАЖДЫЙ ПОКУПАТЕЛЬ ВЫГЛЯДИТ ЧЕЛОВЕКОМ.\nНО НЕ КАЖДЫЙ ИМ ЯВЛЯЕТСЯ.",
		"new_shift":"НОВАЯ СМЕНА", "continue":"ПРОДОЛЖИТЬ", "settings":"НАСТРОЙКИ", "credits":"АВТОРЫ", "quit":"ВЫХОД",
		"system_settings":"СИСТЕМНЫЕ НАСТРОЙКИ", "master_volume":"ОБЩАЯ ГРОМКОСТЬ", "fullscreen":"ПОЛНЫЙ ЭКРАН", "language":"ЯЗЫК",
		"english":"АНГЛИЙСКИЙ", "russian":"РУССКИЙ", "back":"НАЗАД", "settings_note":"По мере развития игры здесь появятся дополнительные настройки графики, управления и доступности.",
		"no_save":"Сохранённая смена не найдена.", "resume_save":"Продолжить последнюю смену.", "cam_parking":"КАМ 05 / ПАРКОВКА",
		"signal_ok":"СИГНАЛ В НОРМЕ", "tracking":"ОТСЛЕЖИВАНИЕ...", "no_motion":"ДВИЖЕНИЕ НЕ ОБНАРУЖЕНО", "event_pending":"ОЖИДАНИЕ СОБЫТИЯ 03:17",
		"security_footer":"СИСТЕМА БЕЗОПАСНОСТИ MORROW MARKET / СБОРКА 0.1",
		"night_intro":"НОЧЬ 1 — 00:00\nТвоя первая смена в Morrow Market.", "objective_note":"ЗАДАЧА: Прочитай записку менеджера возле кассы.",
		"manager_note":"ЗАПИСКА МЕНЕДЖЕРА\n\nВыполняй обычные задачи ночной смены.\nПосле 02:00 запри склад.\nЕсли камеры отключатся — оставайся внутри.\n\nЕсли покупатель придёт в 03:17 — НЕ ОБСЛУЖИВАЙ ЕГО.",
		"objective_continue":"ЗАДАЧА: Продолжай смену.", "warning_0230":"02:30\nЛюминесцентные лампы гудят громче обычного.",
		"objective_watch":"ЗАДАЧА: Следи за входом и камерами наблюдения.", "quiet_0310":"03:10\nНа парковке стало совершенно тихо.",
		"arrival_0317":"03:17\nЗвенит дверной колокольчик.\nНо шагов не слышно.", "objective_check":"ЗАДАЧА: Проверь покупателя. Помни правило менеджера.",
		"unknown_line":"Неизвестный покупатель: «Долгая ночь?»\n\nНа стойке стоит бутылка воды.", "night_complete":"НОЧЬ 1 ЗАВЕРШЕНА\nС Morrow Market что-то не так.",
		"serve":"ОБСЛУЖИТЬ ПОКУПАТЕЛЯ", "refuse":"ОТКАЗАТЬ В ОБСЛУЖИВАНИИ", "credits_body":"THE 03:17 CUSTOMER\n\nАвтор: Benzilya\n\nРазработка прототипа\nпри поддержке OpenAI / ChatGPT\n\nДвижок\nGodot 4\n\nВ финальной версии будут использоваться только оригинальные, лицензированные или корректно атрибутированные материалы."
	}
}

static func get_language() -> String:
	var config: ConfigFile = ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		var saved: String = str(config.get_value("display", "language", DEFAULT_LANGUAGE))
		if saved in SUPPORTED_LANGUAGES:
			return saved
	return DEFAULT_LANGUAGE

static func set_language(language: String) -> void:
	var safe_language: String = language if language in SUPPORTED_LANGUAGES else DEFAULT_LANGUAGE
	var config: ConfigFile = ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value("display", "language", safe_language)
	config.save(SETTINGS_PATH)

static func tr_key(key: String, language: String = "") -> String:
	var lang: String = language if language != "" else get_language()
	if not TEXT.has(lang):
		lang = DEFAULT_LANGUAGE
	var table: Dictionary = TEXT[lang]
	return str(table.get(key, key))
