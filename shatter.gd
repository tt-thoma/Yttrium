extends Node2D

@onready var SIZE: Vector2i = DisplayServer.screen_get_size()
@onready var SIZE_NORMAL: float = SIZE.length()
@onready var WINDOW: Window = get_window()
@onready var CUTOUT: PackedVector2Array = [
		Vector2.ZERO, Vector2(SIZE.x, 0), 
		SIZE,         Vector2(0, SIZE.y),
		Vector2.ZERO
	]

@export var DEBUG: bool = false
var CollisionWindow: PackedScene = load("res://collision_window.tscn")
var VersionFile: GDScript = load("res://version.gd")
var quitting: bool = false
var delaunay: Delaunay

func sleep(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func setup_main_window() -> void:
	get_window().borderless = true
	get_window().size = SIZE
	get_window().position = Vector2i.ZERO
	get_window().mode = Window.MODE_MAXIMIZED
	if not DEBUG:
		DisplayServer.window_set_mouse_passthrough([Vector2.ZERO, Vector2.ZERO])

func setup_boxes() -> void:
	$"Right Wall/Hitbox".shape.distance = -SIZE.x
	$Floor/Hitbox.shape.distance = -SIZE.y

func setup_delaunay(amount: int) -> void:
	delaunay = Delaunay.new(Rect2(0, 0, SIZE.x, SIZE.y))
	
	randomize()
	var pos: Vector2i
	var invalid: bool
	for i in range(amount):
		invalid = true
		while invalid:
			invalid = false
			pos = Vector2i(randi_range(1, SIZE.x-1), randi_range(1, SIZE.y-1))
			for point in delaunay.points:
				if pos.distance_to(point) < SIZE_NORMAL/(float(amount)/2):
					invalid = true
					break
		delaunay.add_point(pos)

func setup_windows(sites, dividor) -> void:
	var polygon: PackedVector2Array
	var window_obj
	
	var counter: int = 0
	for site in sites:
		counter += 1
		if counter % dividor != 0:
			continue
		
		var polygon_obj: Polygon2D = Polygon2D.new()
		var polygons = Geometry2D.intersect_polygons(CUTOUT, site.polygon)
		match len(polygons):
			0:
				print(CUTOUT)
				push_error("Cutout (see above) has made an empty polygon!")
				continue
			1:
				polygon = polygons[0]
			var other:
				print(CUTOUT)
				push_warning("Coutout (see above) has made " + str(other) + " polygons! Choosing the first")
				polygon = polygons[0]
		
		var top_left: Vector2 = polygon[0]
		for point in polygon:
			if point.x < top_left.x:
				top_left.x = point.x
			if point.y < top_left.y:
				top_left.y = point.y
		
		var center: Vector2 = Vector2.ZERO
		var _tmp_polygon: PackedVector2Array = []
		for point in polygon:
			center += point - top_left
			_tmp_polygon.append(point - top_left)
		center /= len(polygon)
		
		polygon = []
		for point in _tmp_polygon:
			polygon.append(point - center)
		
		polygon_obj.polygon = polygon
		polygon_obj.color = Color(randf(), randf(), randf())
		
		window_obj = CollisionWindow.instantiate()
		window_obj.position = top_left + center
		window_obj.set_debug(DEBUG)
		window_obj.set_polygon(polygon)
		window_obj.add_to_window(polygon_obj)
		
		$Windows.add_child(window_obj)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Yttrium by tt_thoma")
	print("Version: " + VersionFile.VERSION)
	print("Licensed under GPLv3")
	setup_main_window()
	setup_boxes()
	setup_delaunay(50)
	var sites = delaunay.make_voronoi(delaunay.triangulate())
	setup_windows(sites, 3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if get_window().mode != Window.MODE_MAXIMIZED:
		setup_main_window()
	if quitting:
		return
	var mouse_pos: Vector2i = get_global_mouse_position()
	$Mouse.position = mouse_pos

func quit():
	if quitting:
		return
	quitting = true
	$CloseConfirmation.mode = Window.MODE_WINDOWED
	$CloseConfirmation.visible = true
	$Ceiling.queue_free()
	$Floor.queue_free()
	$Mouse.queue_free()
	var can_leave: bool = false
	while not can_leave:
		can_leave = true
		for child in $Windows.get_children():
			if child.position.y < SIZE.y + 20:
				can_leave = false
				break
			else:
				child.queue_free()
		await sleep(0.5)
	get_tree().queue_delete(delaunay)
	get_tree().quit()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		quit()
