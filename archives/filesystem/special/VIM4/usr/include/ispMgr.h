#ifndef __ISP_MGR_H__
#define __ISP_MGR_H__

#include <cstdlib>
#include <thread>

#include "mediactl.h"
#include "v4l2subdev.h"
#include "v4l2videodev.h"
#include "mediaApi.h"
#include "aml_isp_tuning.h"
#include "aml_isp_adapt.h"
#include "aisp_command_api.h"

#include "aml_isp_api.h"

#include "sensor_config.h"

const size_t  kMaxRetryCount   = 100;
const int64_t kSyncWaitTimeout = 300000000LL; // 300ms

const size_t kIspStatsNbBuffers = 3;
const size_t kIspStatsWidth = 1024;
const size_t kIspStatsHeight = 256;

const size_t kIspParamsNbBuffers = 1;
const size_t kIspParamsWidth = 1024;
const size_t kIspParamsHeight = 256;

typedef void (*isp_alg2user)(uint32_t ctx_id, void *param);
typedef void (*isp_alg2kernel)(uint32_t ctx_id, void *param);
typedef void (*isp_enable)(uint32_t ctx, void *pstAlgCtx, void *calib);
typedef void (*isp_disable)(uint32_t ctx_id);
typedef void (*isp_fw_interface)(uint32_t ctx_id, void *param);


struct ispIF {
    isp_alg2user   alg2User   = nullptr;
    isp_alg2kernel alg2Kernel = nullptr;
    isp_enable     algEnable  = nullptr;
    isp_disable    algDisable = nullptr;
    isp_fw_interface algFwInterface = nullptr;
};

struct bufferInfo {
    void* addr = nullptr;
    int   size = 0;
    int   dma_fd = -1;
};

struct v4l2BufferInfo {
    v4l2BufferInfo() {
        memset(&rb, 0, sizeof(struct v4l2_requestbuffers));
        memset(&format, 0, sizeof(struct v4l2_format));
    }
    struct v4l2_requestbuffers rb;
    struct v4l2_format         format;
    struct bufferInfo          mem[8];
};

#endif
