/*
 * Copyright (c) 2021 Amlogic, Inc. All rights reserved.
 *
 * This source code is subject to the terms and conditions defined in the
 * file 'LICENSE' which is part of this source code package.
 *
 * Description:
 */

#ifndef __MEDIAPI_H__
#define __MEDIAPI_H__

#include <stdio.h>
#include <string.h>


#include "mediactl.h"
#include "v4l2subdev.h"
#include "v4l2videodev.h"

#include "aml_isp_api.h"

#define V4L2_META_AML_ISP_CONFIG    v4l2_fourcc('A', 'C', 'F', 'G') /* Aml isp config */
#define V4L2_META_AML_ISP_STATS     v4l2_fourcc('A', 'S', 'T', 'S') /* Aml isp statistics */

typedef struct stream_configuration{
    struct aml_format format;
    struct aml_format vformat[4];
} stream_configuration_t;

typedef struct media_stream {
    char media_dev_name[64];
    char lens_ent_name[32];
    char sensor_ent_name[32];
    char csiphy_ent_name[32];
    char adap_ent_name[32];
    char isp_ent_name[32];
    char video_ent_name0[32];
    char video_ent_name1[32];
    char video_ent_name2[32];
    char video_ent_name3[32];
    char video_stats_name[32];
    char video_param_name[32];

    struct media_device  *media_dev;

    struct media_entity  *lens_ent;
    struct media_entity  *sensor_ent;
    struct media_entity  *csiphy_ent;
    struct media_entity  *adap_ent;
    struct media_entity  *isp_ent;
    struct media_entity  *video_ent0;
    struct media_entity  *video_ent1;
    struct media_entity  *video_ent2;
    struct media_entity  *video_ent3;
    struct media_entity  *video_stats;
    struct media_entity  *video_param;
} media_stream_t;

void mediaLog(const char *fmt, ...);

int mediaStreamInit(media_stream_t * stream, struct media_device * dev);

int createLinks(media_stream_t *stream);

int setSdFormat(media_stream_t *stream, stream_configuration_t *cfg);

int setImgFormat(media_stream_t *stream, stream_configuration_t *cfg);

int setDataFormat(media_stream_t *camera, stream_configuration_t *cfg);

int setConfigFormat(media_stream_t *camera, stream_configuration_t *cfg);

int media_set_wdrMode(media_stream_t *camera, uint32_t wdr_mode);

int mediaStreamConfig(media_stream_t * stream, stream_configuration_t *cfg);

#endif /* __MEDIAPI_H__ */

