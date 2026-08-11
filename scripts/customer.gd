extends Node3D

const LEGACY_REGISTER_TARGET := Vector3(3.4, 0.0, -2.8)
const REGISTER_WAIT_POSITION := Vector3(3.55, 0.0, -5.75)
const REGISTER_TARGET_EPSILON: float = 0.35

var display_name:String="Customer"
var anomalous:bool=false
var color:Color=Color(0.45,0.48,0.52)
var character_style:String="default"

func setup(customer_name:String,is_anomalous:bool,body_color:Color,style:String="default")->void:
	display_name=customer_name;anomalous=is_anomalous;color=body_color;character_style=style
	_build_body()
	if character_style=="signature_beard" and not anomalous:_build_signature_customer()

func _material(c:Color,roughness:float=0.78,metallic:float=0.0)->StandardMaterial3D:
	var m:=StandardMaterial3D.new();m.albedo_color=c;m.roughness=roughness;m.metallic=metallic;return m

func _add(mesh:PrimitiveMesh,pos:Vector3,mat:Material,rot:Vector3=Vector3.ZERO,scale_v:Vector3=Vector3.ONE)->void:
	mesh.material=mat;var n:=MeshInstance3D.new();n.mesh=mesh;n.position=pos;n.rotation_degrees=rot;n.scale=scale_v;n.layers=2 if anomalous else 1;add_child(n)

func _sphere(radius:float,height:float,pos:Vector3,mat:Material,scale_v:=Vector3.ONE)->void:
	var m:=SphereMesh.new();m.radius=radius;m.height=height;_add(m,pos,mat,Vector3.ZERO,scale_v)

func _box(size:Vector3,pos:Vector3,mat:Material,rot:=Vector3.ZERO)->void:
	var m:=BoxMesh.new();m.size=size;_add(m,pos,mat,rot)

func _cyl(radius:float,height:float,pos:Vector3,mat:Material,rot:=Vector3.ZERO)->void:
	var m:=CylinderMesh.new();m.top_radius=radius;m.bottom_radius=radius;m.height=height;_add(m,pos,mat,rot)

func _build_body()->void:
	var clothes:=_material(color,0.90);var cloth_shadow:=_material(color.darkened(0.24),0.94);var cloth_hi:=_material(color.lightened(0.08),0.90)
	var skin_color:=Color(0.66,0.54,0.46) if not anomalous else Color(0.49,0.50,0.49)
	var skin:=_material(skin_color,0.92);var skin_shadow:=_material(skin_color.darkened(.14),.94);var hair_mat:=_material(Color(.045,.037,.031) if not anomalous else Color(.012,.015,.018),.92)
	var shoe_mat:=_material(Color(.028,.03,.032),.80,.06)
	# Torso has layered chest/jacket geometry instead of one capsule silhouette.
	var torso:=CapsuleMesh.new();torso.radius=.31;torso.height=1.02;_add(torso,Vector3(0,1.05,.015),clothes,Vector3.ZERO,Vector3(1.0,1.0,.92))
	_box(Vector3(.72,.16,.34),Vector3(0,1.43,0),clothes)
	_box(Vector3(.48,.58,.055),Vector3(0,1.18,-.285),cloth_shadow)
	_box(Vector3(.018,.54,.012),Vector3(0,1.18,-.317),cloth_hi)
	# Collar/lapels immediately give the body a more human clothing read.
	_box(Vector3(.22,.26,.045),Vector3(-.12,1.43,-.255),cloth_hi,Vector3(0,0,-24))
	_box(Vector3(.22,.26,.045),Vector3(.12,1.43,-.255),cloth_shadow,Vector3(0,0,24))
	_cyl(.088,.17,Vector3(0,1.62,0),skin_shadow)
	# Head is slightly narrower/deeper than prototype sphere.
	_sphere(.235,.47,Vector3(0,1.86,0),skin,Vector3(.91,1.08,.88) if not anomalous else Vector3(.90,1.14,.85))
	# Jaw/chin and cheek volumes soften the perfect sphere.
	_sphere(.145,.19,Vector3(0,1.735,-.025),skin_shadow,Vector3(1.05,.70,.90))
	for side:float in [-1.0,1.0]:
		_sphere(.055,.10,Vector3(.212*side,1.86,.005),skin_shadow,Vector3(.60,1.0,.52))
		_sphere(.068,.09,Vector3(.105*side,1.82,-.190),skin,Vector3(1.15,.72,.45))
	# Hair cap + side masses; still stylized but no longer a floating half-sphere.
	_sphere(.238,.27,Vector3(0,1.995,.018),hair_mat,Vector3(.98,.46,.98))
	if not anomalous:
		_sphere(.115,.23,Vector3(-.145,1.94,.015),hair_mat,Vector3(.55,1,.74));_sphere(.115,.23,Vector3(.145,1.94,.015),hair_mat,Vector3(.55,1,.74))
	# Eyes: sclera + iris + pupil + brows. Anomalies retain subtly enlarged dark eyes.
	for side:float in [-1.0,1.0]:
		var eye_x:=.086*side
		_sphere(.030 if not anomalous else .035,.035,Vector3(eye_x,1.885,-.207),_material(Color(.78,.76,.70) if not anomalous else Color(.08,.09,.10),.42),Vector3(1.15,.72,.45))
		_sphere(.014 if not anomalous else .022,.018,Vector3(eye_x,1.885,-.230),_material(Color(.12,.18,.16) if not anomalous else Color(.005,.006,.007),.26),Vector3(.85,1,.45))
		_box(Vector3(.095,.018,.015),Vector3(.092*side,1.945,-.218),hair_mat,Vector3(0,0,5*side))
		var arm:=CapsuleMesh.new();arm.radius=.075;arm.height=.69;_add(arm,Vector3(.38*side,1.04,.015),clothes,Vector3(0,0,5*side))
		_sphere(.082,.16,Vector3(.415*side,.69,-.015),skin)
		var leg:=CapsuleMesh.new();leg.radius=.102;leg.height=.72;_add(leg,Vector3(.145*side,.43,.02),cloth_shadow)
		_box(Vector3(.205,.13,.36),Vector3(.145*side,.10,-.085),shoe_mat)
	# Nose bridge/tip and mouth are broken into smaller volumes.
	_box(Vector3(.038,.115,.044),Vector3(0,1.84,-.218),skin_shadow,Vector3(8,0,0))
	_sphere(.036,.045,Vector3(0,1.785,-.239),skin,Vector3(.82,.66,.62))
	_box(Vector3(.105 if not anomalous else .165,.010,.010),Vector3(0,1.715,-.233),_material(Color(.13,.055,.048),.80))
	# Under-eye/nasolabial shadows add structure without textures.
	for side:float in [-1.0,1.0]:_box(Vector3(.052,.008,.008),Vector3(.075*side,1.80,-.232),_material(skin_color.darkened(.20),.95),Vector3(0,0,28*side))
	if anomalous:
		var halo:=OmniLight3D.new();halo.position=Vector3(0,1.72,.10);halo.light_color=Color(.40,.50,.62);halo.light_energy=.065;halo.omni_range=1.20;add_child(halo)

