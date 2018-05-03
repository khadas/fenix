/*
 * This confidential and proprietary software may be used only as
 * authorised by a licensing agreement from ARM Limited
 * (C) COPYRIGHT 2014-2016 ARM Limited
 * ALL RIGHTS RESERVED
 * The entire notice above must be reproduced on all authorised
 * copies and copies may only be made to the extent permitted
 * by a licensing agreement from ARM Limited.
 */

/**
 * @file wayland_window.h
 * @brief A window type for the wayland platform (used by egl and tests)
 */

#ifndef _WAYLAND_WINDOW_H_
#define _WAYLAND_WINDOW_H_

#ifdef __cplusplus
extern "C" {
#endif

struct wl_surface;

typedef struct wl_egl_window
{
	struct wl_surface *surface;
	void *egl_surface_list;
	int dx;
	int dy;
	int width;
	int height;
	int refcnt;
} wl_egl_window;

#ifdef __cplusplus
}
#endif


#endif
