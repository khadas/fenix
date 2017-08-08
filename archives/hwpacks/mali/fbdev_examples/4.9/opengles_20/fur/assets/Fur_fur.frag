/*
 * This proprietary software may be used only as
 * authorised by a licensing agreement from ARM Limited
 * (C) COPYRIGHT 2009 - 2013 ARM Limited
 * ALL RIGHTS RESERVED
 * The entire notice above must be reproduced on all authorised
 * copies and copies may only be made to the extent permitted
 * by a licensing agreement from ARM Limited.
 */

precision lowp float;

varying vec3 v_v2TexCoord;
varying vec4 v_v4colour;

uniform sampler2D u_s2dTexture;

void main() {
  vec4 v4Texel = texture2D(u_s2dTexture, vec2(v_v2TexCoord) * 2.0) * v_v4colour;
	gl_FragColor = v4Texel;
}
