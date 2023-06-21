/*
 * Copyright (c) 2021 Amlogic, Inc. All rights reserved.
 *
 * This source code is subject to the terms and conditions defined in the
 * file 'LICENSE' which is part of this source code package.
 *
 * Description:
 */

#ifndef __STATIC_PIPE_H__
#define __STATIC_PIPE_H__

#include <cstdlib>


#include "mediactl.h"
#include "v4l2subdev.h"
#include "v4l2videodev.h"
#include "mediaApi.h"
#include "sensor_config.h"


namespace android {

class staticPipe {
  public:
    static int fetchPipeMaxResolution(media_stream_t *stream, uint32_t& width, uint32_t &height);
    static int fetchSensorFormat(media_stream_t *stream, int hdrEnable);
    static sensorType fetchSensorType(media_stream_t *stream);
};
}
#endif
