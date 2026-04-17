extends Camera2D

@onready var map = $"../Map"
@onready var camera = $"../Camera2D"
@onready var marker = $"../Marker"
var zoom_speed = 0.1
var dragging = false
var drag_sensitivity = 2
var map_size

func _process(_delta):
	# 1. Calculate actual visible area (Viewport / Zoom)
	var visible_size = get_viewport_rect().size / zoom
	var half_screen = visible_size / 2.0

	# 2. Calculate min/max boundaries
	# Assumes map is centered at (0,0).
	var min_x = -map_size.x / 2 + half_screen.x
	var max_x = map_size.x / 2 - half_screen.x
	var min_y = -map_size.y / 2 + half_screen.y
	var max_y = map_size.y / 2 - half_screen.y

	# 3. Prevent "Over-zooming" (Grey bars appear if visible_size > map_size)
	if visible_size.x > map_size.x or visible_size.y > map_size.y:
		# Optional: Force zoom to stay within map bounds
		var min_zoom_x = get_viewport_rect().size.x / map_size.x
		var min_zoom_y = get_viewport_rect().size.y / map_size.y
		var min_zoom = max(min_zoom_x, min_zoom_y)
		zoom = Vector2(min_zoom, min_zoom)
		return

	# 4. Apply the clamp
	marker.scale = Vector2(0.2, 0.2) / zoom 
	position.x = clamp(position.x, min_x, max_x)
	position.y = clamp(position.y, min_y, max_y)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom -= Vector2(zoom_speed, zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom += Vector2(zoom_speed, zoom_speed)
			zoom = zoom.min(Vector2(2.0, 2.0)) 
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			dragging = event.pressed

	if event is InputEventMouseMotion and dragging:
		# Use camera zoom to adjust speed of panning
		position -= event.relative * drag_sensitivity
		
func _ready():
	map_size = map.texture.get_size() * map.scale
