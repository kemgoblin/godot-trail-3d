@tool
class_name Trail3D extends MeshInstance3D

enum TrailProcessMode {
	PHYSICS,
	IDLE,
	MANUAL,
}

# separate mesh variable for static typing
var _mesh: ImmediateMesh:
	set(new_mesh):
		_mesh = new_mesh
		mesh = _mesh

@export var origin_a: Node3D:
	set(value):
		origin_a = value
		update_configuration_warnings()
@export var origin_b: Node3D:
	set(value):
		origin_b = value
		update_configuration_warnings()
var last_position_a: Vector3
var last_position_b: Vector3

var particles: Array[TrailParticle]
@export var lifetime: float = 1
@export var width_curve: Curve
@export var color_gradient: Gradient
@export var uv_scale: float = 1
var whole_distance: float
@export var emit_distance: float = 0.1

@export var trail_process_mode := TrailProcessMode.IDLE


func _ready() -> void:
	_mesh = ImmediateMesh.new()
	top_level = true
	transform = Transform3D()
	set_meta("_edit_lock_", true)


func _process(delta: float) -> void:
	if trail_process_mode == TrailProcessMode.IDLE:
		update(delta)


func _physics_process(delta: float) -> void:
	if trail_process_mode == TrailProcessMode.PHYSICS:
		update(delta)


func update(delta: float) -> void:
	if not (origin_a and origin_b):
		return
	
	# emit particle once emit distance threshold has been crossed
	if is_visible_in_tree():
		var distance_a := last_position_a.distance_to(origin_a.global_position)
		var distance_b := last_position_b.distance_to(origin_b.global_position)
		var threshold_crossed: bool = false
		threshold_crossed = distance_a > emit_distance or distance_b > emit_distance
		if threshold_crossed:
			var particle := TrailParticle.new()
			particle.position_a = origin_a.global_position
			particle.position_b = origin_b.global_position
			particle.uv_x = whole_distance
			particle.lifetime = lifetime
			particle.time_left = particle.lifetime
			particles.append(particle)
			last_position_a = origin_a.global_position
			last_position_b = origin_b.global_position
			whole_distance += (distance_a + distance_b) / 2.0
	
	# build mesh from particles
	_mesh.clear_surfaces()
	if particles.size() < 2:
		return
	_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	for i in particles.size():
		var particle := particles[i]
		
		var position_a := particle.position_a
		var position_b := particle.position_b
		if i == particles.size() - 1:
			position_a = origin_a.global_position
			position_b = origin_b.global_position
		
		var center := (position_a + position_b) / 2.0
		var offset := (position_a - position_b) / 2.0
		
		var lifetime_percentage := 1.0 - (particle.time_left / particle.lifetime)
		if width_curve:
			offset *= width_curve.sample_baked(lifetime_percentage)
		var color := Color.WHITE
		if color_gradient:
			color = color_gradient.sample(lifetime_percentage)
		
		_mesh.surface_set_color(color)
		_mesh.surface_set_uv(Vector2(particle.uv_x * uv_scale, 0))
		_mesh.surface_add_vertex(center + offset)
		
		_mesh.surface_set_color(color)
		_mesh.surface_set_uv(Vector2(particle.uv_x * uv_scale, 1))
		_mesh.surface_add_vertex(center - offset)
	_mesh.surface_end()
	
	# remove old particles
	for i in range(particles.size() - 1, -1, -1):
		var particle := particles[i]
		particle.time_left -= delta
		if particle.time_left <= 0:
			particles.remove_at(i)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	
	if not (origin_a and origin_b):
		warnings.push_back("Origin nodes not set, trail will not render")
	
	return warnings


class TrailParticle:
	var position_a: Vector3
	var position_b: Vector3
	var uv_x: float
	var lifetime: float
	var time_left: float
