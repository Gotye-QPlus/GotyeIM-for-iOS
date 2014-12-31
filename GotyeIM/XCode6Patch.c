//
//  XCode6Patch.c
//  GotyeIM
//
//  Created by Peter on 14/12/9.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

// for Xcode 6 bug patch
#include "stdio.h"
#include "string.h"

size_t fwrite$UNIX2003( const void *a, size_t b, size_t c, FILE *d )
{
    return fwrite(a, b, c, d);
}

char* strerror$UNIX2003( int errnum )
{
    return strerror(errnum);
}
