/*
 * This confidential and proprietary software may be used only as
 * authorised by a licensing agreement from ARM Limited
 * (C) COPYRIGHT 2012 ARM Limited
 * ALL RIGHTS RESERVED
 * The entire notice above must be reproduced on all authorised
 * copies and copies may only be made to the extent permitted
 * by a licensing agreement from ARM Limited.
 */

#version 100

attribute vec4 a_v4Position;
attribute vec2 a_v2TexCoord;

uniform mat4 u_m4Texture;

varying vec2 v_v2TexCoord;

void main()
{
    v_v2TexCoord = vec2(u_m4Texture * vec4(a_v2TexCoord, 0.0, 1.0));;
    gl_Position = a_v4Position;
}
