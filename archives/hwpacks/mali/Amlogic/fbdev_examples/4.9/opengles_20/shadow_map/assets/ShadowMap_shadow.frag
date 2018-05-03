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
varying vec4 v_v4TexCoord;
void main()
{
	/* Generate shadow map - write fragment depth. */
	float value = 10.0 - v_v4TexCoord.z;
	float v = floor(value);
	float f = value - v;
	float vn = v * 0.1;
	gl_FragColor = vec4(vn, f, 0.0, 1.0);	
}

