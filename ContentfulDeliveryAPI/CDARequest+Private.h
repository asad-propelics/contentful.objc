//
//  CDARequest+Private.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 10/03/14.
//
//

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

#import "CDARequest.h"

@interface CDARequest ()

-(instancetype)initWithSessionTask:(NSURLSessionTask *)task;

@end
