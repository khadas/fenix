/*
 * Copyright (c) 2021 Amlogic, Inc. All rights reserved.
 *
 * This source code is subject to the terms and conditions defined in the
 * file 'LICENSE' which is part of this source code package.
 *
 * Description:
 */

#ifndef _AISP_COMMAND_API_H_
#define _AISP_COMMAND_API_H_
#include <stdio.h>
#include <stdlib.h>

#define BUFFER_DATA_TYPE 0x1c

#define TGENERAL                                          0x00000000
#define TSELFTEST                                         0x00000001
#define TSENSOR                                           0x00000002
#define TLENS                                             0x00000003
#define TSYSTEM                                           0x00000004
#define TISP_MODULES                                      0x00000005
#define TSTATUS                                           0x00000006
#define TIMAGE                                            0x00000007
#define TALGORITHMS                                       0x00000008
#define TSCENE_MODES                                      0x00000009
#define TREGISTERS                                        0x0000000A
#define TAML_SCALER                                       0x0000000B

// ------------------------------------------------------------------------------ //
//        ERROR REASONS
// ------------------------------------------------------------------------------ //
#define ERR_UNKNOWN                                       0x00000000
#define ERR_BAD_ARGUMENT                                  0x00000001
#define ERR_WRONG_SIZE                                    0x00000002

// ------------------------------------------------------------------------------ //
//        RETURN VALUES
// ------------------------------------------------------------------------------ //
#define SUCCESS                                           0x00000000
#define NOT_IMPLEMENTED                                   0x00000001
#define NOT_SUPPORTED                                     0x00000002
#define NOT_PERMITTED                                     0x00000003
#define NOT_EXISTS                                        0x00000004
#define FAIL                                              0x00000005
#define IMPLEMENTED                                       0x00000006

// ------------------------------------------------------------------------------ //
//        DIRECTION VALUES
// ------------------------------------------------------------------------------ //
#define COMMAND_SET                                       0x00000000
#define COMMAND_GET                                       0x00000001
#define API_VERSION                                       0x00000064
#define uint8_t unsigned char
#define uint32_t unsigned int

#define LOG( ... ) printf( __VA_ARGS__ )

typedef struct _aisp_api_type_t {
    uint8_t u8Direction;
    uint8_t u8CmdType;
    uint8_t u8CmdId;
    uint32_t u32Value;
    uint32_t *pData;
    uint32_t *pRetValue;
} aisp_api_type_t;

// ------------------------------------------------------------------------------ //
//        SET/GET FUNCTION
// ------------------------------------------------------------------------------ //

//The main api function to control and change the firmware state
uint8_t aisp_command( uint32_t ctx_id, uint8_t command_type, uint8_t command, uint32_t value, uint8_t direction, uint32_t *ret_value);

//The function to change firmware internal calibrations.
uint8_t aisp_calibration( uint32_t ctx_id, uint8_t type, uint8_t id, uint8_t direction, void* data, uint32_t data_size, uint32_t* ret_value);
uint8_t aisp_api_array( uint32_t ctx_id, uint8_t type, uint8_t id, uint8_t direction, void *data, uint32_t data_size, uint32_t *ret_value );

#endif//_AISP_COMMAND_API_H_
