//
//  OCFile.h
//  GoMaxMatrix
//
//  Created by 啟發電子 on 2020/7/2.
//  Copyright © 2020 gomax. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCFile : NSObject
- (char *)parseEDID:(unsigned char *) buf withLen: (int)len;
@end

NS_ASSUME_NONNULL_END
