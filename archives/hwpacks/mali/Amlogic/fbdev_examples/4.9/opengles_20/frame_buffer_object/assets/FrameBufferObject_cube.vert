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
attribute vec4 a_v4FillColor;
attribute vec2 a_v2TexCoord;

uniform mat4 u_m4Projection;
uniform mat4 u_m4Modelview;

varying vec4 v_v4FillColor;
varying vec2 v_v2TexCoord;

void main()
{
v_v4FillColor = a_v4FillColor;
    v_v2TexCoord = a_v2TexCoord;
gl_Position = u_m4Projection * u_m4Modelview * a_v4Position;
}