extends Node

func _ready():
    # Connect to AdMob signals
    AdMob.banner_loaded.connect(_on_banner_loaded)
    AdMob.banner_failed_to_load.connect(_on_banner_failed_to_load)
    AdMob.interstitial_loaded.connect(_on_interstitial_loaded)
    AdMob.interstitial_closed.connect(_on_interstitial_closed)
    AdMob.rewarded_user_earned_reward.connect(_on_rewarded_earned)
    
    # Load and show banner
    AdMob.load_banner(AdMob.BannerSize.ADAPTIVE_BANNER, AdMob.BannerPosition.BOTTOM)

func _on_banner_loaded():
    print("Banner loaded!")
    AdMob.show_banner()

func _on_banner_failed_to_load(error_code):
    print("Banner failed to load: ", error_code)

func load_interstitial():
    AdMob.load_interstitial()

func _on_interstitial_loaded():
    print("Interstitial loaded!")
    AdMob.show_interstitial()

func _on_interstitial_closed():
    print("Interstitial closed")

func load_rewarded():
    AdMob.load_rewarded_ad()

func _on_rewarded_earned(currency, amount):
    print("Reward earned: ", amount, " ", currency)
