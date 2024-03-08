shader_type spatial;
render_mode unshaded, depth_draw_always;

uniform float hotspotPos = 0.0f;
uniform float hotspotRadius = 0.25f;
uniform float hotspotAtten = 1.0f;
uniform vec3 basePosition = vec3(0.0f, 0.0f, 0.0f);

float randf(float ofs)
{
	return fract(sin(dot(vec2(ofs, ofs), vec2(12.9898, 4.1414))) * 43758.5453);
}

float smin(float d1, float d2, float k)
{
	float h = clamp(0.5f + 0.5f*(d2-d1)/k, 0.0f, 1.0f);
	return mix(d2, d1, h) - k*h*(1.0f-h);
}

float sdSphere(vec3 p, float s)
{
	return length(p) - s;
}

float sdBox(vec3 p, vec3 b)
{
	vec3 q = abs(p) - b;
	return length(max(q, 0.0f)) + min(max(q.x, max(q.y, q.z)), 0.0f);
}

//Distance functions
float map(vec3 p)
{
	float tOffset[64];
	vec3 spherePos[64];
	float sphere[64];
	
	float index = 0.0f;
	float result = 0.0;
	
	for(int i=0; i<2; i++)
	{
		index += 1.0f;
		tOffset[i] = TIME + 2.0*randf(index);
		spherePos[i] = basePosition + vec3(0.08f * sin(TIME * 1.2f*randf(index + 0.1f)), 0.05f + 0.4f*randf(index + 0.2f) + 0.06f * cos(tOffset[i] * 1.2f*randf(index + 0.3f)), 0.05f*sin(tOffset[i]*1.6f*randf(index + 0.4f)));
		sphere[i] = sdSphere(p - spherePos[i], 0.035f + 0.025f*randf(index));
	}
	result = smin(sphere[0], sphere[1], 0.12f*randf(index+0.5f));
	
	for(int i=2; i<64; i++)
	{
		index += 1.0f;
		tOffset[i] = TIME + 2.0*randf(index);
		spherePos[i] = basePosition + vec3(0.08f * sin(TIME * 1.2f*randf(index)), 0.4f*randf(index) + 0.06f * cos(tOffset[i] * 1.2f*randf(index)), 0.05f*sin(tOffset[i]*1.6f*randf(index)));
		sphere[i] = sdSphere(p - spherePos[i], 0.035f + 0.025f*randf(index));
		
		result = smin(sphere[i], result, 0.12f*randf(index+0.5f));
	}
	
	return result;
}
//Thanks to Kishimisu on YouTube for explaining this implementation of raymarching!
void fragment() {
	vec3 ro = CAMERA_POSITION_WORLD; //ray origin
	vec3 rd = (INV_VIEW_MATRIX * vec4(-VIEW, 0.0f)).xyz; //ray direction
	vec3 col = vec3(0.0f); //final pixel color
	float rim = 1.0f;
	
	float t = 0.0f; //total distance travelled
	
	//Raymarching
	for (int i = 0; i < 80; i++)
	{
		vec3 p = ro + rd * t; //position along the ray
		
		float d = map(p); //current distance to the scene
		
		t += d; //march the ray
		//rim = float(i)/40.0f;
		rim = 1.0f - clamp(length(p), 0.2f, 0.8f);
		col = mix(vec3(1.0f, 0.3f, 0.0f), vec3(0.1f, 0.0f, 0.1f), clamp(pow(length(p - vec3(basePosition.x, basePosition.y + hotspotPos, basePosition.z))/hotspotRadius, hotspotAtten), 0.0f, 1.0f));
		
		if (d < 0.001f || t > 100.0f) break;
	}
	//col = mix(vec3(1.0f, 0.3f, 0.0f), vec3(0.1f, 0.0f, 0.1f), vec3(clamp(t / 3.0f, 0.0f, 1.0f)));
	
	ALBEDO = col;
	ALPHA = (1.0f - clamp(t/100.0f, 0.0f, 1.0f)) * 0.5f;// * rim;
}