extends Node3D

const LEGACY_REGISTER_TARGET := Vector3(3.4, 0.0, -2.8)
const REGISTER_WAIT_POSITION := Vector3(3.55, 0.0, -5.75)
const REGISTER_TARGET_EPSILON: float = 0.35

var display_name:String="Customer"
var anomalous:bool=false
var color:Color=Color(0.45,0.48,0.52)
var character_style:String="default"

func setup(customer_name:String,is_anomalous:bool,body_color:Color,style:String="default")->void:
	display_name=customer_name; anomalous=is_anomalous; color=body_color; character_style=style; _build_body()
	if character_style=="signature_beard" and not anomalous: _build_signature_customer()

func _material(c:Color,roughness:float=0.78,metallic:float=0.0)->StandardMaterial3D:
	var m:=StandardMaterial3D.new(); m.albedo_color=c; m.roughness=roughness; m.metallic=metallic; return m
func _add(mesh:PrimitiveMesh,pos:Vector3,mat:Material,rot:Vector3=Vector3.ZERO,scale_v:Vector3=Vector3.ONE)->void:
	mesh.material=mat; var n:=MeshInstance3D.new(); n.mesh=mesh; n.position=pos; n.rotation_degrees=rot; n.scale=scale_v; add_child(n)

func _build_body()->void:
	var clothes:=_material(color,0.86); var dark:=_material(color.darkened(0.28),0.90); var skin:=_material(Color(0.64,0.53,0.46) if not anomalous else Color(0.49,0.50,0.49),0.88); var shoe_mat:=_material(Color(0.035,0.038,0.04),0.72,0.08)
	var torso:=CapsuleMesh.new(); torso.radius=0.32; torso.height=1.08; _add(torso,Vector3(0,1.08,0),clothes)
	var shoulders:=BoxMesh.new(); shoulders.size=Vector3(0.78,0.18,0.34); _add(shoulders,Vector3(0,1.45,0),clothes)
	var chest:=BoxMesh.new(); chest.size=Vector3(0.50,0.55,0.06); _add(chest,Vector3(0,1.22,-0.285),dark)
	var neck:=CylinderMesh.new(); neck.top_radius=0.09; neck.bottom_radius=0.10; neck.height=0.18; _add(neck,Vector3(0,1.62,0),skin)
	var head:=SphereMesh.new(); head.radius=0.235; head.height=0.47; _add(head,Vector3(0,1.86,0),skin,Vector3.ZERO,Vector3(0.94,1.10,0.90) if anomalous else Vector3.ONE)
	var hair:=SphereMesh.new(); hair.radius=0.238; hair.height=0.26; _add(hair,Vector3(0,1.985,0.015),_material(Color(0.045,0.038,0.032) if not anomalous else Color(0.015,0.018,0.02),0.78),Vector3.ZERO,Vector3(1,0.42,1))
	for side:float in [-1.0,1.0]:
		var eye:=SphereMesh.new(); eye.radius=0.022 if not anomalous else 0.029; eye.height=eye.radius*2; _add(eye,Vector3(0.087*side,1.89,-0.218),_material(Color(0.015,0.018,0.02),0.24))
		var arm:=CapsuleMesh.new(); arm.radius=0.078; arm.height=0.70; _add(arm,Vector3(0.39*side,1.06,0),clothes,Vector3(0,0,6*side))
		var hand:=SphereMesh.new(); hand.radius=0.085; hand.height=0.17; _add(hand,Vector3(0.43*side,0.69,-0.015),skin)
		var leg:=CapsuleMesh.new(); leg.radius=0.105; leg.height=0.72; _add(leg,Vector3(0.15*side,0.43,0),dark)
		var shoe:=BoxMesh.new(); shoe.size=Vector3(0.20,0.13,0.34); _add(shoe,Vector3(0.15*side,0.10,-0.08),shoe_mat)
	var nose:=BoxMesh.new(); nose.size=Vector3(0.045,0.10,0.055); _add(nose,Vector3(0,1.82,-0.235),skin)
	var mouth:=BoxMesh.new(); mouth.size=Vector3(0.10 if not anomalous else 0.17,0.012,0.012); _add(mouth,Vector3(0,1.72,-0.237),_material(Color(0.11,0.045,0.04),0.70))
	if anomalous:
		var halo:=OmniLight3D.new(); halo.position=Vector3(0,1.72,0.10); halo.light_color=Color(0.40,0.50,0.62); halo.light_energy=0.075; halo.omni_range=1.25; add_child(halo)

