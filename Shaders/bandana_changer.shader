shader_type canvas_item;

uniform vec3 team_color = vec3(1.0, 1.0, 1.0);
//SHADER TURNS SHADES OF GREY RED.
void fragment() {
	vec4 acc_t_color = vec4(team_color.r, team_color.g, team_color.b, 1);
    vec4 curr_color = texture(TEXTURE,UV); // Get current color of pixel
	
	//If a shade of grey (this can be figured out if all shades are equal to each other.)
    if (curr_color.r == curr_color.g && curr_color.r == curr_color.b){
        COLOR = curr_color * acc_t_color;
	}else{
		//Otherwise, just set it to the colour it already is.
        COLOR = curr_color;
    }
}