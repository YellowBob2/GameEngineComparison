extends Control

# The website to load
const HOME_PAGE = "https://www.canva.com/design/DAHAr7FXiaE/rehff2vzk660nmxPdCwtTg/view"

# Reference to the active browser object
var current_browser: GdBrowserView = null
var mouse_pressed: bool = false
@onready var textureRext : TextureRect = $Panel/VBox/TextureRect
@export var frame : TextureRect


# ==============================================================================
# 1. INITIALIZATION (Runs once at game start)
# ==============================================================================
func _ready():
	# Start hidden and disable input processing so it doesn't steal mouse clicks
	hide()
	frame.hide()
	set_process_input(false) 
	
	# Initialize the CEF Core (must happen once)
	# We do NOT create the browser view yet.
	if not $CEF.initialize({"incognito": true, "enable_media_stream": true}):
		push_error("Failed to initialize CEF: " + $CEF.get_error())

# ==============================================================================
# 2. OPEN / CLOSE LOGIC (Called by your Computer script)
# ==============================================================================
func open():
	# Show the UI
	
	show()
	frame.show()
	set_process_input(true) # Enable keyboard/mouse for this node
	
	# Wait one frame for the UI to pop up and calculate its size
	await get_tree().process_frame
	
	# Lazy Loading: Only create the browser the first time we open it
	if current_browser == null:
		print("Creating Browser for the first time...")
		current_browser = await $CEF.create_browser(HOME_PAGE, textureRext, {
			"javascript": true, 
			"webgl": true, 
			"user_gesture_required": false 
		})
	else:
		# If it already exists, just make sure it fits the screen
		current_browser.resize(textureRext.get_size())

func close():
	hide()
	frame.hide()
	set_process_input(false) # Stop listening to keys
	# Optional: You could destroy the browser here to save RAM, 
	# but keeping it alive makes re-opening instant.

# ==============================================================================
# 3. INPUT HANDLING
# ==============================================================================
func _on_texture_rect_resized():
	if current_browser != null:
		current_browser.resize(textureRext.get_size())

func _on_TextureRect_gui_input(event):
	if current_browser == null: return

	# Mouse Interactions
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			current_browser.set_mouse_wheel_vertical(2)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			current_browser.set_mouse_wheel_vertical(-2)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			mouse_pressed = event.pressed
			if mouse_pressed: current_browser.set_mouse_left_down()
			else: current_browser.set_mouse_left_up()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			mouse_pressed = event.pressed
			if mouse_pressed: current_browser.set_mouse_right_down()
			else: current_browser.set_mouse_right_up()

	elif event is InputEventMouseMotion:
		if mouse_pressed: current_browser.set_mouse_left_down()
		current_browser.set_mouse_moved(event.position.x, event.position.y)

func _input(event):
	# If the UI is hidden, ignore input (Safety check)
	if not visible: return

	# HANDLE EXITING (Escape Key)
	if event.is_action_pressed("ui_cancel"): # Default Godot "Escape" action
		close()
		return

	if current_browser == null: return

	if event is InputEventKey:
		# Fix for the Dot (.) key
		if event.pressed and (event.keycode == KEY_PERIOD or event.keycode == KEY_KP_PERIOD):
			current_browser.execute_javascript("document.execCommand('insertText', false, '.');")
			return 

		# Send other keys
		var key_to_send = event.unicode if event.unicode != 0 else event.keycode
		current_browser.set_key_pressed(key_to_send, event.pressed, event.shift_pressed, event.alt_pressed, event.is_command_or_control_pressed())
