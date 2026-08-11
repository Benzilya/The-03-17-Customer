extends Node3D
const INTERACTABLE=preload("res://scripts/interactable.gd")
const CUSTOMER=preload("res://scripts/customer.gd")
const L=preload("res://scripts/localization.gd")
var message_label:Label; var clock_label:Label; var objective_label:Label; var interaction_hint:Label; var message_timer:Timer
var shift_minutes:float=0.0; var shift_speed:float=12.0; var event_flags:Dictionary={}; var active_customer:Node3D; var decision_panel:PanelContainer; var note_panel:PanelContainer
var checkout_panel:PanelContainer; var checkout_items:VBoxContainer; var checkout_total:Label; var checkout_action:Button
var cctv_overlay:ColorRect; var cctv_feed_label:Label; var cctv_camera_label:Label; var cctv_noise:Label; var cctv_camera:int=1; var cctv_open:bool=false; var cctv_status:String=""; var note_read:bool=false
var current_items:Array[Dictionary]=[]; var scanned_count:int=0; var transaction_callback:Callable; var night_locked:bool=false
func _ready()->void: add_to_group("game"); build_environment(); build_store(); build_ui(); cctv_status=L.tr_key("cctv_stable"); show_message(L.tr_key("night_intro"),5.0); objective_label.text=L.tr_key("objective_note")
func _process(delta:float)->void:
	if not night_locked: shift_minutes+=delta*shift_speed
	var m:int=int(shift_minutes)%360; clock_label.text="%02d:%02d"%[int(m/60),m%60]; run_night_events(m)
	if cctv_open:update_cctv_feed(m)
func run_night_events(m:int)->void:
	if m>=8 and not event_flags.has("c1"): event_flags["c1"]=true; spawn_customer(L.tr_key("late_driver"),false,Color(0.25,0.34,0.46),L.tr_key("late_driver_line"),[{"name":L.tr_key("black_coffee"),"price":2.49},{"name":L.tr_key("beef_jerky"),"price":3.99}],"signature_beard")
	if m>=72 and not event_flags.has("c2"): event_flags["c2"]=true; spawn_customer(L.tr_key("nurse"),false,Color(0.36,0.42,0.38),L.tr_key("nurse_line"),[{"name":L.tr_key("spring_water"),"price":1.79}])
	if m>=150 and not event_flags.has("warning"): event_flags["warning"]=true; show_message(L.tr_key("warning_0230"),4.0); cctv_status=L.tr_key("cctv_noise_status")
	if m>=190 and not event_flags.has("pre"): event_flags["pre"]=true; objective_label.text=L.tr_key("objective_watch"); show_message(L.tr_key("quiet_0310"),4.0)
	if m>=197 and not event_flags.has("317"): event_flags["317"]=true; shift_minutes=197; night_locked=true; spawn_317_customer()
func spawn_customer(n:String,a:bool,c:Color,line:String,items:Array[Dictionary],style:String="default")->void:
	if active_customer and is_instance_valid(active_customer):active_customer.queue_free()
	active_customer=CUSTOMER.new(); add_child(active_customer); active_customer.global_position=Vector3(0,0,-9.5); active_customer.setup(n,a,c,style); await active_customer.walk_to(Vector3(3.4,0,-2.8),2.2); show_message(n+": \""+line+"\"",4); objective_label.text=L.tr_key("objective_ring")%n; begin_transaction(items,func()->void:finish_normal_customer(n))
func finish_normal_customer(n:String)->void:
	show_message(L.tr_key("payment_approved")%n,3.5); objective_label.text=L.tr_key("objective_continue")
	if active_customer and is_instance_valid(active_customer): await active_customer.walk_to(Vector3(0,0,-9.5),2); active_customer.queue_free()
