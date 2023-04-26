/*
 * Copyright (c) 2018 Amlogic, Inc. All rights reserved.
 *
 * This source code is subject to the terms and conditions defined in the
 * file 'LICENSE' which is part of this source code package.
 *
 * Description:
 */

#ifndef __LOGS_H__
#define __LOGS_H__
/*
 * Apical(ARM) V4L2 test application 2016
 *
 * This is ARM internal development purpose SW tool running on JUNO.
 */

#if 1
#define ERR printf
#else
#define ERR //
#endif

#if 1
#define MSG printf
#else
#define MSG //
#endif

#if 1
#define INFO printf
#else
#define INFO //
#endif

#if 1
#define DBG printf
#else
#define DBG //
#endif

#endif // __METADATA_API_H__
