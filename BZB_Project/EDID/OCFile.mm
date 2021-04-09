//
//  OCFile.m
//  GoMaxMatrix
//
//  Created by 啟發電子 on 2020/7/2.
//  Copyright © 2020 gomax. All rights reserved.
//

#import "OCFile.h"
#import "Edid.hpp"

@implementation OCFile

- (char *)parseEDID: (unsigned char *) buf withLen: (int)len{
    return testCC().edidParser(buf,len);
}

@end
