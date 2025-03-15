# Trail3D

#### Simple ribbon trail using ImmediateMesh

## Features
- Texture UV
- Width curve
- Color gradient
- Works in the editor!

## Usage

1. Add a **Trail3D** node to your scene
2. Set **Origin A** and **Origin B** nodes
3. Add material
	- Standard Godot material:
		- Set cull mode to **Disabled** so you can see your trail from either side
		- Shading will not look correct as normals are not calculated, so set shading mode to **Unshaded**
		- If using a color gradient - enable **Use as Albedo** under Vertex Color
	- Custom shader material:
 		- Add `cull_disabled` and `unshaded` to `render_mode`
   		- Use `COLOR` in your fragment shader for color gradients, for example: `ALBEDO *= COLOR.rgb;`
4. Play around with the cool trail you've made in the editor (not optional)
