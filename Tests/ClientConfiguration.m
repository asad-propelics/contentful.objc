//
//  ClientConfiguration.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 01/10/14.
//
//

#import "ContentfulBaseTestCase.h"

@interface ClientConfiguration : ContentfulBaseTestCase

@end

#pragma mark -

@implementation ClientConfiguration

-(void)testClientCanBeInstantiatedWithoutSpaceKey {
    CDAClient* client1 = [[CDAClient alloc] initWithSpaceKey:nil accessToken:@"yolo"];
    CDAClient* client2 = [[CDAClient alloc] initWithSpaceKey:nil
                                                 accessToken:@"yolo"
                                               configuration:[CDAConfiguration defaultConfiguration]];

    XCTAssertNotNil(client1);
    XCTAssertNotNil(client2);
}

-(void)testDefaultUserAgent {
    StartBlock();

    CDARequest* request = [self.client fetchEntriesWithSuccess:^(CDAResponse *response,
                                                                 CDAArray *array) {
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        EndBlock();
    }];

    WaitUntilBlockCompletes();

    NSString* userAgentString = request.request.allHTTPHeaderFields[@"X-Contentful-User-Agent"];

    NSString *versionNumberRegexString = @"\\d+\\.\\d+\\.\\d+(-(beta|RC|alpha)\\d*)?";

    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:[NSString stringWithFormat:@"sdk contentful.objc/%@; os iOS/\\d+\\.\\d+\\.\\d+;", versionNumberRegexString] options:0 error:nil];
    NSArray<NSTextCheckingResult*> *matches = [regex matchesInString:userAgentString options:0 range:NSMakeRange(0, userAgentString.length)];


    XCTAssertTrue(matches.count == 1, @"The user agent header should have had at least one match.");
}

-(void)testFilterMissingEntities {
    CDAConfiguration* configuration = [CDAConfiguration defaultConfiguration];
    configuration.filterNonExistingResources = YES;

    self.client = [[CDAClient alloc] initWithSpaceKey:@"vfvjfjyjrbbp"
                                          accessToken:@"422588c021896d2ae01eaf2d68faa720aaf6da4b361e7c99e9afac6feacb498b"
                                        configuration:configuration];

    StartBlock();

    [self.client fetchEntriesWithSuccess:^(CDAResponse* response, CDAArray* array) {
        XCTAssertEqual(array.items.count, 1);

        CDAEntry* me = array.items.firstObject;
        XCTAssertNil(me.fields[@"link"]);

        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);

        EndBlock();
    }];

    WaitUntilBlockCompletes();
}

-(void)testNotFilterMissingEntitiesIfNotConfigured {
    self.client = [[CDAClient alloc] initWithSpaceKey:@"vfvjfjyjrbbp"
                                          accessToken:@"422588c021896d2ae01eaf2d68faa720aaf6da4b361e7c99e9afac6feacb498b"];

    StartBlock();

    [self.client fetchEntriesWithSuccess:^(CDAResponse* response, CDAArray* array) {
        XCTAssertEqual(array.items.count, 1);

        CDAEntry* me = array.items.firstObject;
        XCTAssertNotNil(me.fields[@"link"]);

        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);

        EndBlock();
    }];

    WaitUntilBlockCompletes();
}

@end
