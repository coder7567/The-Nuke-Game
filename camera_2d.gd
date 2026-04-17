extends Camera2D

@onready var map = $"../Map"
@onready var marker = $"../Marker"

var zoom_speed = 0.1
var dragging = false
var drag_sensitivity = 1.0 
var map_size: Vector2

# Juice Variables
var target_zoom = Vector2.ONE
var zoom_tween: Tween

func _ready():
	if map and map.texture:
		map_size = map.texture.get_size() * map.scale
	target_zoom = zoom

func _process(_delta):
	# 1. Calculate actual visible area
	var visible_size = get_viewport_rect().size / zoom
	var half_screen = visible_size / 2.0

	# 2. Calculate min/max boundaries
	var min_x = -map_size.x / 2 + half_screen.x
	var max_x = map_size.x / 2 - half_screen.x
	var min_y = -map_size.y / 2 + half_screen.y
	var max_y = map_size.y / 2 - half_screen.y

	# 3. Prevent "Over-zooming" out past map edges
	if visible_size.x > map_size.x or visible_size.y > map_size.y:
		var min_zoom_x = get_viewport_rect().size.x / map_size.x
		var min_zoom_y = get_viewport_rect().size.y / map_size.y
		var min_zoom = max(min_zoom_x, min_zoom_y)
		# Force values to the minimum zoom allowed by the map
		target_zoom = Vector2(min_zoom, min_zoom)
		zoom = target_zoom
		return

	# 4. Apply Marker scaling
	if marker:
		marker.scale = Vector2(0.2, 0.2) / zoom

	# 5. Apply Position Clamping
	position.x = clamp(position.x, min_x, max_x)
	position.y = clamp(position.y, min_y, max_y)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			# Zoom In (No hard clamp here, let Map logic handle it)
			apply_zoom_effect(-zoom_speed, 0.5)
		
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			# Zoom Out
			apply_zoom_effect(zoom_speed, -0.5)

		elif event.button_index == MOUSE_BUTTON_RIGHT:
			dragging = event.pressed

	if event is InputEventMouseMotion and dragging:
		position -= event.relative * (drag_sensitivity / zoom.x)

func apply_zoom_effect(zoom_delta: float, rotation_delta: float):
	# Update target_zoom directly
	target_zoom += Vector2(zoom_delta, zoom_delta)
	target_zoom = target_zoom.max(Vector2(0.1, 0.1)) 
	target_zoom = target_zoom.min(Vector2(2.0, 2.0))
	
	if zoom_tween:
		zoom_tween.kill()
		
	zoom_tween = create_tween().set_parallel(true)
	
	# Animate Zoom
	zoom_tween.tween_property(self, "zoom", target_zoom, 0.3)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	
	# Animate Tilt
	zoom_tween.tween_property(self, "rotation_degrees", rotation_delta, 0.1)
	
	# Reset Tilt
	zoom_tween.chain().tween_property(self, "rotation_degrees", 0.0, 0.15)\
		.set_trans(Tween.TRANS_SINE)
