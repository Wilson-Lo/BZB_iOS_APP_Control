//
//  OCFile.h
//  BZB_Project
//
//  Created by GoMax on 2021/4/9.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCFile : NSObject
- (char *)parseEDID:(unsigned char *) buf withLen: (int)len;
@end

NS_ASSUME_NONNULL_END