func spawn_317_customer()->void:
	if active_customer and is_instance_valid(active_customer):active_customer.queue_free()
	active_customer=CUSTOMER.new(); add_child(active_customer); active_customer.global_position=Vector3(0,0,-9.5); active_customer.setup(L.tr_key("unknown_customer"),true,Color(0.10,0.105,0.12)); cctv_status=L.tr_key("cctv_mismatch"); show_message(L.tr_key("arrival_0317"),5); await active_customer.walk_to(Vector3(3.4,0,-2.8),3); objective_label.text=L.tr_key("objective_check"); show_message(L.tr_key("unknown_line"),5); await get_tree().create_timer(1.5).timeout; show_decision()
func begin_transaction(items:Array[Dictionary],callback:Callable)->void: current_items=items; scanned_count=0; transaction_callback=callback; update_checkout_ui()
func open_checkout()->void:
	if current_items.is_empty():show_message(L.tr_key("register_empty"),2.5);return
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE; checkout_panel.visible=true; update_checkout_ui()
func update_checkout_ui()->void:
	if not checkout_items:return
	for child:Node in checkout_items.get_children():child.queue_free()
	var total:float=0
	for i:int in range(current_items.size()):
		var item:Dictionary=current_items[i]; var row:=Label.new(); row.text="[%s] %s   $%.2f"%[L.tr_key("scanned") if i<scanned_count else L.tr_key("waiting"),item["name"],item["price"]]; checkout_items.add_child(row)
		if i<scanned_count:total+=float(item["price"])
	checkout_total.text="%s  $%.2f"%[L.tr_key("total"),total]; checkout_action.text=L.tr_key("scan_next") if scanned_count<current_items.size() else L.tr_key("take_payment")
func checkout_action_pressed()->void:
	if scanned_count<current_items.size():scanned_count+=1;update_checkout_ui();return
	checkout_panel.visible=false;Input.mouse_mode=Input.MOUSE_MODE_CAPTURED;current_items.clear();var cb:=transaction_callback;transaction_callback=Callable();if cb.is_valid():cb.call()
func close_checkout()->void:checkout_panel.visible=false;Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
func open_cctv()->void:cctv_open=true;Input.mouse_mode=Input.MOUSE_MODE_VISIBLE;cctv_overlay.visible=true;update_cctv_feed(int(shift_minutes))
func close_cctv()->void:cctv_open=false;cctv_overlay.visible=false;Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
func cycle_cctv(d:int)->void:cctv_camera=wrapi(cctv_camera+d,1,5);update_cctv_feed(int(shift_minutes))
func update_cctv_feed(m:int)->void:
	var names:Dictionary={1:L.tr_key("cctv_register"),2:L.tr_key("cctv_aisles"),3:L.tr_key("cctv_entrance"),4:L.tr_key("cctv_stockroom")};cctv_camera_label.text="CAM %02d / %s"%[cctv_camera,names[cctv_camera]];var feed:=L.tr_key("cctv_stable")
	if m>=150:feed=L.tr_key("cctv_static")
	if m>=197:
		if cctv_camera==1:feed=L.tr_key("cctv_cashier_only")
		elif cctv_camera==3:feed=L.tr_key("cctv_empty_entrance")
		else:feed=L.tr_key("cctv_desync")
	cctv_feed_label.text=feed+"\n\n"+cctv_status;cctv_noise.text="·  ·   · ·    ·     · ·   ·" if int(Time.get_ticks_msec()/220)%2==0 else "   · ·     ·   · ·      ·"
func show_decision()->void:Input.mouse_mode=Input.MOUSE_MODE_VISIBLE;decision_panel.visible=true
func resolve_decision(served:bool)->void:
	decision_panel.visible=false;Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	if served:show_message(L.tr_key("served_message"),7);objective_label.text=L.tr_key("result_served");cctv_status=L.tr_key("cctv_served")
	else:show_message(L.tr_key("refused_message"),7);objective_label.text=L.tr_key("result_refused");cctv_status=L.tr_key("cctv_refused")
	if active_customer and is_instance_valid(active_customer):active_customer.queue_free()
	await get_tree().create_timer(7).timeout;show_message(L.tr_key("night_complete"),6);write_night_one_save(served)
