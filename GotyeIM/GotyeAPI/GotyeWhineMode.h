/****************************************************************************
 Copyright(c) 2013-2014, Shanghai AiLiao Information Technology Co.,Ltd

 http://www.gotye.com.cn
 
 @author:	liugan
 @date:		2014-06-20
 @version:	v3.0
 @filename:	GotyeWhineMode.h
 @description:
 This header file includes supported whine mode using for recording.
 Include "GotyeAPI.h" instead of this.
****************************************************************************/

#ifndef __GOTYE_WHINEMODE_H__
#define __GOTYE_WHINEMODE_H__

#include "Gotye.h"

NS_GOTYEAPI_BEGIN

typedef enum
{
	GotyeWhineModeDefault,              ///< original
	GotyeWhineModeFatherChristmas,      ///< father christmas
	GotyeWhineModeOptimus,              ///< optimus prime
	GotyeWhineModeDolphine,             ///< dolphin
	GotyeWhineModeBaby,                 ///< baby
	GotyeWhineModeSubwoofer             ///< subwoofer
}GotyeWhineMode;	///< enum whine mode

NS_GOTYEAPI_END

#endif
