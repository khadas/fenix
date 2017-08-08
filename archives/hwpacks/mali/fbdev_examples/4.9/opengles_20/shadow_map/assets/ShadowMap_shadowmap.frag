/* vim:set sts=4 ts=4 noexpandtab cindent syntax=c: */
/*
 * This confidential and proprietary software may be used only as
 * authorised by a licensing agreement from ARM Limited
 * (C) COPYRIGHT 2009 ARM Limited
 * ALL RIGHTS RESERVED
 * The entire notice above must be reproduced on all authorised
 * copies and copies may only be made to the extent permitted
 * by a licensing agreement from ARM Limited.
 */

#version 100

precision mediump float;

uniform sampler2D u_s2dShadowMap;
uniform vec4 u_v3Specular;
uniform vec4 u_v3GlobalAmbient;

varying vec4 v_v4TexCoord;
varying vec4 v_v4Normal;
varying vec4 v_v4FillColor;
varying vec4 v_v4LightDir;
varying vec4 v_v4ViewDir;

void main()
{
	const vec3 Ambient = vec3(0.1, 0.1, 0.1);
	const float Specular = 90.0;
	vec3 LightDir = normalize( v_v4LightDir.xyz );
	vec3 Half = normalize( v_v4LightDir.xyz + v_v4ViewDir.xyz );
	vec3 Normal = normalize( v_v4Normal.xyz );

	/* Calculate diffuse intensity */
	float NoL = dot( Normal, LightDir );
	float intensityDiffuse = clamp(NoL, 0.0, 1.0);
	
	/* Calculate specular intensity */
	float NoH = clamp(dot(Normal, Half), 0.0, 1.0);
	float intensitySpecular = pow(NoH, Specular);

	/* Draw main scene - read and compare shadow map. */
	vec2 vfDepth = texture2DProj(u_s2dShadowMap, v_v4TexCoord).xy;
	float fDepth = (vfDepth.x * 10.0 + vfDepth.y);
	
	/* Unpack the light distance. See how it is packed in the shadow.frag file */
	float fLDepth = (10.0-v_v4TexCoord.z) + 0.1 - fDepth ;
	float fLight = 1.0;
	if(fDepth>0.0 && fLDepth<0.0)
		{
		fLight = 0.2;
		/* Make sure there is no specular effect on obscured fragments */
		intensitySpecular = 0.0;
		}
	
	gl_FragColor = u_v3GlobalAmbient + vec4(Ambient * v_v4FillColor.rgb +
                                          v_v4FillColor.rgb * fLight * intensityDiffuse +
                                          u_v3Specular.rgb * intensitySpecular,
                                          1.0);
}

