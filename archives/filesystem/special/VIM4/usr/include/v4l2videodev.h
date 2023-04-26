/*
 * Copyright (c) 2022 Amlogic, Inc. All rights reserved.
 *
 * This source code is subject to the terms and conditions defined in the
 * file 'LICENSE' which is part of this source code package.
 *
 * Description:
 */

#ifndef  V4L2_VIDEO_DEV_H
#define  V4L2_VIDEO_DEV_H


int v4l2_video_open(struct media_entity *entity);

void v4l2_video_close(struct media_entity *entity);

int v4l2_video_get_format(struct media_entity *entity,
                      struct v4l2_format *v4l2_fmt);

int v4l2_video_set_format(struct media_entity *entity,
              struct v4l2_format * v4l2_fmt);

int v4l2_video_get_capability(struct media_entity *entity,
                        struct v4l2_capability * v4l2_cap);


int v4l2_video_req_bufs(struct media_entity *entity,
                        struct v4l2_requestbuffers * v4l2_rb);

int v4l2_video_query_buf(struct media_entity *entity,
                       struct v4l2_buffer *v4l2_buf);

int v4l2_video_q_buf(struct media_entity *entity,
                       struct v4l2_buffer *v4l2_buf);



int v4l2_video_dq_buf(struct media_entity *entity,
                       struct v4l2_buffer *v4l2_buf);

int v4l2_video_stream_on(struct media_entity *entity, int type);

int v4l2_video_stream_off(struct media_entity *entity, int type);


#endif

