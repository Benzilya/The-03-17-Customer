extends Node3D

const INTERACTABLE = preload("res://scripts/interactable.gd")
const CUSTOMER = preload("res://scripts/customer.gd")
const L = preload("res://scripts/localization.gd")

var message_label: Label
var clock_label: Label
var objective_label: Label
var interaction_hint: Label
var message_timer: Timer
var shift_minutes: float = 0.0
var shift_speed: float = 12.0
var event_flags: Dictionary = {}
var active_customer: Node3D
var decision_panel: PanelContainer
var checkout_panel: PanelContainer
var checkout_items: VBoxContainer
var checkout_total: Label
var checkout_action: Button
var cctv_overlay: ColorRect
var cctv_feed_label: Label
var cctv_camera_label: Label
var cctv_noise: Label
var cctv_camera: int = 1
var cctv_open: bool = false
var cctv_status: String = "No anomalies detected."
var note_read: bool = false
var current_items: Array[Dictionary] = []
var scanned_count: int = 0
var transaction_customer: String = ""
var transaction_callback: Callable
var night_locked: bool = false

func _ready() -> void:
	add_to_group("game")
	build_environment()
	build_store()
	build_ui()
	show_message(L.tr_key("night_intro"), 5.0)
	objective_label.text = L.tr_key("objective_note")

func _process(delta: float) -> void:
	if not night_locked:
		shift_minutes += delta * shift_speed
	var total_minutes: int = int(shift_minutes) % 360
	var hour: int = int(total_minutes / 60)
	var minute: int = total_minutes % 60
	clock_label.text = "%02d:%02d" % [hour, minute]
	run_night_events(total_minutes)
	if cctv_open:
		update_cctv_feed(total_minutes)

func run_night_events(total_minutes: int) -> void:
	if total_minutes >= 8 and not event_flags.has("customer_1"):
		event_flags["customer_1"] = true
		spawn_customer("Late Driver", false, Color(0.25, 0.34, 0.46), "Coffee. Black. Long road ahead.", [
			{"name":"Black Coffee", "price":2.49}, {"name":"Beef Jerky", "price":3.99}
		])
	if total_minutes >= 72 and not event_flags.has("customer_2"):
		event_flags["customer_2"] = true
		spawn_customer("Nurse", false, Color(0.36, 0.42, 0.38), "Just water, please. Night shift too?", [
			{"name":"Spring Water", "price":1.79}
		])
	if total_minutes >= 150 and not event_flags.has("warning"):
		event_flags["warning"] = true
		show_message(L.tr_key("warning_0230"), 4.0)
		cctv_status = "SIGNAL NOISE INCREASING"
	if total_minutes >= 190 and not event_flags.has("pre_317"):
		event_flags["pre_317"] = true
		objective_label.text = L.tr_key("objective_watch")
		show_message(L.tr_key("quiet_0310"), 4.0)
	if total_minutes >= 197 and not event_flags.has("customer_317"):
		event_flags["customer_317"] = true
		shift_minutes = 197.0
		night_locked = true
		clock_label.text = "03:17"
		spawn_317_customer()

func spawn_customer(customer_name: String, anomalous: bool, body_color: Color, line: String, items: Array[Dictionary]) -> void:
	if active_customer and is_instance_valid(active_customer):
		active_customer.queue_free()
	active_customer = CUSTOMER.new()
	add_child(active_customer)
	active_customer.global_position = Vector3(0, 0, -9.5)
	active_customer.setup(customer_name, anomalous, body_color)
	await active_customer.walk_to(Vector3(3.4, 0, -2.8), 2.2)
	show_message(customer_name + ": \"" + line + "\"", 4.0)
	objective_label.text = "OBJECTIVE: Ring up " + customer_name + " at REGISTER 01."
	begin_transaction(customer_name, items, func() -> void: finish_normal_customer(customer_name))

func finish_normal_customer(customer_name: String) -> void:
	show_message("PAYMENT APPROVED\n" + customer_name + " takes the receipt and leaves.", 3.5)
	objective_label.text = L.tr_key("objective_continue")
	if active_customer and is_instance_valid(active_customer):
		await active_customer.walk_to(Vector3(0, 0, -9.5), 2.0)
		active_customer.queue_free()

