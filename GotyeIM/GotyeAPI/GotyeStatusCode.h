/****************************************************************************
 Copyright(c) 2013-2014, Shanghai AiLiao Information Technology Co.,Ltd

 http://www.gotye.com.cn
 
 @author:	liugan
 @date:		2014-06-20
 @version:	v3.0
 @filename:	GotyeStatusCode.h
 @description:
 This header file inlcudes gotye status codes.
 Include "GotyeAPI.h" instead of this.
****************************************************************************/

#ifndef __GOTYE_STATUSCODE_H__
#define __GOTYE_STATUSCODE_H__

#include "Gotye.h"

NS_GOTYEAPI_BEGIN

typedef enum
{
    GotyeStatusCodeWaitingCallback          = -1,   ///< async calling sucessfully
	GotyeStatusCodeOK                       = 0,    ///< sync calling sucessfully
    GotyeStatusCodeSystemBusy               = 1,    ///< system busy
    GotyeStatusCodeNotLoginYet              = 2,    ///< not logged in yet
    GotyeStatusCodeCreateFileFailed         = 3,    ///< create file failed
    GotyeStatusCodeTargetIsSelf             = 4,    ///< target is self
    GotyeStatusCodeTimeout                  = 300,  ///< time out
	GotyeStatusCodeVerifyFailed             = 400,  ///< verification failed
    GotyeStatusCodeNoPermission             = 401,  ///< no permission
    GotyeStatusCodeRepeatOper               = 402,  ///< repeat operation
    GotyeStatusCodeGroupNotFound            = 403,  ///< group not found
    GotyeStatusCodeUserNotFound             = 404,  ///< user not found
    GotyeStatusCodeLoginFailed              = 500,  ///< login failed
	GotyeStatusCodeForceLogout              = 600,  ///< your account has logged in another device.
	GotyeStatusCodeNetworkDisConnected      = 700,  ///< network disconnected
    GotyeStatusCodeRoomNotExist             = 33,   ///< room not exist
    GotyeStatusCodeRoomIsFull               = 34,   ///< room is full
    GotyeStatusCodeNotInRoom                = 35,   ///< not in the room
    GotyeStatusCodeForbidden                = 36,   ///< forbidden
    GotyeStatusCodeAlreadyInRoom            = 39,   ///< forbidden
    GotyeStatusCodeUserNotExist             = 804,  ///< friend not exist
    GotyeStatusCodeRequestMicFailed         = 806,  ///< requesting mic failed
    GotyeStatusCodeVoiceTimeOver            = 807,  ///< recording time over
    GotyeStatusCodeRecorderBusy             = 808,  ///< recording device is in use
    GotyeStatusCodeVoiceTooShort            = 809,  ///< recording time too short < 1000ms
    GotyeStatusCodeInvalidArgument          = 1000, ///< parameters invalid
    GotyeStatusCodeServerProcessError       = 1001, ///< server error
    GotyeStatusCodeDBError                  = 1002, ///< create db failed.
    GotyeStatusCodeUnkonwnError             = 1100  ///< unknown error
}GotyeStatusCode, status;	///< enum status code

NS_GOTYEAPI_END

#endif
