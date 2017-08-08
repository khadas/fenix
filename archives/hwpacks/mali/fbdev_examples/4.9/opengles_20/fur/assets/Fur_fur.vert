/*
 * This proprietary software may be used only as
 * authorised by a licensing agreement from ARM Limited
 * (C) COPYRIGHT 2009 - 2013 ARM Limited
 * ALL RIGHTS RESERVED
 * The entire notice above must be reproduced on all authorised
 * copies and copies may only be made to the extent permitted
 * by a licensing agreement from ARM Limited.
 */

attribute vec4 a_v4position;
attribute vec3 a_v2TexCoord;

uniform mat4 u_m4MVP;
uniform mat4 u_m4Texture;
uniform vec4 u_v4Color;

varying vec3 v_v2TexCoord;
varying vec4 v_v4colour;

void main() {
  v_v4colour = u_v4Color;
  v_v2TexCoord = a_v2TexCoord;
	gl_Position = u_m4MVP * a_v4position;
}