func spawn_317_customer() -> void:
	if active_customer and is_instance_valid(active_customer):
		active_customer.queue_free()
	active_customer = CUSTOMER.new()
	add_child(active_customer)
	active_customer.global_position = Vector3(0, 0, -9.5)
	active_customer.setup("Unknown Customer", true, Color(0.10, 0.105, 0.12))
	cctv_status = "CAMERA MISMATCH"
	show_message(L.tr_key("arrival_0317"), 5.0)
	await active_customer.walk_to(Vector3(3.4, 0, -2.8), 3.0)
	objective_label.text = L.tr_key("objective_check")
	show_message(L.tr_key("unknown_line"), 5.0)
	await get_tree().create_timer(1.5).timeout
	show_decision()

func begin_transaction(customer_name: String, items: Array[Dictionary], callback: Callable) -> void:
	transaction_customer = customer_name
	current_items = items
	scanned_count = 0
	transaction_callback = callback
	update_checkout_ui()

func open_checkout() -> void:
	if current_items.is_empty():
		show_message("REGISTER 01\nNo customer is waiting.", 2.5)
		return
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	checkout_panel.visible = true
	update_checkout_ui()

func update_checkout_ui() -> void:
	if not checkout_items:
		return
	for child: Node in checkout_items.get_children():
		child.queue_free()
	var total: float = 0.0
	for i: int in range(current_items.size()):
		var item: Dictionary = current_items[i]
		var row: Label = Label.new()
		var prefix: String = "[SCANNED] " if i < scanned_count else "[WAITING] "
		row.text = "%s%s   $%.2f" % [prefix, item["name"], item["price"]]
		row.modulate = Color(0.62, 0.95, 0.70) if i < scanned_count else Color(0.82, 0.84, 0.86)
		checkout_items.add_child(row)
		if i < scanned_count:
			total += float(item["price"])
	checkout_total.text = "TOTAL  $%.2f" % total
	checkout_action.text = "SCAN NEXT ITEM" if scanned_count < current_items.size() else "TAKE PAYMENT"

func checkout_action_pressed() -> void:
	if scanned_count < current_items.size():
		scanned_count += 1
		update_checkout_ui()
		return
	checkout_panel.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	current_items.clear()
	var callback: Callable = transaction_callback
	transaction_callback = Callable()
	if callback.is_valid():
		callback.call()

func close_checkout() -> void:
	checkout_panel.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func open_cctv() -> void:
	cctv_open = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	cctv_overlay.visible = true
	update_cctv_feed(int(shift_minutes))

func close_cctv() -> void:
	cctv_open = false
	cctv_overlay.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func cycle_cctv(direction: int) -> void:
	cctv_camera += direction
	if cctv_camera < 1: cctv_camera = 4
	if cctv_camera > 4: cctv_camera = 1
	update_cctv_feed(int(shift_minutes))

func update_cctv_feed(total_minutes: int) -> void:
	var names: Dictionary = {1:"REGISTER", 2:"AISLES", 3:"ENTRANCE", 4:"STOCKROOM"}
	cctv_camera_label.text = "CAM %02d / %s" % [cctv_camera, names[cctv_camera]]
	var feed: String = "FEED STABLE"
	if total_minutes >= 150: feed = "INTERMITTENT STATIC"
	if total_minutes >= 197:
		if cctv_camera == 1: feed = "CASHIER DETECTED\nCUSTOMER: NOT DETECTED"
		elif cctv_camera == 3: feed = "ENTRANCE DOOR: OPEN\nPERSON DETECTION: 0"
		else: feed = "FRAME DESYNC / 03:17:00"
	cctv_feed_label.text = feed + "\n\n" + cctv_status
	cctv_noise.text = "·  ·   · ·    ·     · ·   ·" if int(Time.get_ticks_msec() / 220) % 2 == 0 else "   · ·     ·   · ·      ·"

func show_decision() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	decision_panel.visible = true

func resolve_decision(served: bool) -> void:
	decision_panel.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if served:
		show_message("BEEP.\n\nThe receipt prints by itself:\nTHANK YOU, ALEX.", 7.0)
		objective_label.text = "NIGHT 1 RESULT: You served the 03:17 customer."
		cctv_status = "CUSTOMER: NOT DETECTED / CASHIER: DETECTED"
	else:
		show_message("You refuse the sale.\n\nThe customer stares at you for several seconds... then leaves without the bottle.", 7.0)
		objective_label.text = "NIGHT 1 RESULT: You followed the rule."
		cctv_status = "DOOR OPENED AT 03:17 / PERSON DETECTION: 0"
	if active_customer and is_instance_valid(active_customer): active_customer.queue_free()
	await get_tree().create_timer(7.0).timeout
	show_message(L.tr_key("night_complete"), 6.0)
	write_night_one_save(served)

