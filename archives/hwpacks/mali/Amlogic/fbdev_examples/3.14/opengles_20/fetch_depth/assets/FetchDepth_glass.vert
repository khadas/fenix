/*
 * This proprietary software may be used only as
 * authorised by a licensing agreement from ARM Limited
 * (C) COPYRIGHT 2014 ARM Limited
 * ALL RIGHTS RESERVED
 * The entire notice above must be reproduced on all authorised
 * copies and copies may only be made to the extent permitted
 * by a licensing agreement from ARM Limited.
 */

attribute vec4 av4position;
attribute vec4 av4color;

uniform mat4 mvp;
uniform mediump float far;

varying vec4 vv4GlassColor;
varying float vfGlassLinearDepth;

void main()
{
    vv4GlassColor = av4color;
    gl_Position = mvp * av4position;
    vfGlassLinearDepth = gl_Position.w / far;
}