func _build_signature_customer()->void:
	# M7 second pass: cleaner beard mass, smaller glasses and restrained curled tips.
	var coat:=_material(Color(0.18,0.075,0.035),0.90); var hat:=_material(Color(0.15,0.065,0.03),0.84); var band:=_material(Color(0.055,0.025,0.018),0.74); var beard:=_material(Color(0.42,0.255,0.105),0.98); var beard_hi:=_material(Color(0.57,0.37,0.17),0.98); var lens:=_material(Color(0.018,0.012,0.010),0.14,0.12); var metal:=_material(Color(0.48,0.37,0.23),0.30,0.55)
	var coat_mesh:=BoxMesh.new(); coat_mesh.size=Vector3(0.68,0.70,0.10); _add(coat_mesh,Vector3(0,1.18,-0.315),coat)
	var brim:=CylinderMesh.new(); brim.top_radius=0.31; brim.bottom_radius=0.31; brim.height=0.045; _add(brim,Vector3(0,2.08,0),hat)
	var crown:=CylinderMesh.new(); crown.top_radius=0.21; crown.bottom_radius=0.245; crown.height=0.29; _add(crown,Vector3(0,2.21,0.01),hat)
	var hat_band:=CylinderMesh.new(); hat_band.top_radius=0.249; hat_band.bottom_radius=0.249; hat_band.height=0.055; _add(hat_band,Vector3(0,2.10,0.01),band)
	for side:float in [-1.0,1.0]:
		var glass:=CylinderMesh.new(); glass.top_radius=0.082; glass.bottom_radius=0.082; glass.height=0.018; _add(glass,Vector3(0.095*side,1.90,-0.239),lens,Vector3(90,0,0))
		var temple:=BoxMesh.new(); temple.size=Vector3(0.085,0.010,0.010); _add(temple,Vector3(0.19*side,1.90,-0.225),metal)
	var bridge:=BoxMesh.new(); bridge.size=Vector3(0.040,0.010,0.010); _add(bridge,Vector3(0,1.90,-0.247),metal)
	var upper:=SphereMesh.new(); upper.radius=0.17; upper.height=0.30; _add(upper,Vector3(0,1.69,-0.248),beard,Vector3.ZERO,Vector3(1.05,0.72,0.55))
	var lower:=CapsuleMesh.new(); lower.radius=0.105; lower.height=0.48; _add(lower,Vector3(0,1.48,-0.255),beard_hi,Vector3(4,0,0),Vector3(0.92,1,0.72))
	for side:float in [-1.0,1.0]:
		var moustache:=CapsuleMesh.new(); moustache.radius=0.025; moustache.height=0.25; _add(moustache,Vector3(0.105*side,1.755,-0.278),beard,Vector3(0,0,68*side))
		var curl:=TorusMesh.new(); curl.inner_radius=0.025; curl.outer_radius=0.065; _add(curl,Vector3(0.215*side,1.775,-0.278),beard_hi,Vector3(90,0,0),Vector3(0.85,1,1))
		var side_lock:=CapsuleMesh.new(); side_lock.radius=0.022; side_lock.height=0.31; _add(side_lock,Vector3(0.17*side,1.54,-0.255),beard,Vector3(0,0,24*side))

func walk_to(target:Vector3,duration:float=2.5)->Signal:
	var resolved:=_resolve_target(target); look_at(Vector3(resolved.x,global_position.y+1.0,resolved.z),Vector3.UP); var tween:=create_tween(); tween.set_trans(Tween.TRANS_SINE); tween.set_ease(Tween.EASE_IN_OUT); tween.tween_property(self,"global_position",resolved,duration); return tween.finished
func _resolve_target(target:Vector3)->Vector3:
	if Vector2(target.x-LEGACY_REGISTER_TARGET.x,target.z-LEGACY_REGISTER_TARGET.z).length()<=REGISTER_TARGET_EPSILON: return REGISTER_WAIT_POSITION
	return target
