extends Control

var debug_rect: Rect2 = Rect2()

func update_debug_rect(rect: Rect2):
	debug_rect = rect
	queue_redraw()

func _draw() -> void:
	var center = get_viewport_rect().get_center()
	draw_arc(center, 12.0, 0, PI * 2, 64, Color(1, 1, 1, 1), 1.0)
	
	#draw_rect(debug_rect, Color(0, 1, 0, 1), true)
