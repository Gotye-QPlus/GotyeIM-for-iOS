/****************************************************************************
 Copyright(c) 2013-2014, Shanghai AiLiao Information Technology Co.,Ltd

 http://www.gotye.com.cn
 
 @author:   liugan
 @date:		2014-06-20
 @version:	v3.0
 @filename:	GotyeMedia.h
 @description:
 This header file declares gotye media struct for audio/image.
 Include "GotyeAPI.h" instead of this.
****************************************************************************/

#ifndef __GOTYE_MEDIA_H__
#define __GOTYE_MEDIA_H__

#include "Gotye.h"

NS_GOTYEAPI_BEGIN

typedef enum
{
    GotyeMediaTypeImage = 1, ///<image
    GotyeMediaTypeAudio, ///<audio
    GotyeMediaTypeUserData,  ///< user data
    GotyeMediaTypeExtraData ///< extra data
}GotyeMediaType;    ///<enum media type.

typedef enum
{
    GotyeMediaStatusCreated,
    GotyeMediaStatusDownloading,
    GotyeMediaStatusDownloaded,
    GotyeMediaStatusDownloadFailed
}GotyeMediaStatus;

/**
 * @summary: GotyeMedia encapsulates audio/media/user data content using in GotyeAPI
 */
struct  GotyeMedia
{
    long long tag;   ///< reserved
    GotyeMediaType type;    ///< media type
    GotyeMediaStatus status;    ///< status of audio/image
    
    std::string url; ///< the relative url for downloading/uploading media
    std::string path;    ///< saving audio/image thumbnail/userdata
    std::string pathEx; ///< saving original image or audio PCM file while decoding.
    
    unsigned duration;  ///< audio duration(in millisecond), valid only when the media type is GotyeMediaTypeAudio

    GotyeMedia():type(GotyeMediaTypeImage), url(""), path(""), duration(0), tag(0), status(GotyeMediaStatusCreated){ } ///< default ctor
    GotyeMedia(GotyeMediaType t):type(t), url(""), path(""), duration(0), tag(0), status(GotyeMediaStatusCreated){ } ///< ctor
};



NS_GOTYEAPI_END

#endif
