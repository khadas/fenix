/*
 * This proprietary software may be used only as
 * authorised by a licensing agreement from ARM Limited
 * (C) COPYRIGHT 2014 ARM Limited
 * ALL RIGHTS RESERVED
 * The entire notice above must be reproduced on all authorised
 * copies and copies may only be made to the extent permitted
 * by a licensing agreement from ARM Limited.
 */

#extension GL_ARM_shader_framebuffer_fetch_depth_stencil : require

precision mediump float;

uniform float near;
uniform float far;
uniform float glassMaterial;

varying lowp vec4 vv4GlassColor;
varying float vfGlassLinearDepth;

// converts exponential depth to a linear [0..1] range, assuming [eye..far]
highp float z_eye_far_to_linear(highp float z, float n, float f)
{
    return 2.0 * n / (f + n - z * (f - n));
}

void main()
{
    highp float fCubeZ = gl_LastFragDepthARM * 2.0 - 1.0;
    float fCubeLinearDepth = z_eye_far_to_linear(fCubeZ, near, far);

    float fator = clamp(vv4GlassColor.a + (fCubeLinearDepth - vfGlassLinearDepth) * glassMaterial, 0.0, 1.0);
    gl_FragColor = vec4(vv4GlassColor.rgb, fator);
}

