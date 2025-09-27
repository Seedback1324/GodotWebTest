extends Control

var host_command_func: Callable

# --- GDWEB HOST INTERFACE FUNCTIONS (REQUIRED) ---

# 1. Called by the host to inject the command function reference.
func set_host_callable(callable_func: Callable):
	host_command_func = callable_func
	
# 2. Universal function that any remote script calls to issue commands.
func host_call(command: String, args: Array = []):
	if host_command_func.is_valid():
		host_command_func.call(command, args)
	else:
		print("Host Error: Communication channel not set up. Cannot call host.")

# --- HOST CALLBACKS (REQUIRED) ---

# Utility to check if a download failed (returns true if data is empty)
func _is_data_failed(data: PackedByteArray) -> bool:
	return data.size() == 0

# 1. Called for 'get_scene' requests.
func host_callback_scene_data(data: PackedByteArray):
	if _is_data_failed(data):
		print("FAILED: Scene download failed.")
		return
		
	print("SUCCESS: Received SCENE data. Size: %d bytes." % data.size())


# 2. Called for 'get_file' requests.
func host_callback_file_data(data: PackedByteArray):
	if _is_data_failed(data):
		print("FAILED: File download failed.")
		return
		
	print("SUCCESS: Received FILE data. Size: %d bytes." % data.size())


# 3. Called for 'load_script' requests.
func host_callback_loaded_script(data: PackedByteArray):
	if _is_data_failed(data):
		print("FAILED: Script download failed.")
		return
		
	print("SUCCESS: Received SCRIPT data. Size: %d bytes. Compiling...")
	
	var script_text = data.get_string_from_utf8()
	var script = GDScript.new()
	
	script.source_code = script_text
	
	var error = script.reload() 
	
	if error != OK:
		print("Error compiling script: %s" % error)
		return
		
	print("Script loaded and compiled successfully!")
	
	var dynamic_instance = script.new()
	if dynamic_instance.has_method("run_main"):
		dynamic_instance.run_main(self)
