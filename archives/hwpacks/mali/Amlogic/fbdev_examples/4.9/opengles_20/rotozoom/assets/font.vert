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
uniform mat4 u_m4Projection;
attribute vec4 a_v4Position;
attribute vec4 a_v4FontColor;
attribute vec2 a_v2TexCoord;
varying vec4 v_v4FontColor;
varying vec2 v_v2TexCoord;
void main()
{
    v_v4FontColor = a_v4FontColor;
    v_v2TexCoord = a_v2TexCoord;
    gl_Position = u_m4Projection * a_v4Position;
}