extends Control

@onready var status_label = $VBoxContainer/StatusLabel
@onready var reward_label = $VBoxContainer/RewardedSection/RewardLabel
@onready var show_interstitial_btn = $VBoxContainer/InterstitialSection/ShowInterstitialBtn
@onready var show_rewarded_btn = $VBoxContainer/RewardedSection/ShowRewardedBtn

var total_rewards = 0
var banner_visible = false
var admob = null

func _ready():
	# Try different ways to get AdMob singleton
	if Engine.has_singleton("GodotAdMob"):
		admob = Engine.get_singleton("GodotAdMob")
		print("Using native AdMob singleton")
	elif has_node("/root/AdMob"):
		admob = get_node("/root/AdMob")
		print("Using AdMob autoload singleton")
	else:
		# For standalone testing in the plugin project itself
		print("AdMob singleton not found, checking for standalone script")
		var standalone_script = load("res://addons/godot-admob-plugin/AdMobStandalone.gd")
		if standalone_script:
			admob = standalone_script.new()
			add_child(admob)
			print("Using standalone AdMob for testing")
		else:
			status_label.text = "Status: AdMob not available!"
			print("ERROR: Could not initialize AdMob")
			_disable_all_buttons()
			return
	
	_connect_signals()
	_connect_buttons()
	
	status_label.text = "Status: Initializing..."
	
	# Auto-load banner on start
	call_deferred("_load_banner")

func _disable_all_buttons():
	$VBoxContainer/BannerSection/ShowBannerBtn.disabled = true
	$VBoxContainer/BannerSection/HideBannerBtn.disabled = true
	$VBoxContainer/InterstitialSection/LoadInterstitialBtn.disabled = true
	show_interstitial_btn.disabled = true
	$VBoxContainer/RewardedSection/LoadRewardedBtn.disabled = true
	show_rewarded_btn.disabled = true

func _connect_signals():
	if not admob:
		return
		
	# Banner signals
	admob.banner_loaded.connect(_on_banner_loaded)
	admob.banner_failed_to_load.connect(_on_banner_failed_to_load)
	admob.banner_clicked.connect(_on_banner_clicked)
	
	# Interstitial signals
	admob.interstitial_loaded.connect(_on_interstitial_loaded)
	admob.interstitial_failed_to_load.connect(_on_interstitial_failed_to_load)
	admob.interstitial_opened.connect(_on_interstitial_opened)
	admob.interstitial_closed.connect(_on_interstitial_closed)
	
	# Rewarded ad signals
	admob.rewarded_ad_loaded.connect(_on_rewarded_ad_loaded)
	admob.rewarded_ad_failed_to_load.connect(_on_rewarded_ad_failed_to_load)
	admob.rewarded_ad_opened.connect(_on_rewarded_ad_opened)
	admob.rewarded_ad_closed.connect(_on_rewarded_ad_closed)
	admob.rewarded_user_earned_reward.connect(_on_rewarded_user_earned_reward)

func _connect_buttons():
	$VBoxContainer/BannerSection/ShowBannerBtn.pressed.connect(_on_show_banner_pressed)
	$VBoxContainer/BannerSection/HideBannerBtn.pressed.connect(_on_hide_banner_pressed)
	$VBoxContainer/InterstitialSection/LoadInterstitialBtn.pressed.connect(_on_load_interstitial_pressed)
	$VBoxContainer/InterstitialSection/ShowInterstitialBtn.pressed.connect(_on_show_interstitial_pressed)
	$VBoxContainer/RewardedSection/LoadRewardedBtn.pressed.connect(_on_load_rewarded_pressed)
	$VBoxContainer/RewardedSection/ShowRewardedBtn.pressed.connect(_on_show_rewarded_pressed)

# Banner Ad Functions
func _load_banner():
	if not admob:
		return
	status_label.text = "Status: Loading banner..."
	admob.load_banner(admob.BannerSize.ADAPTIVE_BANNER, admob.BannerPosition.BOTTOM)

func _on_show_banner_pressed():
	if not admob:
		return
	if not banner_visible:
		admob.show_banner()
		banner_visible = true
		status_label.text = "Status: Banner shown"

func _on_hide_banner_pressed():
	if not admob:
		return
	if banner_visible:
		admob.hide_banner()
		banner_visible = false
		status_label.text = "Status: Banner hidden"

func _on_banner_loaded():
	status_label.text = "Status: Banner loaded"
	if admob:
		admob.show_banner()
	banner_visible = true

func _on_banner_failed_to_load(error_code):
	status_label.text = "Status: Banner failed (Error: " + str(error_code) + ")"

func _on_banner_clicked():
	status_label.text = "Status: Banner clicked"

# Interstitial Ad Functions
func _on_load_interstitial_pressed():
	if not admob:
		return
	status_label.text = "Status: Loading interstitial..."
	show_interstitial_btn.disabled = true
	admob.load_interstitial()

func _on_show_interstitial_pressed():
	if not admob:
		return
	status_label.text = "Status: Showing interstitial..."
	admob.show_interstitial()

func _on_interstitial_loaded():
	status_label.text = "Status: Interstitial loaded"
	show_interstitial_btn.disabled = false

func _on_interstitial_failed_to_load(error_code):
	status_label.text = "Status: Interstitial failed (Error: " + str(error_code) + ")"
	show_interstitial_btn.disabled = true

func _on_interstitial_opened():
	status_label.text = "Status: Interstitial opened"

func _on_interstitial_closed():
	status_label.text = "Status: Interstitial closed"
	show_interstitial_btn.disabled = true

# Rewarded Ad Functions
func _on_load_rewarded_pressed():
	if not admob:
		return
	status_label.text = "Status: Loading rewarded ad..."
	show_rewarded_btn.disabled = true
	admob.load_rewarded_ad()

func _on_show_rewarded_pressed():
	if not admob:
		return
	status_label.text = "Status: Showing rewarded ad..."
	admob.show_rewarded_ad()

func _on_rewarded_ad_loaded():
	status_label.text = "Status: Rewarded ad loaded"
	show_rewarded_btn.disabled = false

func _on_rewarded_ad_failed_to_load(error_code):
	status_label.text = "Status: Rewarded ad failed (Error: " + str(error_code) + ")"
	show_rewarded_btn.disabled = true

func _on_rewarded_ad_opened():
	status_label.text = "Status: Rewarded ad opened"

func _on_rewarded_ad_closed():
	status_label.text = "Status: Rewarded ad closed"
	show_rewarded_btn.disabled = true

func _on_rewarded_user_earned_reward(currency: String, amount: int):
	total_rewards += amount
	reward_label.text = "Rewards: " + str(total_rewards)
	status_label.text = "Status: Earned " + str(amount) + " " + currency + "!"