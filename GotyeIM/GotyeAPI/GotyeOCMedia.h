//
//  GotyeOCMedia.h
//  GotyeAPI
//
//  Created by Peter on 14/12/3.
//  Copyright (c) 2014年 Ailiao Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@interface GotyeOCMedia : NSObject

@property(nonatomic, assign) long long tag;   ///< reserved
@property(nonatomic, assign) GotyeMediaType type;    ///< media type
@property(nonatomic, assign) GotyeMediaStatus status;    ///< status of audio/image

@property(nonatomic, copy) NSString* url; ///< the relative url for downloading/uploading media
@property(nonatomic, copy) NSString* path;    ///< saving audio/image thumbnail/userdata
@property(nonatomic, copy) NSString* pathEx; ///< saving original image or audio PCM file while decoding.

@property(nonatomic, assign) unsigned duration;  ///< audio duration(in millisecond), valid only when the media type is GotyeOCMedia*TypeAudio

@end
