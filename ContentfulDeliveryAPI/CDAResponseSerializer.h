//
//  CDAResponseSerializer.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <AFNetworking/AFURLResponseSerialization.h>

@class CDAClient;

@interface CDAResponseSerializer : AFJSONResponseSerializer

@property (nonatomic, weak, readonly) CDAClient* client;

-(instancetype)initWithClient:(CDAClient*)client;

@end
