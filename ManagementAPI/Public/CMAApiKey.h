//
//  CMAApiKey.h
//  Pods
//
//  Created by Boris Bügling on 16/01/15.
//
//

#import "CDAResource.h"
#import "CDANullabilityStubs.h"

NS_ASSUME_NONNULL_BEGIN

/** API key of a Space. */
@interface CMAApiKey : CDAResource

/** Name of the API key */
@property (nonatomic, copy, readonly) NSString* name;

/** The access token beloging to the API key */
@property (nonatomic, copy, readonly) NSString* token;

/** Description of the API key */
@property (nonatomic, copy, readonly) NSString* tokenDescription;

@end

NS_ASSUME_NONNULL_END
