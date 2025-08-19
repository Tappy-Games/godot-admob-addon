extends Node

signal banner_loaded()
signal banner_failed_to_load(error_code: int)
signal banner_opened()
signal banner_closed()
signal banner_clicked()

signal interstitial_loaded()
signal interstitial_failed_to_load(error_code: int)
signal interstitial_opened()
signal interstitial_closed()

signal rewarded_ad_loaded()
signal rewarded_ad_failed_to_load(error_code: int)
signal rewarded_ad_opened()
signal rewarded_ad_closed()
signal rewarded_user_earned_reward(currency: String, amount: int)

var _admob_singleton = null
var _config = {}
var _is_initialized = false

const DEFAULT_CONFIG = {
	"app_id_android": "ca-app-pub-3940256099942544~3347511713",
	"app_id_ios": "ca-app-pub-3940256099942544~1458002511",
	"banner_id_android": "ca-app-pub-3940256099942544/6300978111",
	"banner_id_ios": "ca-app-pub-3940256099942544/2934735716",
	"interstitial_id_android": "ca-app-pub-3940256099942544/1033173712",
	"interstitial_id_ios": "ca-app-pub-3940256099942544/4411468910",
	"rewarded_id_android": "ca-app-pub-3940256099942544/5224354917",
	"rewarded_id_ios": "ca-app-pub-3940256099942544/1712485313",
	"test_mode": true,
	"child_directed": false,
	"max_ad_content_rating": "G",
	"test_device_ids": []
}

enum BannerPosition {
	TOP = 0,
	BOTTOM = 1,
	TOP_LEFT = 2,
	TOP_RIGHT = 3,
	BOTTOM_LEFT = 4,
	BOTTOM_RIGHT = 5,
	CENTER = 6
}

enum BannerSize {
	ADAPTIVE_BANNER = 0,
	SMART_BANNER = 1,
	BANNER = 2,
	MEDIUM_RECTANGLE = 3,
	FULL_BANNER = 4,
	LEADERBOARD = 5
}

func _ready():
	_load_config()
	_initialize_platform()

func _load_config():
	var config_path = "res://addons/godot-admob-plugin/admob_config.json"
	if FileAccess.file_exists(config_path):
		var file = FileAccess.open(config_path, FileAccess.READ)
		if file:
			var json_text = file.get_as_text()
			file.close()
			var json = JSON.new()
			var parse_result = json.parse(json_text)
			if parse_result == OK:
				_config = json.data
			else:
				push_error("Failed to parse AdMob config: " + json.error_string)
				_config = DEFAULT_CONFIG
	else:
		_config = DEFAULT_CONFIG
		_save_default_config(config_path)

func _save_default_config(path: String):
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		var json = JSON.new()
		file.store_string(json.stringify(DEFAULT_CONFIG, "\t"))
		file.close()

func _initialize_platform():
	if OS.get_name() == "Android":
		if Engine.has_singleton("GodotAdMob"):
			_admob_singleton = Engine.get_singleton("GodotAdMob")
			_connect_signals()
			_initialize_admob()
		else:
			push_error("AdMob Android plugin not found")
	elif OS.get_name() == "iOS":
		if Engine.has_singleton("GodotAdMob"):
			_admob_singleton = Engine.get_singleton("GodotAdMob")
			_connect_signals()
			_initialize_admob()
		else:
			push_error("AdMob iOS plugin not found")
	else:
		push_warning("AdMob is only supported on Android and iOS")

func _connect_signals():
	if _admob_singleton:
		_admob_singleton.connect("banner_loaded", _on_banner_loaded)
		_admob_singleton.connect("banner_failed_to_load", _on_banner_failed_to_load)
		_admob_singleton.connect("banner_opened", _on_banner_opened)
		_admob_singleton.connect("banner_closed", _on_banner_closed)
		_admob_singleton.connect("banner_clicked", _on_banner_clicked)
		
		_admob_singleton.connect("interstitial_loaded", _on_interstitial_loaded)
		_admob_singleton.connect("interstitial_failed_to_load", _on_interstitial_failed_to_load)
		_admob_singleton.connect("interstitial_opened", _on_interstitial_opened)
		_admob_singleton.connect("interstitial_closed", _on_interstitial_closed)
		
		_admob_singleton.connect("rewarded_ad_loaded", _on_rewarded_ad_loaded)
		_admob_singleton.connect("rewarded_ad_failed_to_load", _on_rewarded_ad_failed_to_load)
		_admob_singleton.connect("rewarded_ad_opened", _on_rewarded_ad_opened)
		_admob_singleton.connect("rewarded_ad_closed", _on_rewarded_ad_closed)
		_admob_singleton.connect("rewarded_user_earned_reward", _on_rewarded_user_earned_reward)

