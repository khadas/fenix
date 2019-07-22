/*
 * This confidential and proprietary software may be used only as
 * authorised by a licensing agreement from ARM Limited
 * (C) COPYRIGHT 2008-2013, 2016 ARM Limited
 * ALL RIGHTS RESERVED
 * The entire notice above must be reproduced on all authorised
 * copies and copies may only be made to the extent permitted
 * by a licensing agreement from ARM Limited.
 */

/**
 * @file fbdev_window.h
 * @brief A window type for the framebuffer device (used by egl and tests)
 */

#ifndef _FBDEV_WINDOW_H_
#define _FBDEV_WINDOW_H_

#ifdef __cplusplus
extern "C" {
#endif

typedef enum
{
	FBDEV_PIXMAP_DEFAULT = 0,
	FBDEV_PIXMAP_SUPPORTS_UMP = (1 << 0),
	FBDEV_PIXMAP_ALPHA_FORMAT_PRE = (1 << 1),
	FBDEV_PIXMAP_COLORSPACE_sRGB = (1 << 2),
	FBDEV_PIXMAP_EGL_MEMORY = (1 << 3),     /* EGL allocates/frees this memory */
	FBDEV_PIXMAP_DMA_BUF = (1 << 4),
} fbdev_pixmap_flags;

typedef struct fbdev_window
{
	unsigned short width;
	unsigned short height;
} fbdev_window;

typedef struct fbdev_pixmap
{
	unsigned int height;
	unsigned int width;
	unsigned int bytes_per_pixel;
	unsigned char buffer_size;
	unsigned char red_size;
	unsigned char green_size;
	unsigned char blue_size;
	unsigned char alpha_size;
	unsigned char luminance_size;
	fbdev_pixmap_flags flags;
	unsigned short *data;
	unsigned int format; /* extra format information in case rgbal is not enough, especially for YUV formats */
} fbdev_pixmap;

#if MALI_USE_DMA_BUF
struct fbdev_dma_buf
{
	int fd;
	int size;
	void *ptr;
};
#endif

#ifdef __cplusplus
}
#endif


#endif