func write_night_one_save(served: bool) -> void:
	var file: FileAccess = FileAccess.open("user://save.json", FileAccess.WRITE)
	if file: file.store_string(JSON.stringify({"night":2, "night_1_served_0317":served}))

func build_environment() -> void:
	var world_environment: WorldEnvironment = WorldEnvironment.new()
	var environment: Environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.006,0.008,0.012)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.18,0.21,0.26)
	environment.ambient_light_energy = 0.55
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world_environment.environment = environment
	add_child(world_environment)
	var moon: DirectionalLight3D = DirectionalLight3D.new()
	moon.rotation_degrees = Vector3(-55,-25,0)
	moon.light_color = Color(0.45,0.55,0.75)
	moon.light_energy = 0.25
	moon.shadow_enabled = true
	add_child(moon)

func build_store() -> void:
	make_box("Floor",Vector3(18,0.2,14),Vector3(0,-0.1,0),Color(0.18,0.19,0.20))
	make_box("Ceiling",Vector3(18,0.2,14),Vector3(0,4.2,0),Color(0.12,0.13,0.14))
	make_box("BackWall",Vector3(18,4.2,0.25),Vector3(0,2.1,7),Color(0.28,0.29,0.30))
	make_box("LeftWall",Vector3(0.25,4.2,14),Vector3(-9,2.1,0),Color(0.26,0.27,0.28))
	make_box("RightWall",Vector3(0.25,4.2,14),Vector3(9,2.1,0),Color(0.26,0.27,0.28))
	make_box("FrontWallL",Vector3(7.0,4.2,0.25),Vector3(-5.5,2.1,-7),Color(0.20,0.22,0.23))
	make_box("FrontWallR",Vector3(7.0,4.2,0.25),Vector3(5.5,2.1,-7),Color(0.20,0.22,0.23))
	make_box("DoorHeader",Vector3(4.0,0.9,0.25),Vector3(0,3.75,-7),Color(0.20,0.22,0.23))
	var register: StaticBody3D = make_interactable_box("Register",Vector3(4.2,1.05,1.25),Vector3(4.6,0.525,-3.8),Color(0.13,0.20,0.18),"REGISTER 01")
	register.set_meta("register",true)
	make_box("RegisterTop",Vector3(4.35,0.08,1.38),Vector3(4.6,1.09,-3.8),Color(0.08,0.09,0.09))
	make_box("Scanner",Vector3(0.8,0.07,0.45),Vector3(4.1,1.17,-3.55),Color(0.05,0.12,0.16),false)
	var note: StaticBody3D = make_interactable_box("ManagerNote",Vector3(0.55,0.035,0.75),Vector3(3.6,1.15,-3.55),Color(0.74,0.70,0.52),L.tr_key("manager_note"))
	note.set_meta("manager_note",true)
	for z: float in [-1.2,1.2,3.6]:
		make_box("Shelf_%s"%z,Vector3(6.0,1.8,0.65),Vector3(-1.8,0.9,z),Color(0.34,0.31,0.25))
		make_box("ShelfTop_%s"%z,Vector3(6.1,0.08,0.72),Vector3(-1.8,1.84,z),Color(0.10,0.11,0.11))
		for i: int in range(6): make_box("Product",Vector3(0.28,0.42,0.22),Vector3(-4.1+i*0.8,1.25,z-0.36),Color(0.32+i*0.04,0.18+i*0.03,0.12+i*0.02),false)
	for i: int in range(5):
		var x: float = -6.5 + i * 2.15
		make_box("Fridge_%d"%i,Vector3(1.9,3.0,0.65),Vector3(x,1.5,6.55),Color(0.12,0.18,0.20))
		var fridge_light: OmniLight3D = OmniLight3D.new()
		fridge_light.position = Vector3(x,2.0,5.8); fridge_light.light_color=Color(0.65,0.82,1.0); fridge_light.light_energy=1.2; fridge_light.omni_range=4.5; add_child(fridge_light)
	var cctv: StaticBody3D = make_interactable_box("CCTV",Vector3(1.15,0.75,0.6),Vector3(6.8,1.45,-3.75),Color(0.04,0.05,0.055),"CCTV")
	cctv.set_meta("cctv",true)
	for x: float in [-5.5,0.0,5.5]:
		for z: float in [-3.5,1.0,5.0]:
			var light: OmniLight3D = OmniLight3D.new(); light.position=Vector3(x,3.7,z); light.light_color=Color(0.76,0.84,0.90); light.light_energy=2.0; light.omni_range=5.5; light.shadow_enabled=true; add_child(light)
			make_box("Fixture",Vector3(2.0,0.05,0.25),Vector3(x,4.0,z),Color(0.85,0.88,0.88),false)
	make_box("Parking",Vector3(28,0.15,16),Vector3(0,-0.12,-14.8),Color(0.025,0.028,0.032))

