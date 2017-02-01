//
//  CDAError.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/03/14.
//
//

#import "CDAError+Private.h"
#import "CDAResource+Private.h"

NSString* const CDAErrorDomain = @"CDAErrorDomain";

@interface CDAError ()

@property (nonatomic) NSDictionary* details;
@property (nonatomic) NSString* message;

@end

#pragma mark -

@implementation CDAError

+(NSError*)buildErrorWithCode:(NSInteger)code userInfo:(NSDictionary*)userInfo {
    return [NSError errorWithDomain:CDAErrorDomain
                               code:code
                           userInfo:userInfo];
}

+(NSString *)CDAType {
    return @"Error";
}

#pragma mark -

-(NSString *)description {
    return [[self errorRepresentationWithCode:0] description];
}

-(NSError *)errorRepresentationWithCode:(NSInteger)code {
    return [[self class] buildErrorWithCode:code
                                   userInfo:@{ @"details": self.details ?: @{},
                                               @"identifier": self.identifier,
                                               NSLocalizedDescriptionKey: self.message ?: @"" }];
}

-(id)initWithDictionary:(NSDictionary *)dictionary
                 client:(CDAClient*)client
  localizationAvailable:(BOOL)localizationAvailable {
    self = [super initWithDictionary:dictionary client:client localizationAvailable:localizationAvailable];
    if (self) {
        self.details = dictionary[@"details"];
        self.message = dictionary[@"message"];
    }
    return self;
}

// We only encode properties that have write permissions
#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.details    = [aDecoder decodeObjectForKey:@"details"];
        self.message    = [aDecoder decodeObjectForKey:@"message"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:self.details forKey:@"details"];
    [aCoder encodeObject:self.message forKey:@"message"];
}

@end