func write_night_one_save(served:bool)->void:var f:=FileAccess.open("user://save.json",FileAccess.WRITE);if f:f.store_string(JSON.stringify({"night":2,"night_1_served_0317":served}))
func build_environment()->void:
	var w:=WorldEnvironment.new();var e:=Environment.new();e.background_mode=Environment.BG_COLOR;e.background_color=Color(0.006,0.008,0.012);e.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;e.ambient_light_color=Color(0.18,0.21,0.26);e.ambient_light_energy=0.55;e.tonemap_mode=Environment.TONE_MAPPER_FILMIC;w.environment=e;add_child(w);var moon:=DirectionalLight3D.new();moon.rotation_degrees=Vector3(-55,-25,0);moon.light_color=Color(0.45,0.55,0.75);moon.light_energy=0.25;moon.shadow_enabled=true;add_child(moon)
func build_store()->void:
	make_box("Floor",Vector3(18,.2,14),Vector3(0,-.1,0),Color(.18,.19,.20));make_box("Ceiling",Vector3(18,.2,14),Vector3(0,4.2,0),Color(.12,.13,.14));make_box("BackWall",Vector3(18,4.2,.25),Vector3(0,2.1,7),Color(.28,.29,.30));make_box("LeftWall",Vector3(.25,4.2,14),Vector3(-9,2.1,0),Color(.26,.27,.28));make_box("RightWall",Vector3(.25,4.2,14),Vector3(9,2.1,0),Color(.26,.27,.28));make_box("FrontL",Vector3(7,4.2,.25),Vector3(-5.5,2.1,-7),Color(.20,.22,.23));make_box("FrontR",Vector3(7,4.2,.25),Vector3(5.5,2.1,-7),Color(.20,.22,.23));make_box("Header",Vector3(4,.9,.25),Vector3(0,3.75,-7),Color(.20,.22,.23))
	var reg:=make_interactable_box("Register",Vector3(4.2,1.05,1.25),Vector3(4.6,.525,-3.8),Color(.13,.20,.18),"REGISTER 01");reg.set_meta("register",true);make_box("Top",Vector3(4.35,.08,1.38),Vector3(4.6,1.09,-3.8),Color(.08,.09,.09));make_box("Scanner",Vector3(.8,.07,.45),Vector3(4.1,1.17,-3.55),Color(.05,.12,.16),false)
	var note:=make_interactable_box("ManagerNote",Vector3(.55,.035,.75),Vector3(3.6,1.15,-3.55),Color(.62,.52,.31),"");note.set_meta("manager_note",true)
	for z:float in [-1.2,1.2,3.6]:make_box("Shelf",Vector3(6,1.8,.65),Vector3(-1.8,.9,z),Color(.34,.31,.25));make_box("ShelfTop",Vector3(6.1,.08,.72),Vector3(-1.8,1.84,z),Color(.10,.11,.11))
	for i:int in range(5):var x:float=-6.5+i*2.15;make_box("Fridge",Vector3(1.9,3,.65),Vector3(x,1.5,6.55),Color(.12,.18,.20));var fl:=OmniLight3D.new();fl.position=Vector3(x,2,5.8);fl.light_color=Color(.65,.82,1);fl.light_energy=1.2;fl.omni_range=4.5;add_child(fl)
	var c:=make_interactable_box("CCTV",Vector3(1.15,.75,.6),Vector3(6.8,1.45,-3.75),Color(.04,.05,.055),"CCTV");c.set_meta("cctv",true)
	for x:float in [-5.5,0.0,5.5]:for z:float in [-3.5,1.0,5.0]:var light:=OmniLight3D.new();light.position=Vector3(x,3.7,z);light.light_color=Color(.76,.84,.90);light.light_energy=1.7;light.omni_range=5.5;light.shadow_enabled=true;add_child(light);make_box("Fixture",Vector3(2,.05,.25),Vector3(x,4,z),Color(.82,.85,.86),false)
	make_box("Parking",Vector3(28,.15,16),Vector3(0,-.12,-14.8),Color(.025,.028,.032))
