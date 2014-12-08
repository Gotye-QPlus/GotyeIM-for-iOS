/****************************************************************************
 Copyright(c) 2013-2014, Shanghai AiLiao Information Technology Co.,Ltd

 http://www.gotye.com.cn
 
 @author:	liugan
 @date:		2014-06-20
 @version:	v3.0
 @filename:	Gotye.h
 @description:
 This header file includes some common macro definitions providing convenience
 for integration with GotyeAPI.
 Include "GotyeAPI.h" instead of this.
****************************************************************************/

#ifndef __GOTYE_H__
#define __GOTYE_H__

#include <iostream>

#include <ciso646>
#ifdef _LIBCPP_VERSION
#if _LIBCPP_VERSION>=1002 ///< libc++ version must be c++11
#define GotyeFunction           std::function
#else
#error "libc++ version not support this api"
#endif
#else
#if defined(WIN32)||defined(_WINPHONE)
#include <functional>
#else
#include <tr1/functional>
#endif

#ifndef nullptr
#define nullptr                 NULL
#endif
#define GotyeFunction           std::tr1::function
#endif

typedef GotyeFunction<void()>   GotyeFunc0;

#define NS_GOTYEAPI_BEGIN       namespace gotyeapi {		///< gotyeapi namespace begin
#define NS_GOTYEAPI_END         }							///< gotyeapi namespace end
#define USING_NS_GOTYEAPI       using namespace gotyeapi	///< using namespace gotyeapi

#define IIOS        ///< interface for iOS
#define IANDROID    ///< interface for Android

#define Optional                {}	///< mark interface as optional

#define	SYNCSUCCESS(stat)		(GotyeStatusCodeOK==(stat))					///< sync calling success
#define	ASYNSUCCESS(stat)		(GotyeStatusCodeWaitingCallback==(stat))	///< async calling success

#define apiist                  gotyeapi::GotyeAPI::getInstance() ///< get the instance of GotyeAPI

#define REC_MAXDURATION			60000   ///< maximum recording duration(millisecond)
#define REC_DEFAULTDURATION     10000   ///< default recording duration(millisecond)

#define DEFAULT_COUNT           (10)    ///< default count of history message list

#define SEX_IGNORE              (GotyeUserGender)(-1)

#endif/* defined(__GOTYE_H__) */
