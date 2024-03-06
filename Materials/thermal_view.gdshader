shader_type spatial;
render_mode unshaded, depth_draw_always;

struct blobSegment {
	float dist;
	vec3 col;
};

float randf(float ofs)
{
	return fract(sin(dot(vec2(TIME, ofs), vec2(12.9898, 4.1414))) * 43758.5453);
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
	float tOffset1 = TIME+1.0f;
	float tOffset2 = TIME+2.0f;
	float tOffset3 = TIME;
	vec3 spherePos1 = vec3(0.08f * sin(TIME * 1.2f), 0.06f * cos(tOffset1 * 1.1f), 0.05f*sin(tOffset2*1.6f));
	vec3 spherePos2 = vec3(0.08f * cos(TIME * 0.7f), 0.06f * sin(tOffset2 * 0.6f), 0.05f*sin(tOffset1*1.4f));
	vec3 spherePos3 = vec3(0.08f * sin(TIME * 2.0f), 0.06f * cos(tOffset3 * 2.1f), 0.05f*sin(tOffset3*1.2f));
	float sphere1 = sdSphere(p - spherePos1, 0.1f);
	float sphere2 = sdSphere(p - spherePos2, 0.1f);
	float sphere3 = sdSphere(p - spherePos3, 0.1f);
	
	float sphere4 = sdSphere(p, 0.1f);
	
	return smin(sphere1, smin(sphere2, smin(sphere3, sphere4, 0.15f), 0.12f), 0.05f);
}
//Thanks to Kishimisu on YouTube for this implementation of raymarching!
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
		//rim = float(i)/5.0f;
		rim = 1.0f - clamp(length(p)/0.25f, 0.2f, 0.8f);
		col = mix(vec3(1.0f, 0.3f, 0.0f), vec3(0.1f, 0.0f, 0.1f), clamp(length(p)/0.25f, 0.0f, 1.0f));
		
		if (d < 0.001f || t > 100.0f) break;
	}
	//col = mix(vec3(1.0f, 0.3f, 0.0f), vec3(0.1f, 0.0f, 0.1f), vec3(clamp(t / 3.0f, 0.0f, 1.0f)));
	
	ALBEDO = col;
	ALPHA = (1.0f - clamp(t/100.0f, 0.0f, 1.0f)) * rim;
}