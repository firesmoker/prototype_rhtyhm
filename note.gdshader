shader_type canvas_item;
uniform vec4 color: source_color;
uniform float alpha = 1;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR.rgb = color.rgb;
	if (COLOR.a > alpha) {
		COLOR.a = alpha;
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
