extends Control





enum VAR_TYPE{
	INT,
	FLOAT
}

class SHADER_VARIABLE:
	var _name: String
	var _type: VAR_TYPE
	var _type_str: String
	var start_value: float
	var has_range: bool
	var _min: float = 1.0
	var _max: float = 0.0
	var _step: float = 1.0
	
	func _init(_name: String, _type:VAR_TYPE,has_range:bool, start_value: float, _min: float = 0.0, _max: float = 1.0, _step: float = 1.0):
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
		

	func get_var_def() -> String:
		var format: String = "%s %s;"
		return format % [self._type_str, self._name]

# Called when the node enters the scene tree for the first time.
func _ready():
	var VARIABLE_MAP: Dictionary = {}
	var shader_prefix: String = "
#version 450
layout(local_size_x = 32, local_size_y = 32) in;layout(set = 0, binding = 0, rgba32f) readonly uniform image2D source;
layout(set = 0, binding = 1, rgba32f) writeonly uniform image2D target_image;
layout(set = 0, binding = 2) uniform MyDataBuffer {

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

	var s: String = "
	$define float a = 1; range(1,2,3)
	$define float b = 2;
	
	$define int asd = 10; range(0, 100)
	
	void main() {
	color = vec4(1.0);
	color = vec4(1.0,0.0,0.0,0.0) * buf.a;
}
"

	
	

	var splits = s.split("\n")
	var line_index = 0
	var main_func_index = 0
	var lines_to_delete = []
	
	for line in splits:
		line = line.strip_escapes()
		if line.contains("void main()"):
			main_func_index = line_index + 1

		if line.begins_with("#"):
			lines_to_delete.push_back(line_index)
		if line.begins_with("$define"):
			lines_to_delete.push_back(line_index)
#			var variable: SHADER_VARIABLE =
			var line_split = line.split(";")
			var variable_definition = line_split[0].split(" ")
			print(line_split)
			print("VARIABLE DEF: ", variable_definition)
			var _type = get_type(variable_definition[1])
			var _name = variable_definition[2]
			var _start_val = variable_definition[4]
			var has_range = false
			var _min = 0.0
			var _max = 1.0
			var _step = 1.0
			print(_type)
			print(_name)
			print(_start_val)
#			for part in variable_definition:
			if line_split[1].contains("range("):
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

			var shader_var: SHADER_VARIABLE = SHADER_VARIABLE.new(_name, _type, has_range, _min, _max, _step)
			VARIABLE_MAP[_name] = shader_var
		line_index += 1

#	splits.remove_at(0)
#	splits.remove_at(1)
	for line in len(lines_to_delete):
		splits.remove_at(lines_to_delete[line] - line)

	shader_prefix = insert_variables_into_prefix(shader_prefix.split("\n"), VARIABLE_MAP)
	
	splits.insert(main_func_index - len(lines_to_delete), shader_image_load)
	splits.insert(0, shader_prefix)
	splits.insert(splits.size() - 2, shader_image_store)
	print("\n".join(splits))

	var final_shader_code = "\n".join(splits)
	
	
	var dev = RenderingServer.get_rendering_device()
	var rd_shader = RDShaderSource.new()
	rd_shader.source_compute = final_shader_code
	var spirv = dev.shader_compile_spirv_from_source(rd_shader)
	print("ERROR: ", spirv.compile_error_compute)
	var shader = dev.shader_create_from_spirv(spirv)

func get_type(part: String) -> VAR_TYPE:
	if part == "float":
		return VAR_TYPE.FLOAT
#	elif part == "int":
	return VAR_TYPE.INT


func insert_variables_into_prefix(prefix: PackedStringArray, map: Dictionary):
	var index_to_insert = 7
	for key in map:
		prefix.insert(index_to_insert, map[key].get_var_def())
		index_to_insert += 1
#	print("FINAL PREFIX CODE:")
#	print("\n".join(prefix))
	return "\n".join(prefix)