func make_box(node_name: String, size: Vector3, position: Vector3, color: Color, collision: bool = true) -> StaticBody3D:
	var body: StaticBody3D = StaticBody3D.new(); body.name=node_name; body.position=position; add_child(body)
	var mesh_instance: MeshInstance3D = MeshInstance3D.new(); var box_mesh: BoxMesh = BoxMesh.new(); box_mesh.size=size
	var material: StandardMaterial3D = StandardMaterial3D.new(); material.albedo_color=color; material.roughness=0.72; box_mesh.material=material; mesh_instance.mesh=box_mesh; body.add_child(mesh_instance)
	if collision:
		var collision_shape: CollisionShape3D = CollisionShape3D.new(); var shape: BoxShape3D = BoxShape3D.new(); shape.size=size; collision_shape.shape=shape; body.add_child(collision_shape)
	return body

func make_interactable_box(node_name: String, size: Vector3, position: Vector3, color: Color, text: String) -> StaticBody3D:
	var body: StaticBody3D = make_box(node_name,size,position,color,true); body.set_script(INTERACTABLE); body.set("message",text); return body

func build_ui() -> void:
	var layer: CanvasLayer = CanvasLayer.new(); add_child(layer)
	clock_label=Label.new(); clock_label.position=Vector2(28,22); clock_label.add_theme_font_size_override("font_size",30); clock_label.text="00:00"; layer.add_child(clock_label)
	var title: Label = Label.new(); title.position=Vector2(28,58); title.text="MORROW MARKET — NIGHT 1"; title.modulate=Color(0.72,0.78,0.82); layer.add_child(title)
	objective_label=Label.new(); objective_label.position=Vector2(28,90); objective_label.size=Vector2(740,50); objective_label.modulate=Color(0.82,0.79,0.63); layer.add_child(objective_label)
	interaction_hint=Label.new(); interaction_hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM); interaction_hint.position=Vector2(-120,-70); interaction_hint.size=Vector2(240,30); interaction_hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; interaction_hint.text="E — INTERACT"; interaction_hint.modulate=Color(0.55,0.60,0.63); layer.add_child(interaction_hint)
	var crosshair: Label=Label.new(); crosshair.set_anchors_preset(Control.PRESET_CENTER); crosshair.position=Vector2(-4,-10); crosshair.text="+"; crosshair.add_theme_font_size_override("font_size",20); layer.add_child(crosshair)
	var controls: Label=Label.new(); controls.set_anchors_preset(Control.PRESET_BOTTOM_LEFT); controls.position=Vector2(28,-42); controls.text="WASD — MOVE   MOUSE — LOOK   E — INTERACT"; controls.modulate=Color(0.50,0.54,0.58); layer.add_child(controls)
	message_label=Label.new(); message_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM); message_label.position=Vector2(-300,-190); message_label.size=Vector2(600,120); message_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; message_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER; message_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; message_label.add_theme_font_size_override("font_size",18); message_label.visible=false; layer.add_child(message_label)
	message_timer=Timer.new(); message_timer.one_shot=true; message_timer.timeout.connect(func() -> void: message_label.visible=false); add_child(message_timer)
	build_checkout_ui(layer); build_cctv_ui(layer); build_decision_ui(layer)

func build_checkout_ui(layer: CanvasLayer) -> void:
	checkout_panel=PanelContainer.new(); checkout_panel.set_anchors_preset(Control.PRESET_CENTER); checkout_panel.position=Vector2(-270,-220); checkout_panel.size=Vector2(540,440); checkout_panel.visible=false; layer.add_child(checkout_panel)
	var box: VBoxContainer=VBoxContainer.new(); box.add_theme_constant_override("separation",14); checkout_panel.add_child(box)
	var header: Label=Label.new(); header.text="MORROW MARKET / REGISTER 01"; header.add_theme_font_size_override("font_size",22); box.add_child(header); box.add_child(HSeparator.new())
	checkout_items=VBoxContainer.new(); checkout_items.custom_minimum_size=Vector2(500,220); box.add_child(checkout_items)
	checkout_total=Label.new(); checkout_total.text="TOTAL  $0.00"; checkout_total.add_theme_font_size_override("font_size",28); box.add_child(checkout_total)
	checkout_action=Button.new(); checkout_action.text="SCAN NEXT ITEM"; checkout_action.custom_minimum_size.y=48; checkout_action.pressed.connect(checkout_action_pressed); box.add_child(checkout_action)
	var close: Button=Button.new(); close.text="BACK TO STORE"; close.pressed.connect(close_checkout); box.add_child(close)

