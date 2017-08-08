/*
 * This proprietary software may be used only as
 * authorised by a licensing agreement from ARM Limited
 * (C) COPYRIGHT 2009 - 2013 ARM Limited
 * ALL RIGHTS RESERVED
 * The entire notice above must be reproduced on all authorised
 * copies and copies may only be made to the extent permitted
 * by a licensing agreement from ARM Limited.
 */

attribute vec4 av4position;
attribute vec3 av3colour;
attribute vec3 a_v2TexCoord;

uniform mat4 mvp;
uniform mat4 u_m4Texture;
varying vec3 v_v2TexCoord;

varying vec3 vv3colour;

void main() {
  v_v2TexCoord = vec3(u_m4Texture * vec4(a_v2TexCoord, 1.0));
	vv3colour = av3colour;
	gl_Position = mvp * av4position;
}

