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

attribute vec4 a_v4Position;
uniform mat4 u_m4LightMVP;
varying vec4 v_v4TexCoord;

void main()
{
	v_v4TexCoord = u_m4LightMVP * a_v4Position;
	gl_Position = u_m4LightMVP * a_v4Position;
}

