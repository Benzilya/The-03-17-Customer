extends Node

# M14 procedural production-art layer shared by Nights 1–6.
# It deliberately uses built-in geometry/materials so the project remains portable,
# while giving every night a more authored convenience-store silhouette.

var game: Node3D
var night_index := 1
var root := Node3D.new()

func _ready() -> void:
	call_deferred("_initialize")

func _initialize() -> void:
	game = get_parent() as Node3D
	if game == null: return
	night_index = _night_from_name(game.name)
	root.name = "ProductionVisuals"
	game.add_child(root)
	_upgrade_environment()
	_build_floor_language()
	_build_wall_language()
	_build_ceiling_language()
	_build_register_cluster()
	_build_store_signage()
	_build_ambient_props()
	_build_rest_room_detail()

func _night_from_name(n:String)->int:
	match n:
		"Night2": return 2
		"Night3": return 3
		"Night4": return 4
		"Night5": return 5
		"Night6": return 6
		_: return 1

func _mat(c:Color,rough:=0.72,metal:=0.0,emission:=Color(0,0,0),energy:=0.0)->StandardMaterial3D:
	var m:=StandardMaterial3D.new();m.albedo_color=c;m.roughness=rough;m.metallic=metal
	if energy>0.0:m.emission_enabled=true;m.emission=emission;m.emission_energy_multiplier=energy
	return m

func _box(n:String,s:Vector3,p:Vector3,m:Material,rot:=Vector3.ZERO)->MeshInstance3D:
	var i:=MeshInstance3D.new();i.name=n;var mesh:=BoxMesh.new();mesh.size=s;mesh.material=m;i.mesh=mesh;i.position=p;i.rotation_degrees=rot;root.add_child(i);return i

func _cyl(n:String,r:float,h:float,p:Vector3,m:Material,rot:=Vector3.ZERO)->MeshInstance3D:
	var i:=MeshInstance3D.new();i.name=n;var mesh:=CylinderMesh.new();mesh.top_radius=r;mesh.bottom_radius=r;mesh.height=h;mesh.material=m;i.mesh=mesh;i.position=p;i.rotation_degrees=rot;root.add_child(i);return i

func _label(text:String,p:Vector3,size:int,color:Color,rot:=Vector3(0,180,0))->Label3D:
	var l:=Label3D.new();l.text=text;l.position=p;l.rotation_degrees=rot;l.font_size=size;l.modulate=color;l.outline_size=5;l.outline_modulate=Color(0.01,0.015,0.018,.9);root.add_child(l);return l

func _upgrade_environment()->void:
	# Add restrained pools of light instead of globally brightening the store.
	var key:=OmniLight3D.new();key.position=Vector3(4.2,3.25,-2.7);key.light_color=Color(.63,.78,.72);key.light_energy=.42 if night_index<5 else .28;key.omni_range=5.2;key.shadow_enabled=true;root.add_child(key)
	var fridge:=OmniLight3D.new();fridge.position=Vector3(-2.4,2.2,5.35);fridge.light_color=Color(.50,.68,.84);fridge.light_energy=.38 if night_index<5 else .24;fridge.omni_range=6.2;root.add_child(fridge)
	var entrance:=OmniLight3D.new();entrance.position=Vector3(0,2.7,-5.8);entrance.light_color=Color(.32,.48,.64);entrance.light_energy=.32;entrance.omni_range=5.5;entrance.shadow_enabled=true;root.add_child(entrance)
	# Warm back-room contrast gives depth and a visual safe-zone cue.
	var back:=OmniLight3D.new();back.position=Vector3(6.6,2.55,4.7);back.light_color=Color(.82,.66,.43);back.light_energy=.30;back.omni_range=3.4;root.add_child(back)

func _build_floor_language()->void:
	var grout:=_mat(Color(.055,.062,.064),.92)
	# Thin grout lines break the giant prototype floor plane into commercial tiles.
	for x in range(-8,9):_box("FloorGroutX",Vector3(.018,.006,13.2),Vector3(float(x),.006,0),grout)
	for z in range(-6,7):_box("FloorGroutZ",Vector3(17.0,.006,.018),Vector3(0,.006,float(z)),grout)
	var wear:=_mat(Color(.10,.105,.10,.38),.95)
	for p in [Vector3(3.7,.012,-3.0),Vector3(0,.012,-5.2),Vector3(-2,.012,1.2),Vector3(5.9,.012,4.2)]:_box("FloorWear",Vector3(1.15,.008,.42),p,wear,Vector3(0,randf_range(-14,14),0))

func _build_wall_language()->void:
	var base:=_mat(Color(.08,.095,.10),.88)
	var rail:=_mat(Color(.16,.18,.18),.55,.32)
	# Commercial kick plate/baseboard around the room.
	_box("BackBaseboard",Vector3(17.4,.16,.08),Vector3(0,.12,6.78),rail)
	_box("LeftBaseboard",Vector3(.08,.16,13.4),Vector3(-8.78,.12,0),rail)
	_box("RightBaseboard",Vector3(.08,.16,13.4),Vector3(8.78,.12,0),rail)
	# Utility panels and conduit add believable wall scale.
	_box("ElectricalPanel",Vector3(.72,1.02,.10),Vector3(8.68,1.55,1.5),base)
	_box("PanelDoor",Vector3(.62,.91,.018),Vector3(8.61,1.55,1.5),_mat(Color(.22,.24,.23),.58,.36))
	for z in [-.8,.2,1.2]:_cyl("Conduit",.018,2.0,Vector3(8.62,2.75,z),rail,Vector3(90,0,0))
	_box("FirePanel",Vector3(.36,.52,.09),Vector3(-8.65,1.65,-4.25),_mat(Color(.38,.055,.045),.64))
	_label("STAFF ONLY",Vector3(7.95,2.42,5.92),26,Color(.72,.66,.50),Vector3(0,0,0))

