extends RefCounted

const SETTINGS_PATH := "user://settings.cfg"
const DEFAULT_LANGUAGE := "en"
const SUPPORTED_LANGUAGES := ["en", "ru"]

const TEXT := {
	"en": {
		"title": "THE 03:17\nCUSTOMER",
		"subtitle": "EVERY CUSTOMER LOOKS HUMAN.\nNOT EVERY CUSTOMER IS.",
		"new_shift": "NEW SHIFT",
		"continue": "CONTINUE",
		"settings": "SETTINGS",
		"credits": "CREDITS",
		"quit": "QUIT",
		"system_settings": "SYSTEM SETTINGS",
		"master_volume": "MASTER VOLUME",
		"fullscreen": "FULLSCREEN",
		"language": "LANGUAGE",
		"english": "ENGLISH",
		"russian": "RUSSIAN",
		"back": "BACK",
		"settings_note": "More graphics, controls and accessibility settings will be added as the vertical slice grows.",
		"no_save": "No saved shift found.",
		"resume_save": "Resume your last shift.",
		"cam_parking": "CAM 05 / PARKING LOT",
		"signal_ok": "SIGNAL OK",
		"tracking": "TRACKING...",
		"no_motion": "NO MOTION",
		"event_pending": "03:17 EVENT PENDING",
		"security_footer": "MORROW MARKET SECURITY SYSTEM / BUILD 0.1",
		"credits_body": "THE 03:17 CUSTOMER\n\nCreated by Benzilya\n\nPrototype development\nOpenAI / ChatGPT collaboration\n\nEngine\nGodot 4\n\nAll art and audio used in release builds will be original, licensed, or properly attributed."
	},
	"ru": {
		"title": "ПОКУПАТЕЛЬ\n03:17",
		"subtitle": "КАЖДЫЙ ПОКУПАТЕЛЬ ВЫГЛЯДИТ ЧЕЛОВЕКОМ.\nНО НЕ КАЖДЫЙ ИМ ЯВЛЯЕТСЯ.",
		"new_shift": "НОВАЯ СМЕНА",
		"continue": "ПРОДОЛЖИТЬ",
		"settings": "НАСТРОЙКИ",
		"credits": "АВТОРЫ",
		"quit": "ВЫХОД",
		"system_settings": "СИСТЕМНЫЕ НАСТРОЙКИ",
		"master_volume": "ОБЩАЯ ГРОМКОСТЬ",
		"fullscreen": "ПОЛНЫЙ ЭКРАН",
		"language": "ЯЗЫК",
		"english": "АНГЛИЙСКИЙ",
		"russian": "РУССКИЙ",
		"back": "НАЗАД",
		"settings_note": "По мере развития игры здесь появятся дополнительные настройки графики, управления и доступности.",
		"no_save": "Сохранённая смена не найдена.",
		"resume_save": "Продолжить последнюю смену.",
		"cam_parking": "КАМ 05 / ПАРКОВКА",
		"signal_ok": "СИГНАЛ В НОРМЕ",
		"tracking": "ОТСЛЕЖИВАНИЕ...",
		"no_motion": "ДВИЖЕНИЕ НЕ ОБНАРУЖЕНО",
		"event_pending": "ОЖИДАНИЕ СОБЫТИЯ 03:17",
		"security_footer": "СИСТЕМА БЕЗОПАСНОСТИ MORROW MARKET / СБОРКА 0.1",
		"credits_body": "THE 03:17 CUSTOMER\n\nАвтор: Benzilya\n\nРазработка прототипа\nпри поддержке OpenAI / ChatGPT\n\nДвижок\nGodot 4\n\nВ финальной версии будут использоваться только оригинальные, лицензированные или корректно атрибутированные материалы."
	}
}

static func get_language() -> String:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		var saved := str(config.get_value("display", "language", DEFAULT_LANGUAGE))
		if saved in SUPPORTED_LANGUAGES:
			return saved
	return DEFAULT_LANGUAGE

static func set_language(language: String) -> void:
	var safe_language := language if language in SUPPORTED_LANGUAGES else DEFAULT_LANGUAGE
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value("display", "language", safe_language)
	config.save(SETTINGS_PATH)

static func tr_key(key: String, language: String = "") -> String:
	var lang := language if language != "" else get_language()
	if not TEXT.has(lang):
		lang = DEFAULT_LANGUAGE
	var table: Dictionary = TEXT[lang]
	return str(table.get(key, key))
