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
precision mediump float;

uniform sampler2D u_s2dTexture;

varying vec2 v_v2TexCoord;

void main()
{
    vec4 v4Texel = texture2D(u_s2dTexture, v_v2TexCoord);
    gl_FragColor = v4Texel;
}