func make_box(n:String,s:Vector3,p:Vector3,c:Color,collision:bool=true)->StaticBody3D:
	var b:=StaticBody3D.new();b.name=n;b.position=p;add_child(b);var mi:=MeshInstance3D.new();var mesh:=BoxMesh.new();mesh.size=s;var mat:=StandardMaterial3D.new();mat.albedo_color=c;mat.roughness=.72;mesh.material=mat;mi.mesh=mesh;b.add_child(mi);if collision:var cs:=CollisionShape3D.new();var sh:=BoxShape3D.new();sh.size=s;cs.shape=sh;b.add_child(cs);return b
func make_interactable_box(n:String,s:Vector3,p:Vector3,c:Color,text:String)->StaticBody3D:var b:=make_box(n,s,p,c,true);b.set_script(INTERACTABLE);b.set("message",text);return b
func build_ui()->void:
	var layer:=CanvasLayer.new();add_child(layer);clock_label=Label.new();clock_label.position=Vector2(28,22);clock_label.add_theme_font_size_override("font_size",30);layer.add_child(clock_label);var title:=Label.new();title.position=Vector2(28,58);title.text=L.tr_key("night_title");title.modulate=Color(.72,.78,.82);layer.add_child(title);objective_label=Label.new();objective_label.position=Vector2(28,90);objective_label.size=Vector2(850,50);objective_label.modulate=Color(.82,.79,.63);layer.add_child(objective_label)
	interaction_hint=Label.new();interaction_hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM);interaction_hint.position=Vector2(-140,-62);interaction_hint.size=Vector2(280,30);interaction_hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;interaction_hint.text=L.tr_key("interact");interaction_hint.modulate=Color(.55,.60,.63);layer.add_child(interaction_hint);var controls:=Label.new();controls.set_anchors_preset(Control.PRESET_BOTTOM_LEFT);controls.position=Vector2(28,-32);controls.text=L.tr_key("controls");controls.modulate=Color(.50,.54,.58);controls.add_theme_font_size_override("font_size",12);layer.add_child(controls)
	message_label=Label.new();message_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM);message_label.position=Vector2(-320,-195);message_label.size=Vector2(640,100);message_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;message_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;message_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;message_label.add_theme_font_size_override("font_size",18);message_label.visible=false;layer.add_child(message_label);message_timer=Timer.new();message_timer.one_shot=true;message_timer.timeout.connect(func()->void:message_label.visible=false);add_child(message_timer);build_note_ui(layer);build_checkout_ui(layer);build_cctv_ui(layer);build_decision_ui(layer)
func build_note_ui(layer:CanvasLayer)->void:
	note_panel=PanelContainer.new();note_panel.set_anchors_preset(Control.PRESET_CENTER);note_panel.position=Vector2(-290,-205);note_panel.size=Vector2(580,410);note_panel.visible=false;layer.add_child(note_panel);var box:=VBoxContainer.new();box.add_theme_constant_override("separation",18);note_panel.add_child(box);var text:=Label.new();text.text=L.tr_key("manager_note");text.custom_minimum_size=Vector2(520,300);text.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;text.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;text.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;text.add_theme_font_size_override("font_size",18);box.add_child(text);var close:=Button.new();close.text=L.tr_key("back_store");close.custom_minimum_size.y=44;close.pressed.connect(close_note);box.add_child(close)
func open_note()->void:note_panel.visible=true;message_label.visible=false;Input.mouse_mode=Input.MOUSE_MODE_VISIBLE;if not note_read:note_read=true;objective_label.text=L.tr_key("objective_continue")
func close_note()->void:note_panel.visible=false;Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
func build_checkout_ui(layer:CanvasLayer)->void:
	checkout_panel=PanelContainer.new();checkout_panel.set_anchors_preset(Control.PRESET_CENTER);checkout_panel.position=Vector2(-270,-210);checkout_panel.size=Vector2(540,420);checkout_panel.visible=false;layer.add_child(checkout_panel);var box:=VBoxContainer.new();box.add_theme_constant_override("separation",12);checkout_panel.add_child(box);var h:=Label.new();h.text=L.tr_key("register_header");h.add_theme_font_size_override("font_size",22);box.add_child(h);box.add_child(HSeparator.new());checkout_items=VBoxContainer.new();checkout_items.custom_minimum_size=Vector2(500,200);box.add_child(checkout_items);checkout_total=Label.new();checkout_total.add_theme_font_size_override("font_size",26);box.add_child(checkout_total);checkout_action=Button.new();checkout_action.custom_minimum_size.y=44;checkout_action.pressed.connect(checkout_action_pressed);box.add_child(checkout_action);var close:=Button.new();close.text=L.tr_key("back_store");close.pressed.connect(close_checkout);box.add_child(close)
