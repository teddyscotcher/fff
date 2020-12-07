shader_type canvas_item;

uniform vec3 change_color = vec3(0.9, 0, 0);
//SHADER TURNS SHADES OF BLUE RED, ONLY REALLY WORKS WITH THE SNOWBALL LAUNCHER SPRITE CAUSE IT ONLY CHECKS FOR SHADES OF WHITE AS A PRECAUTION
void fragment() {
    vec4 curr_color = texture(TEXTURE,UV); // Get current color of pixel
	
	//If blue of current colour is greater than 0 and it's not a shade of white.
    if (curr_color.b > 0.0 && !(curr_color.r == curr_color.g || curr_color.g == curr_color.b)){
        COLOR = curr_color * vec4(change_color.r * 3.0,change_color.g * 3.0,change_color.b * 3.0,1);
	}else{
		//Otherwise, just set it to the colour it already is.
        COLOR = curr_color;
    }
}