func _build_ceiling_language()->void:
	var frame:=_mat(Color(.055,.064,.067),.66,.20)
	var diffuser:=_mat(Color(.68,.73,.70),.34,0,Color(.70,.83,.77),1.0 if night_index<5 else .72)
	for z in [-4.4,-1.2,2.0,5.0]:
		for x in [-5.3,0.0,5.3]:
			_box("FixtureHousing",Vector3(2.30,.11,.58),Vector3(x,4.02,z),frame)
			_box("FixtureDiffuser",Vector3(2.06,.028,.40),Vector3(x,3.955,z),diffuser)
	# A few dark/non-working units avoid a uniformly generated look.
	_box("DeadFixture",Vector3(2.04,.032,.39),Vector3(-5.3,3.953,2.0),_mat(Color(.14,.15,.14),.75))

func _build_register_cluster()->void:
	var black:=_mat(Color(.025,.03,.032),.56,.16);var metal:=_mat(Color(.22,.25,.25),.34,.52);var paper:=_mat(Color(.74,.71,.61),.94)
	_box("RegisterMonitorBack",Vector3(.90,.58,.13),Vector3(5.15,1.62,-3.78),black)
	_box("MonitorBezelInset",Vector3(.72,.42,.014),Vector3(5.15,1.62,-3.705),_mat(Color(.035,.075,.072),.22,0,Color(.05,.24,.20),.38))
	_box("MonitorStem",Vector3(.09,.36,.09),Vector3(5.15,1.30,-3.78),metal)
	_box("ReceiptPrinterTop",Vector3(.52,.28,.44),Vector3(5.84,1.30,-3.61),_mat(Color(.12,.13,.13),.62,.12))
	_box("ReceiptSlot",Vector3(.31,.025,.018),Vector3(5.84,1.42,-3.38),black)
	_box("Receipt",Vector3(.27,.008,.42),Vector3(5.84,1.44,-3.52),paper,Vector3(-7,0,0))
	# Counter trim makes the blockout read as fabricated furniture.
	_box("CounterFrontTrim",Vector3(4.25,.10,.08),Vector3(4.65,1.08,-3.94),metal)
	_box("CounterFoot",Vector3(3.85,.07,.65),Vector3(4.65,.08,-3.65),black)

func _build_store_signage()->void:
	_label("COLD DRINKS",Vector3(-2.15,3.18,6.02),34,Color(.60,.80,.92),Vector3(0,0,0))
	_label("REGISTER 01",Vector3(5.0,2.72,-3.98),23,Color(.63,.74,.68),Vector3(0,0,0))
	_label("AISLE 01",Vector3(-1.9,2.35,-.83),20,Color(.62,.61,.49),Vector3(-90,0,0))
	var promo:=_mat(Color(.38,.065,.045),.78)
	_box("PromoBoard",Vector3(.82,1.14,.025),Vector3(-8.65,2.0,-1.0),promo)
	_label("2 / $5",Vector3(-8.60,2.04,-1.0),24,Color(.92,.82,.56),Vector3(0,90,0))

func _build_ambient_props()->void:
	var cardboard:=_mat(Color(.33,.23,.13),.95);var tape:=_mat(Color(.57,.46,.25),.74)
	for data in [[Vector3(-7.2,.25,5.1),Vector3(.7,.5,.62)],[Vector3(-6.5,.18,5.35),Vector3(.62,.36,.52)],[Vector3(7.1,.30,4.85),Vector3(.8,.60,.68)]]:
		var p:Vector3=data[0];var s:Vector3=data[1];_box("ShippingCarton",s,Vector3(p.x,s.y*.5,p.z),cardboard);_box("CartonTape",Vector3(.08,s.y+.01,s.z+.01),Vector3(p.x,s.y*.5,p.z),tape)
	# Mop/bucket silhouette in rear corner.
	_cyl("MopHandle",.018,1.65,Vector3(-7.65,.83,5.2),_mat(Color(.40,.31,.19),.78),Vector3(0,0,-7))
	_cyl("Bucket",.24,.32,Vector3(-7.25,.16,5.25),_mat(Color(.10,.23,.28),.80))
	# Fire extinguisher.
	_cyl("Extinguisher",.11,.54,Vector3(-8.55,.75,-4.2),_mat(Color(.52,.055,.04),.55,.12))
	_box("ExtinguisherHandle",Vector3(.18,.05,.05),Vector3(-8.55,1.04,-4.2),_mat(Color(.08,.08,.075),.4,.4))

func _build_rest_room_detail()->void:
	# Shared rest_room_system owns collision/bed; this layer adds non-colliding visual dressing.
	var wood:=_mat(Color(.16,.095,.055),.83);var fabric:=_mat(Color(.25,.29,.30),.96);var cream:=_mat(Color(.56,.54,.48),.98)
	_box("RestHeadboard",Vector3(.10,1.05,1.36),Vector3(5.24,.80,4.65),wood)
	_box("RestBlanketFold",Vector3(.76,.10,1.10),Vector3(6.72,.77,4.65),fabric)
	_box("RestPillowDetail",Vector3(.46,.18,.82),Vector3(5.58,.82,4.65),cream)
	_box("BedsideTable",Vector3(.55,.55,.55),Vector3(7.75,.28,3.82),wood)
	_cyl("Mug",.09,.16,Vector3(7.75,.64,3.82),_mat(Color(.18,.21,.20),.62))
	_box("NoticeBoard",Vector3(1.05,.78,.04),Vector3(8.48,1.75,4.15),_mat(Color(.32,.23,.15),.93),Vector3(0,90,0))
