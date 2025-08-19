extends Node
# Visual test ad system for displaying real-looking ads in editor

static func create_test_banner(parent: Node, size: int, position: int) -> Control:
	var banner = ColorRect.new()
	banner.name = "TestBanner"
	
	# Set banner size
	var banner_size = Vector2(320, 50)  # Default banner size
	match size:
		0: banner_size = Vector2(320, 50)   # ADAPTIVE_BANNER (simplified)
		1: banner_size = Vector2(320, 50)   # SMART_BANNER
		2: banner_size = Vector2(320, 50)   # BANNER
		3: banner_size = Vector2(300, 250)  # MEDIUM_RECTANGLE
		4: banner_size = Vector2(468, 60)   # FULL_BANNER
		5: banner_size = Vector2(728, 90)   # LEADERBOARD
	
	banner.custom_minimum_size = banner_size
	banner.color = Color(0.2, 0.2, 0.8, 0.9)
	
	# Add border
	var border = ReferenceRect.new()
	border.border_color = Color.WHITE
	border.border_width = 2
	border.anchors_preset = Control.PRESET_FULL_RECT
	banner.add_child(border)
	
	# Add test ad content
	var label = Label.new()
	label.text = "Google Test Ad\n(AdMob)"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.anchors_preset = Control.PRESET_FULL_RECT
	label.add_theme_color_override("font_color", Color.WHITE)
	banner.add_child(label)
	
	# Position the banner
	banner.anchors_preset = Control.PRESET_CENTER
	match position:
		0: # TOP
			banner.anchors_preset = Control.PRESET_TOP_WIDE
			banner.anchor_bottom = 0.0
			banner.offset_bottom = banner_size.y
		1: # BOTTOM
			banner.anchors_preset = Control.PRESET_BOTTOM_WIDE
			banner.anchor_top = 1.0
			banner.offset_top = -banner_size.y
		6: # CENTER
			banner.anchors_preset = Control.PRESET_CENTER
		_: # Default to bottom
			banner.anchors_preset = Control.PRESET_BOTTOM_WIDE
			banner.anchor_top = 1.0
			banner.offset_top = -banner_size.y
	
	# Make it clickable
	var button = Button.new()
	button.flat = true
	button.anchors_preset = Control.PRESET_FULL_RECT
	button.pressed.connect(_on_test_ad_clicked)
	banner.add_child(button)
	
	parent.add_child(banner)
	return banner

static func _on_test_ad_clicked():
	print("[AdMob] Test ad clicked - would open browser")

static func create_test_interstitial(parent: Node) -> Control:
	var interstitial = ColorRect.new()
	interstitial.name = "TestInterstitial"
	interstitial.color = Color(0.1, 0.1, 0.1, 0.95)
	interstitial.anchors_preset = Control.PRESET_FULL_RECT
	
	# Create ad content container
	var ad_container = ColorRect.new()
	ad_container.color = Color(0.3, 0.3, 0.9, 1.0)
	ad_container.anchors_preset = Control.PRESET_CENTER
	ad_container.custom_minimum_size = Vector2(300, 400)
	
	# Add border
	var border = ReferenceRect.new()
	border.border_color = Color.WHITE
	border.border_width = 3
	border.anchors_preset = Control.PRESET_FULL_RECT
	ad_container.add_child(border)
	
	# Add content
	var vbox = VBoxContainer.new()
	vbox.anchors_preset = Control.PRESET_FULL_RECT
	vbox.add_theme_constant_override("separation", 20)
	
	var title = Label.new()
	title.text = "Test Interstitial Ad"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color.WHITE)
	title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title)
	
	var content = Label.new()
	content.text = "This is a Google AdMob\ntest interstitial advertisement.\n\nIn a real app, this would show\na full-screen ad from an advertiser."
	content.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	content.add_theme_color_override("font_color", Color.WHITE)
	content.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(content)
	
	# Close button
	var close_btn = Button.new()
	close_btn.text = "Close Ad (X)"
	close_btn.custom_minimum_size.y = 40
	vbox.add_child(close_btn)
	
	ad_container.add_child(vbox)
	interstitial.add_child(ad_container)
	
	# Connect close button
	close_btn.pressed.connect(func(): 
		print("[AdMob] Test interstitial closed")
		interstitial.queue_free()
	)
	
	parent.add_child(interstitial)
	return interstitial

static func create_test_rewarded(parent: Node, reward_callback: Callable) -> Control:
	var rewarded = ColorRect.new()
	rewarded.name = "TestRewarded"
	rewarded.color = Color(0.1, 0.1, 0.1, 0.95)
	rewarded.anchors_preset = Control.PRESET_FULL_RECT
	
	# Create ad content container
	var ad_container = ColorRect.new()
	ad_container.color = Color(0.9, 0.6, 0.2, 1.0)  # Orange for rewarded
	ad_container.anchors_preset = Control.PRESET_CENTER
	ad_container.custom_minimum_size = Vector2(350, 450)
	
	# Add border
	var border = ReferenceRect.new()
	border.border_color = Color.WHITE
	border.border_width = 3
	border.anchors_preset = Control.PRESET_FULL_RECT
	ad_container.add_child(border)
	
	# Add content
	var vbox = VBoxContainer.new()
	vbox.anchors_preset = Control.PRESET_FULL_RECT
	vbox.add_theme_constant_override("separation", 15)
	
	var title = Label.new()
	title.text = "Rewarded Video Ad"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color.WHITE)
	title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title)
	
	var content = Label.new()
	content.text = "Watch this ad to earn rewards!\n\nThis is a Google AdMob test ad.\nNormally you'd see a video here."
	content.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	content.add_theme_color_override("font_color", Color.WHITE)
	content.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(content)
	
	# Progress bar (simulated video progress)
	var progress_label = Label.new()
	progress_label.text = "Ad Progress:"
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress_label.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(progress_label)
	
	var progress_bar = ProgressBar.new()
	progress_bar.max_value = 100
	progress_bar.value = 0
	progress_bar.custom_minimum_size.y = 20
	vbox.add_child(progress_bar)
	
	# Buttons
	var button_container = HBoxContainer.new()
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var close_btn = Button.new()
	close_btn.text = "Skip"
	close_btn.custom_minimum_size = Vector2(80, 40)
	button_container.add_child(close_btn)
	
	var reward_btn = Button.new()
	reward_btn.text = "Claim Reward"
	reward_btn.custom_minimum_size = Vector2(120, 40)
	reward_btn.disabled = true
	button_container.add_child(reward_btn)
	
	vbox.add_child(button_container)
	
	ad_container.add_child(vbox)
	rewarded.add_child(ad_container)
	
	# Animate progress bar
	var tween = rewarded.create_tween()
	tween.tween_property(progress_bar, "value", 100, 3.0)
	tween.tween_callback(func():
		reward_btn.disabled = false
		progress_label.text = "Ad Complete! Claim your reward:"
	)
	
	# Connect buttons
	close_btn.pressed.connect(func(): 
		print("[AdMob] Test rewarded ad skipped")
		rewarded.queue_free()
	)
	
	reward_btn.pressed.connect(func():
		print("[AdMob] Test rewarded ad completed - earning reward")
		reward_callback.call("coins", 10)
		rewarded.queue_free()
	)
	
	parent.add_child(rewarded)
	return rewarded