extends Node

var game: Node

func _ready() -> void:
	call_deferred("_apply_layout")

func _apply_layout() -> void:
	game = get_parent()
	if game == null:
		return

	# VisualPass creates the rendered feed deferred as well, so wait two frames
	# before applying the final 1280x720 safe-area layout.
	await get_tree().process_frame
	await get_tree().process_frame

	var overlay_value: Variant = game.get("cctv_overlay")
	if typeof(overlay_value) != TYPE_OBJECT or overlay_value == null or not is_instance_valid(overlay_value):
		return
	var overlay: ColorRect = overlay_value as ColorRect
	if overlay == null:
		return

	# Opaque background prevents the normal HUD / QA labels from bleeding through.
	overlay.color = Color(0.008, 0.014, 0.012, 1.0)

	var camera_label_value: Variant = game.get("cctv_camera_label")
	if typeof(camera_label_value) == TYPE_OBJECT and camera_label_value != null and is_instance_valid(camera_label_value):
		var camera_label: Label = camera_label_value as Label
		if camera_label != null:
			camera_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
			camera_label.position = Vector2(42, 24)
			camera_label.size = Vector2(430, 44)
			camera_label.add_theme_font_size_override("font_size", 25)

	var feed_value: Variant = game.get("cctv_feed_label")
	if typeof(feed_value) == TYPE_OBJECT and feed_value != null and is_instance_valid(feed_value):
		var feed: Label = feed_value as Label
		if feed != null:
			feed.set_anchors_preset(Control.PRESET_TOP_LEFT)
			feed.position = Vector2(42, 188)
			feed.size = Vector2(330, 235)
			feed.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			feed.vertical_alignment = VERTICAL_ALIGNMENT_TOP
			feed.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			feed.add_theme_font_size_override("font_size", 17)

	# Find supporting controls created by VisualPass/Main and move them into a
	# consistent safe area without depending on their creation order.
	for child: Node in overlay.get_children():
		if child is TextureRect and child.name == "RenderedFeed":
			var rendered: TextureRect = child as TextureRect
			rendered.offset_left = 176.0
			rendered.offset_top = 82.0
			rendered.offset_right = -176.0
			rendered.offset_bottom = -128.0
		elif child is Label:
			var label: Label = child as Label
			if "MORROW SECURITY" in label.text:
				label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
				label.position = Vector2(-325, 28)
				label.size = Vector2(285, 34)
				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
				label.add_theme_font_size_override("font_size", 14)
		elif child is HBoxContainer:
			var nav: HBoxContainer = child as HBoxContainer
			nav.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
			nav.position = Vector2(-225, -62)
			nav.size = Vector2(450, 42)

	var noise_value: Variant = game.get("cctv_noise")
	if typeof(noise_value) == TYPE_OBJECT and noise_value != null and is_instance_valid(noise_value):
		var noise: Label = noise_value as Label
		if noise != null:
			noise.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
			noise.position = Vector2(-300, -118)
			noise.size = Vector2(600, 36)
			noise.add_theme_font_size_override("font_size", 20)
