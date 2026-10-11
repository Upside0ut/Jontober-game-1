shader_type canvas_item;

// Shader by
// https://godotshaders.com/author/ayzzi_dev/ and
// https://godotshaders.com/author/arlez80/

// added by Circcle
uniform bool enabled = true;

/* ================= SETTINGS ================= */

// Probability of glitch effect happening
uniform float glitch_chance : hint_range(0.0, 1.0) = 0.2;

// Speed of glitch state changes
uniform float glitch_speed = 7.0;

// Number of horizontal slices
uniform float slice_density = 14.0;

// Strength of horizontal displacement for slices
uniform float slice_strength = 0.38;

// Global shake amount
uniform float shake_strength = 0.02;

// Chromatic color separation amount
uniform float chroma_offset = 0.016;

// Digital noise intensity
uniform float noise_strength = 0.2;

// Intensity of color flashes
uniform float color_flash_strength = 0.4;

// Intensity of scanline drop effect
uniform float scanline_strength = 0.18;

// Strength of local warping distortion
uniform float local_warp_strength = 0.14;

/* ================= RANDOM FUNCTIONS ================= */

global uniform float global_shadertime;

// Circcle: found these from here:
// https://www.geeks3d.com/20100831/shader-library-noise-and-pseudo-random-number-generator-in-glsl/
// the original used sin() based pseudo random so it got less precise over global_shadertime
float rand2(vec2 x)
{
    int n = int(x.x * 40.0 + x.y * 6400.0);
    n = (n << 13) ^ n;
    return 1.0 - float( (n * (n * n * 15731 + 789221) + 1376312589) & 0x7fffffff) / 1073741824.0;
}

float rand(float x)
{
    int n = int(x * 40.0 + x * 6400.0);
    n = (n << 13) ^ n;
    return 1.0 - float( (n * (n * n * 15731 + 789221) + 1376312589) & 0x7fffffff) / 1073741824.0;
}

/* ================= FRAGMENT SHADER ================= */

void fragment() {
	// enable bool added by Circcle
	if (enabled)
	{
		vec2 uv = UV;

		// Determine if glitch should happen this frame
		float glitch = step(1.0 - glitch_chance, rand(floor(global_shadertime * glitch_speed)));

		/* ----- SLICES EFFECT ----- */
		float slice_id = floor(uv.y * slice_density + rand(floor(global_shadertime)));
		float slice_rand = rand(slice_id + floor(global_shadertime * glitch_speed));
		float slice_mask = step(0.5, slice_rand) * glitch;

		// Apply horizontal displacement for this slice
		uv.x += (slice_rand - 0.5) * slice_strength * slice_mask;

		/* ----- MICRO JITTER ----- */
		// Small random jitters to add chaos
		float jitter = step(0.85, rand(global_shadertime * 12.0)) * glitch;
		uv.x += (rand(global_shadertime * 3.0) - 0.5) * 0.08 * jitter;

		/* ----- LOCAL WARP ----- */
		// Random local distortion in some slices
		float warp_zone = step(0.65, rand2(vec2(slice_id, global_shadertime)));
		uv += (vec2(rand2(uv + global_shadertime), rand2(uv - global_shadertime)) - 0.5) * local_warp_strength * warp_zone * glitch;

		/* ----- GLOBAL SHAKE ----- */
		uv += vec2(
			rand(global_shadertime * 1.3) - 0.5,
			rand(global_shadertime * 1.7) - 0.5
		) * shake_strength * glitch;

		/* ----- COLOR SPLIT ----- */
		vec4 base = texture(TEXTURE, uv);
		float r = texture(TEXTURE, uv + vec2(chroma_offset * glitch, 0.0)).r;
		float b = texture(TEXTURE, uv - vec2(chroma_offset * glitch, 0.0)).b;
		vec3 color = vec3(r, base.g, b);

		/* ----- DIGITAL NOISE ----- */
		color += (rand2(uv * global_shadertime * 1.5) - 0.5) * noise_strength * glitch;

		/* ----- SCANLINE DROP ----- */
		float scan = step(0.9, rand(uv.y * 100.0 + global_shadertime * 10.0));
		color *= 1.0 - scan * scanline_strength * glitch;

		/* ----- COLOR FLASH ----- */
		vec3 flash_color = vec3(
			step(0.5, rand(global_shadertime + 0.1)),
			step(0.5, rand(global_shadertime + 3.1)),
			step(0.5, rand(global_shadertime + 6.1))
		);
		color = mix(color, flash_color, rand(global_shadertime * 4.0) * color_flash_strength * glitch);

		COLOR = vec4(color, base.a);
	}
}
