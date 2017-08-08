/*
 * This confidential and proprietary software may be used only as
 * authorised by a licensing agreement from ARM Limited
 * (C) COPYRIGHT 2013 ARM Limited
 * ALL RIGHTS RESERVED
 * The entire notice above must be reproduced on all authorised
 * copies and copies may only be made to the extent permitted
 * by a licensing agreement from ARM Limited.
 */

/* [Vertex Shader] */
attribute vec3 a_v3Position;
attribute vec3 a_v3Velocity;
attribute vec3 a_v3ParticleTimes;
uniform mat4 mvp;
uniform vec3 u_v3gravity;
uniform vec3 u_v3colour;

varying float v_ageFactor;
varying vec3 v_v3colour;

void main()
{
    vec3 newPos;
    float ageFactor;
    float delay    = a_v3ParticleTimes.x;
    float lifetime = a_v3ParticleTimes.y;
    float age      = a_v3ParticleTimes.z;

    if( age  > delay )
    {
        float t = age - delay;
        /* Particle motion equation. */
        newPos = a_v3Position + a_v3Velocity * t + 0.5 * u_v3gravity * t * t;

        ageFactor = 1.0 - (age / lifetime);
        ageFactor = clamp(ageFactor, 0.0, 1.0);

        /* The older the particle the smaller its size. */
        gl_PointSize = ageFactor * 250.0;
    }
    else
    {
        newPos = a_v3Position;
        /* If null size particle will not be drawn. */
        gl_PointSize = 0.0;
        ageFactor = 0.0;
    }

    /* Initializing varying. */
    v_ageFactor = ageFactor;
    v_v3colour = u_v3colour;

    /* Particle position. */
    gl_Position.xyz = newPos;
    gl_Position.w = 1.0;

    /* Apply matrix transformation. */
    gl_Position = mvp * gl_Position;
}
/* [Vertex Shader] */