func build_cctv_ui(layer:CanvasLayer)->void:
	cctv_overlay=ColorRect.new();cctv_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);cctv_overlay.color=Color(.012,.022,.018,.98);cctv_overlay.visible=false;layer.add_child(cctv_overlay);cctv_camera_label=Label.new();cctv_camera_label.position=Vector2(42,32);cctv_camera_label.add_theme_font_size_override("font_size",28);cctv_camera_label.modulate=Color(.55,.92,.70);cctv_overlay.add_child(cctv_camera_label);var stamp:=Label.new();stamp.set_anchors_preset(Control.PRESET_TOP_RIGHT);stamp.position=Vector2(-290,32);stamp.text=L.tr_key("cctv_rec");stamp.modulate=Color(.62,.88,.70);cctv_overlay.add_child(stamp);cctv_feed_label=Label.new();cctv_feed_label.set_anchors_preset(Control.PRESET_CENTER);cctv_feed_label.position=Vector2(-330,-155);cctv_feed_label.size=Vector2(660,310);cctv_feed_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;cctv_feed_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;cctv_feed_label.add_theme_font_size_override("font_size",24);cctv_feed_label.modulate=Color(.45,.83,.60);cctv_overlay.add_child(cctv_feed_label);cctv_noise=Label.new();cctv_noise.set_anchors_preset(Control.PRESET_CENTER);cctv_noise.position=Vector2(-300,115);cctv_noise.size=Vector2(600,80);cctv_noise.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;cctv_noise.add_theme_font_size_override("font_size",30);cctv_noise.modulate=Color(.30,.55,.40,.45);cctv_overlay.add_child(cctv_noise);var nav:=HBoxContainer.new();nav.set_anchors_preset(Control.PRESET_CENTER_BOTTOM);nav.position=Vector2(-245,-80);cctv_overlay.add_child(nav);var prev:=Button.new();prev.text=L.tr_key("cctv_prev");prev.pressed.connect(func()->void:cycle_cctv(-1));nav.add_child(prev);var next:=Button.new();next.text=L.tr_key("cctv_next");next.pressed.connect(func()->void:cycle_cctv(1));nav.add_child(next);var close:=Button.new();close.text=L.tr_key("cctv_exit");close.pressed.connect(close_cctv);nav.add_child(close)
func build_decision_ui(layer:CanvasLayer)->void:
	decision_panel=PanelContainer.new();decision_panel.set_anchors_preset(Control.PRESET_CENTER);decision_panel.position=Vector2(-270,-115);decision_panel.size=Vector2(540,230);decision_panel.visible=false;layer.add_child(decision_panel);var box:=VBoxContainer.new();box.add_theme_constant_override("separation",10);decision_panel.add_child(box);var p:=Label.new();p.text=L.tr_key("decision_prompt");p.custom_minimum_size=Vector2(500,100);p.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;p.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;p.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;p.add_theme_font_size_override("font_size",20);box.add_child(p);var serve:=Button.new();serve.text=L.tr_key("serve");serve.pressed.connect(func()->void:resolve_decision(true));box.add_child(serve);var refuse:=Button.new();refuse.text=L.tr_key("refuse");refuse.pressed.connect(func()->void:resolve_decision(false));box.add_child(refuse)
func show_message(text:String,seconds:float=4)->void:message_label.text=text;message_label.visible=true;message_timer.wait_time=seconds;message_timer.start()
func on_interaction(body:Node)->bool:
	if body.has_meta("manager_note"):open_note();return true
	if body.has_meta("register"):open_checkout();return true
	if body.has_meta("cctv"):open_cctv();return true
	return false