func _build_signature_customer()->void:
	# The agreed distinctive gentleman: bowler-style hat, round glasses and exaggerated curled beard.
	var coat:=_material(Color(.17,.073,.036),.94);var hat:=_material(Color(.12,.052,.028),.88);var band:=_material(Color(.045,.021,.015),.80)
	var beard:=_material(Color(.40,.235,.095),.99);var beard_hi:=_material(Color(.56,.35,.16),.99);var lens:=_material(Color(.012,.010,.009),.18,.10);var metal:=_material(Color(.43,.34,.22),.32,.58)
	_box(Vector3(.69,.72,.085),Vector3(0,1.17,-.323),coat)
	# Coat lapels.
	_box(Vector3(.22,.38,.045),Vector3(-.13,1.42,-.34),_material(Color(.23,.10,.05),.93),Vector3(0,0,-22));_box(Vector3(.22,.38,.045),Vector3(.13,1.42,-.34),_material(Color(.12,.05,.028),.94),Vector3(0,0,22))
	_cyl(.315,.045,Vector3(0,2.08,0),hat);var crown:=CylinderMesh.new();crown.top_radius=.205;crown.bottom_radius=.245;crown.height=.30;_add(crown,Vector3(0,2.21,.01),hat);_cyl(.249,.055,Vector3(0,2.105,.01),band)
	for side:float in [-1.0,1.0]:
		var glass:=CylinderMesh.new();glass.top_radius=.083;glass.bottom_radius=.083;glass.height=.018;_add(glass,Vector3(.095*side,1.895,-.243),lens,Vector3(90,0,0))
		_box(Vector3(.085,.010,.010),Vector3(.19*side,1.895,-.225),metal)
	_box(Vector3(.040,.010,.010),Vector3(0,1.895,-.248),metal)
	# Dense center beard.
	_sphere(.175,.31,Vector3(0,1.68,-.252),beard,Vector3(1.07,.74,.57))
	var lower:=CapsuleMesh.new();lower.radius=.102;lower.height=.52;_add(lower,Vector3(0,1.46,-.258),beard_hi,Vector3(5,0,0),Vector3(.92,1,.70))
	# Six sculptural locks, closer to the user's reference silhouette.
	for side:float in [-1.0,1.0]:
		var moust:=CapsuleMesh.new();moust.radius=.025;moust.height=.29;_add(moust,Vector3(.105*side,1.755,-.282),beard,Vector3(0,0,70*side))
		var curl:=TorusMesh.new();curl.inner_radius=.024;curl.outer_radius=.068;_add(curl,Vector3(.225*side,1.79,-.278),beard_hi,Vector3(90,0,0),Vector3(.88,1,1))
		for j:int in range(3):
			var lock:=CapsuleMesh.new();lock.radius=.020;lock.height=.33+.06*j;_add(lock,Vector3((.16+.075*j)*side,1.58-.11*j,-.257),beard if j%2==0 else beard_hi,Vector3(0,0,(26+22*j)*side))
			var tip:=TorusMesh.new();tip.inner_radius=.016;tip.outer_radius=.047;_add(tip,Vector3((.22+.105*j)*side,1.47-.16*j,-.258),beard_hi,Vector3(90,0,0),Vector3(.75,1,1))

func walk_to(target:Vector3,duration:float=2.5)->Signal:
	var resolved:=_resolve_target(target);look_at(Vector3(resolved.x,global_position.y+1.0,resolved.z),Vector3.UP);var tween:=create_tween();tween.set_trans(Tween.TRANS_SINE);tween.set_ease(Tween.EASE_IN_OUT);tween.tween_property(self,"global_position",resolved,duration);return tween.finished

func _resolve_target(target:Vector3)->Vector3:
	if Vector2(target.x-LEGACY_REGISTER_TARGET.x,target.z-LEGACY_REGISTER_TARGET.z).length()<=REGISTER_TARGET_EPSILON:return REGISTER_WAIT_POSITION
	return target