func _initialize_admob():
	if not _admob_singleton:
		return
	
	var app_id = ""
	if OS.get_name() == "Android":
		app_id = _config.get("app_id_android", DEFAULT_CONFIG["app_id_android"])
	else:
		app_id = _config.get("app_id_ios", DEFAULT_CONFIG["app_id_ios"])
	
	var test_mode = _config.get("test_mode", true)
	var child_directed = _config.get("child_directed", false)
	var max_rating = _config.get("max_ad_content_rating", "G")
	var test_devices = _config.get("test_device_ids", [])
	
	_admob_singleton.initialize(app_id, test_mode, child_directed, max_rating, test_devices)
	_is_initialized = true

func load_banner(size: BannerSize = BannerSize.ADAPTIVE_BANNER, position: BannerPosition = BannerPosition.BOTTOM):
	if not _admob_singleton or not _is_initialized:
		push_error("AdMob not initialized")
		return
	
	var banner_id = ""
	if OS.get_name() == "Android":
		banner_id = _config.get("banner_id_android", DEFAULT_CONFIG["banner_id_android"])
	else:
		banner_id = _config.get("banner_id_ios", DEFAULT_CONFIG["banner_id_ios"])
	
	_admob_singleton.load_banner(banner_id, size, position)

func show_banner():
	if _admob_singleton:
		_admob_singleton.show_banner()

func hide_banner():
	if _admob_singleton:
		_admob_singleton.hide_banner()

func destroy_banner():
	if _admob_singleton:
		_admob_singleton.destroy_banner()

func load_interstitial():
	if not _admob_singleton or not _is_initialized:
		push_error("AdMob not initialized")
		return
	
	var interstitial_id = ""
	if OS.get_name() == "Android":
		interstitial_id = _config.get("interstitial_id_android", DEFAULT_CONFIG["interstitial_id_android"])
	else:
		interstitial_id = _config.get("interstitial_id_ios", DEFAULT_CONFIG["interstitial_id_ios"])
	
	_admob_singleton.load_interstitial(interstitial_id)

func show_interstitial():
	if _admob_singleton:
		_admob_singleton.show_interstitial()

func load_rewarded_ad():
	if not _admob_singleton or not _is_initialized:
		push_error("AdMob not initialized")
		return
	
	var rewarded_id = ""
	if OS.get_name() == "Android":
		rewarded_id = _config.get("rewarded_id_android", DEFAULT_CONFIG["rewarded_id_android"])
	else:
		rewarded_id = _config.get("rewarded_id_ios", DEFAULT_CONFIG["rewarded_id_ios"])
	
	_admob_singleton.load_rewarded_ad(rewarded_id)

func show_rewarded_ad():
	if _admob_singleton:
		_admob_singleton.show_rewarded_ad()

func _on_banner_loaded():
	banner_loaded.emit()

func _on_banner_failed_to_load(error_code: int):
	banner_failed_to_load.emit(error_code)

func _on_banner_opened():
	banner_opened.emit()

func _on_banner_closed():
	banner_closed.emit()

func _on_banner_clicked():
	banner_clicked.emit()

func _on_interstitial_loaded():
	interstitial_loaded.emit()

func _on_interstitial_failed_to_load(error_code: int):
	interstitial_failed_to_load.emit(error_code)

func _on_interstitial_opened():
	interstitial_opened.emit()

func _on_interstitial_closed():
	interstitial_closed.emit()

func _on_rewarded_ad_loaded():
	rewarded_ad_loaded.emit()

func _on_rewarded_ad_failed_to_load(error_code: int):
	rewarded_ad_failed_to_load.emit(error_code)

func _on_rewarded_ad_opened():
	rewarded_ad_opened.emit()

func _on_rewarded_ad_closed():
	rewarded_ad_closed.emit()

func _on_rewarded_user_earned_reward(currency: String, amount: int):
	rewarded_user_earned_reward.emit(currency, amount)