func build_cctv_ui(layer: CanvasLayer) -> void:
	cctv_overlay=ColorRect.new(); cctv_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); cctv_overlay.color=Color(0.015,0.025,0.022,0.97); cctv_overlay.visible=false; layer.add_child(cctv_overlay)
	cctv_camera_label=Label.new(); cctv_camera_label.position=Vector2(42,32); cctv_camera_label.add_theme_font_size_override("font_size",28); cctv_camera_label.modulate=Color(0.55,0.92,0.70); cctv_overlay.add_child(cctv_camera_label)
	var stamp: Label=Label.new(); stamp.set_anchors_preset(Control.PRESET_TOP_RIGHT); stamp.position=Vector2(-250,32); stamp.text="MORROW SECURITY / REC ●"; stamp.modulate=Color(0.62,0.88,0.70); cctv_overlay.add_child(stamp)
	cctv_feed_label=Label.new(); cctv_feed_label.set_anchors_preset(Control.PRESET_CENTER); cctv_feed_label.position=Vector2(-300,-150); cctv_feed_label.size=Vector2(600,300); cctv_feed_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; cctv_feed_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER; cctv_feed_label.add_theme_font_size_override("font_size",25); cctv_feed_label.modulate=Color(0.45,0.83,0.60); cctv_overlay.add_child(cctv_feed_label)
	cctv_noise=Label.new(); cctv_noise.set_anchors_preset(Control.PRESET_CENTER); cctv_noise.position=Vector2(-300,120); cctv_noise.size=Vector2(600,80); cctv_noise.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; cctv_noise.add_theme_font_size_override("font_size",32); cctv_noise.modulate=Color(0.30,0.55,0.40,0.45); cctv_overlay.add_child(cctv_noise)
	var nav: HBoxContainer=HBoxContainer.new(); nav.set_anchors_preset(Control.PRESET_CENTER_BOTTOM); nav.position=Vector2(-210,-90); nav.size=Vector2(420,50); cctv_overlay.add_child(nav)
	var prev: Button=Button.new(); prev.text="< PREV CAM"; prev.pressed.connect(func() -> void: cycle_cctv(-1)); nav.add_child(prev)
	var next: Button=Button.new(); next.text="NEXT CAM >"; next.pressed.connect(func() -> void: cycle_cctv(1)); nav.add_child(next)
	var close: Button=Button.new(); close.text="EXIT CCTV"; close.pressed.connect(close_cctv); nav.add_child(close)

func build_decision_ui(layer: CanvasLayer) -> void:
	decision_panel=PanelContainer.new(); decision_panel.set_anchors_preset(Control.PRESET_CENTER); decision_panel.position=Vector2(-220,-110); decision_panel.size=Vector2(440,220); decision_panel.visible=false; layer.add_child(decision_panel)
	var decision_box: VBoxContainer=VBoxContainer.new(); decision_box.add_theme_constant_override("separation",12); decision_panel.add_child(decision_box)
	var prompt: Label=Label.new(); prompt.text="03:17 CUSTOMER\nThe cameras say nobody is there."; prompt.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; prompt.add_theme_font_size_override("font_size",21); decision_box.add_child(prompt)
	var serve: Button=Button.new(); serve.text=L.tr_key("serve"); serve.pressed.connect(func() -> void: resolve_decision(true)); decision_box.add_child(serve)
	var refuse: Button=Button.new(); refuse.text=L.tr_key("refuse"); refuse.pressed.connect(func() -> void: resolve_decision(false)); decision_box.add_child(refuse)

func show_message(text: String, seconds: float = 4.0) -> void:
	message_label.text=text; message_label.visible=true; message_timer.wait_time=seconds; message_timer.start()

func on_interaction(body: Node) -> bool:
	if body.has_meta("manager_note"):
		if not note_read:
			note_read=true; objective_label.text=L.tr_key("objective_continue")
		return false
	if body.has_meta("register"): open_checkout(); return true
	if body.has_meta("cctv"): open_cctv(); return true
	return false
