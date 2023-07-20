extends Node





enum VAR_TYPE{
	INT,
	FLOAT,
	BOOL
}

class SHADER_VARIABLE:
	var _name: String
	var _type: VAR_TYPE
	var _type_str: String
	var bool_value: bool
	var start_value: float
	var has_range: bool
	var _min: float = 1.0
	var _max: float = 0.0
	var _step: float = 1.0
	
	func _init(_name: String, _type:VAR_TYPE,has_range:bool, start_value: float, _min: float, _max: float, _step: float, bool_value:bool):
		self._name = _name
		self._type = _type
		self.has_range = has_range
		self.start_value = start_value
		self._min = _min
		self._max = _max
		self._step = _step
		self._type_str = "int"
		if _type == VAR_TYPE.FLOAT:
			self._type_str = "float"
		elif _type == VAR_TYPE.BOOL:
			self._type_str = "bool"
		self.bool_value = bool_value

	func get_var_def() -> String:
		var format: String = "%s %s;"
		return format % [self._type_str, self._name]

# Called when the node enters the scene tree for the first time.
func parse(editor_name, editor_id, shader_text: String):
	var VARIABLE_MAP: Array[SHADER_VARIABLE] = []
	var shader_prefix: String = "
#version 450
layout(local_size_x = 32, local_size_y = 32) in;
layout(set = 0, binding = 0, rgba32f) readonly uniform image2D source;
layout(set = 0, binding = 1, rgba32f) writeonly uniform image2D target_image;
layout(set = 0, binding = 2, std430) readonly buffer MyDataBuffer {

}
buf;

"

	var shader_image_load: String = "
	ivec2 index = ivec2(gl_GlobalInvocationID.xy);
	
	vec4 color = imageLoad(source, index);
"

	var shader_image_store: String = "
	imageStore(target_image, index, color);
	"
#	shader_text += "\n"

#	var s: String = "
#	$define float a = 1; range(1,2,3)
#	$define float b = 2;
#
#	$define int asd = 10; range(0, 100)
#
#	void main() {
#	color = vec4(1.0);
#	color = vec4(1.0,0.0,0.0,0.0) * buf.a;
#}
#"

	var custom_image_store: String
	
	var use_base_imagestore = true
	var splits = shader_text.split("\n")
	var line_index = 0
	var main_func_index = 0
	var lines_to_delete = []
	
	for line in splits:
		line = line.strip_escapes()
		line = line.strip_edges(true,false)
		print("LINE: ", line)
		if line.contains("void main()"):
			main_func_index = line_index + 1

		elif line.begins_with("#"):
			lines_to_delete.push_back(line_index)
		elif line.begins_with("$define"):
			lines_to_delete.push_back(line_index)
#			var variable: SHADER_VARIABLE =
			var line_split = line.split(";")
			var variable_definition = line_split[0].split(" ")
			print(line_split)
			print("VARIABLE DEF: ", variable_definition)
			var _type = get_type(variable_definition[1])
			var _name = variable_definition[2]
			var _start_val = 0
			var bool_value: bool = false
			if _type == VAR_TYPE.BOOL:
				bool_value = true if variable_definition[4] == "true" else false
			else:
				_start_val = float(variable_definition[4])
			var has_range = false
			var _min = 0.0
			var _max = 1.0
			var _step = 1.0
			print(_type)
			print(_name)
			print(_start_val)
#			for part in variable_definition:
			if line_split[1].contains("range(") and _type != VAR_TYPE.BOOL:
				print("THERE IS A RANGE GIVEN")
				has_range = true

				var range_split = line_split[1].split(",")
				_min = float(range_split[0][range_split[0].length() - 1])
				_max = float(range_split[1])
				if range_split.size() == 3:
					_step = float(range_split[2])
				print(float(_min))
				print(float(_max))
				print(float(_step))
			print("MIN1: ", _min)
			print("MAX1: ", _max)
			print("STEP1: ", _step)
			var shader_var: SHADER_VARIABLE = SHADER_VARIABLE.new(_name, _type, has_range, _start_val, _min, _max, _step, bool_value)
			VARIABLE_MAP.push_back(shader_var)
			print("MIN2: ", shader_var._min)
			print("MAX2: ", shader_var._max)
			print("STEP2: ", shader_var._step)
			if _type == VAR_TYPE.BOOL:
				print("VAR IS A BOOLEAN VALUE")
#		elif line.begins_with("int") or line.begins_with("shared"):
#			lines_to_delete.push_back(line_index)
		elif line.begins_with("$override"):
			print("OVERRIDE!!!")
			lines_to_delete.push_back(line_index)
			use_base_imagestore = false
			var split_lines = line.split(" ")
			custom_image_store = " ".join(split_lines.slice(1))
			custom_image_store += "\n"
		line_index += 1

#	splits.remove_at(0)
#	splits.remove_at(1)
	for line in len(lines_to_delete):
		splits.remove_at(lines_to_delete[line] - line)

	shader_prefix = insert_variables_into_prefix(shader_prefix.split("\n"), VARIABLE_MAP)
	
	splits.insert(main_func_index - len(lines_to_delete), shader_image_load)
	splits.insert(0, shader_prefix)
	if use_base_imagestore:
		splits.insert(splits.size() - 2, shader_image_store)
	else:
		splits.insert(splits.size() - 2, custom_image_store)
	print("\n".join(splits))

	var final_shader_code = "\n".join(splits)
	
	
	var dev = RenderingServer.get_rendering_device()
	var rd_shader = RDShaderSource.new()
	rd_shader.source_compute = final_shader_code
	var spirv = dev.shader_compile_spirv_from_source(rd_shader)
	print("ERROR: ", spirv.compile_error_compute)
	var shader = dev.shader_create_from_spirv(spirv)

	if spirv.compile_error_compute == "":
		var index_ = min(1, editor_id)
		AppNodeConstants.get_right_side_panel().create_custom_effect_panel(VARIABLE_MAP, shader, index_)

func get_type(part: String) -> VAR_TYPE:
	if part == "float":
		return VAR_TYPE.FLOAT
	elif part == "bool":
		return VAR_TYPE.BOOL
#	elif part == "int":
	return VAR_TYPE.INT


func insert_variables_into_prefix(prefix: PackedStringArray, map: Array[SHADER_VARIABLE]):
	var index_to_insert = 7
	for key in map:
		prefix.insert(index_to_insert, key.get_var_def())
		index_to_insert += 1
#	print("FINAL PREFIX CODE:")
#	print("\n".join(prefix))
	return "\n".join(prefix)


