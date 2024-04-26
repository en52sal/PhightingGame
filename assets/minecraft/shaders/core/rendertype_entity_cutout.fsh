/*
=== COPYRIGHT NOTICE ===
This shader code is written by KabanFriends.
Some portions of the code are based on BalintCsala/minecraft-vanilla-skybox on GitHub.

Do not re-distribute this code without express permission from KabanFriends.
Please see the included LICENSE file for more information.
*/

#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec4 lightMapColor;
in vec4 overlayColor;
in vec2 texCoord0;
in vec4 normal;

out vec4 fragColor;

// Skybox
#moj_import <util.glsl>

#define UV_FACTOR 0.9965;

in vec3 toBlock;
in vec2 cornerUV;
in vec2 uvRatio;
in vec2 oneTexel;
in float isSkybox; //1.0 if skybox

float m(float x) {
   return x * 0.5 + 0.5;
}

// https://github.com/BalintCsala/minecraft-vanilla-skybox/blob/main/assets/minecraft/shaders/program/skybox.fsh
vec3 sampleSkybox(sampler2D skyboxSampler, vec3 direction) {
	float l = max(max(abs(direction.x), abs(direction.y)), abs(direction.z));
	vec3 dir = direction / l;
	vec3 absDir = abs(dir);
	
	vec2 skyboxUV;
	vec4 backgroundColor;
	if (absDir.x >= absDir.y && absDir.x > absDir.z) {
		if (dir.x > 0) {
			skyboxUV = vec2(0, 0.5) + (dir.zy * vec2(1, -1) + 1) / 2 / vec2(3, 2) * UV_FACTOR;
		} else {
			skyboxUV = vec2(2.0 / 3, 0.5) + (-dir.zy + 1) / 2 / vec2(3, 2) * UV_FACTOR;
		}
	} else if (absDir.y >= absDir.z) {
		if (dir.y > 0) {
			skyboxUV = vec2(1.0 / 3, 0) + (dir.xz * vec2(-1, 1) + 1) / 2 / vec2(3, 2) * UV_FACTOR;
		} else {
			skyboxUV = vec2(0, 0) + (-dir.xz + 1) / 2 / vec2(3, 2) * UV_FACTOR;
		}
	} else {
		if (dir.z > 0) {
			skyboxUV = vec2(1.0 / 3, 0.5) + (-dir.xy + 1) / 2 / vec2(3, 2) * UV_FACTOR;
		} else {
			skyboxUV = vec2(2.0 / 3, 0) + (dir.xy * vec2(1, -1) + 1) / 2 / vec2(3, 2) * UV_FACTOR;
		}
	}
	return texture(skyboxSampler, cornerUV + skyboxUV * uvRatio).rgb;
}

void main() {
	// Skybox
    if (compfloat(isSkybox, 1.0)) {
        vec3 tb = normalize(toBlock);
        vec3 skycol = sampleSkybox(Sampler0, tb);
        fragColor = vec4(skycol, 1.0);
        return;
    }

	// Vanilla
	vec4 color = texture(Sampler0, texCoord0);
    if (color.a < 0.1) {
        discard;
    }
    color *= vertexColor * ColorModulator;
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
    color *= lightMapColor;
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
