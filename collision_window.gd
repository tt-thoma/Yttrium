extends RigidBody2D

var has_polygon: bool = false
var furthest: float
var size: Vector2i
var half_size: Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Window.size = get_window().size

func set_debug(debug) -> void:
	if not debug:
		$"Window/Debug Cross".queue_free()

func set_polygon(polygon) -> void:
	$CollisionPolygon2D.set_polygon(polygon)

func add_to_window(element) -> void:
	$Window.add_child(element)
	if not is_instance_of(element, Polygon2D):
		return
	
	for child in $Window.get_children():
		if not is_instance_of(child, Polygon2D):
			continue
		if not has_polygon:
			has_polygon = true
			furthest = child.polygon[0].length()
		
		for point in child.polygon:
			var length = point.length()
			if length > furthest:
				furthest = length
	@warning_ignore("narrowing_conversion")
	size = 2*Vector2i(furthest, furthest)
	# Windows (OS) doesn't like less than 120px wide windows
	size.x = max(120, size.x)
	half_size = size/2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for child in $Window.get_children():
		if not is_instance_of(child, Polygon2D):
			continue
		child.rotation = rotation
	
	if not $Window.mode == Window.MODE_WINDOWED:
		$Window.mode = Window.MODE_WINDOWED
	
	if size != $Window.size:
		$Window.size = size
	
	$Window.position = Vector2i(position) - half_size

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_parent().get_parent().quit()

func _on_window_close_requested() -> void:
	get_parent().get_parent().quit()
