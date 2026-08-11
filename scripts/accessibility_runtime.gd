extends Node

const SETTINGS_PATH := "user://settings.cfg"
var subtitles_enabled := true
var reduce_flashes := false
var text_scale := 1.0
var applied_nodes: Dictionary = {}
var game: Node

func _ready() -> void:
	game = get_parent()
	_load_settings()
	call_deferred("_apply_all")
	set_process(true)

func _load_settings() -> void:
	var cfg:=ConfigFile.new()
	if cfg.load(SETTINGS_PATH)==OK:
		subtitles_enabled=bool(cfg.get_value("accessibility","subtitles",true))
		reduce_flashes=bool(cfg.get_value("accessibility","reduce_flashes",false))
		text_scale=clampf(float(cfg.get_value("accessibility","text_scale",1.0)),0.85,1.35)

func _process(_delta:float)->void:
	_apply_all()
	if not subtitles_enabled and game != null:
		var msg:Variant=game.get("message_label")
		if msg is Label:(msg as Label).visible=false
	if reduce_flashes:
		for light in get_tree().get_nodes_in_group("accessibility_flash_light"):
			if light is Light3D:(light as Light3D).light_energy=minf((light as Light3D).light_energy,1.35)

func _apply_all()->void:
	for node in get_tree().get_nodes_in_group("m12_scaled_text"):
		_scale_control(node)
	_apply_recursive(game)

func _apply_recursive(node:Node)->void:
	if node==null:return
	if node is Label or node is Button:
		_scale_control(node)
	for child in node.get_children():
		if child is Node:_apply_recursive(child)

func _scale_control(control:Control)->void:
	var id:=control.get_instance_id()
	if applied_nodes.has(id):return
	var size:=control.get_theme_font_size("font_size")
	if size<=0:size=16
	control.add_theme_font_size_override("font_size",maxi(12,int(round(float(size)*text_scale))))
	applied_nodes[id]=true
