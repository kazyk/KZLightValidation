//
//  Created by TAKAHASHI kazuyuki on 2013/04/12.
//


#import "KZAFJSONRequestOperationTests.h"
#import "KZAFJSONRequestOperation.h"


@implementation KZAFJSONRequestOperationTests

- (NSURL *)URLWithName:(NSString *)name
{
    return [[NSBundle bundleForClass:[self class]] URLForResource:name withExtension:@"json"];
}

- (void)startAndWait:(NSOperation *)operation
{
    [operation start];
    while (![operation isFinished]) {
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    }
}

- (void)setUp
{
    [KZAFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];
}

- (void)testSuccess
{
    __block BOOL success = NO;
    NSURLRequest *req = [NSURLRequest requestWithURL:[self URLWithName:@"test1"]];
    id operation = [KZAFJSONRequestOperation operationWithRequest:req
                                                 JSONFormatObject:@{}
                                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                              success = YES;
                                                          }
                                                          failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                              STFail(@"");
                                                          }];
    [self startAndWait:operation];
    STAssertTrue(success, @"");
}

- (void)testFailure
{
    __block BOOL failure = NO;
    __block NSError *err = nil;
    NSString *dummyPath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"notfound.json"];
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:dummyPath]];
    id operation = [KZAFJSONRequestOperation operationWithRequest:req
                                                 JSONFormatObject:@{}
                                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                              STFail(@"");
                                                          }
                                                          failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                              failure = YES;
                                                              err = error;
                                                          }];
    [self startAndWait:operation];
    STAssertTrue(failure, @"");
    STAssertEqualObjects(err.domain, NSURLErrorDomain, @"");
}

- (void)testInvalidFormat
{
    __block BOOL failure = NO;
    __block NSError *err = nil;
    NSURL *URL = [self URLWithName:@"test1"];
    NSURLRequest *req = [NSURLRequest requestWithURL:URL];
    id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:URL]
                                              options:(NSJSONReadingOptions)0
                                                error:NULL];
    id operation = [KZAFJSONRequestOperation operationWithRequest:req
                                                 JSONFormatObject:@{@"a": @1}
                                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                              STFail(@"");
                                                          }
                                                          failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                              failure = YES;
                                                              err = error;
                                                              STAssertEqualObjects(json, JSON, @"");
                                                          }];
    [self startAndWait:operation];
    STAssertTrue(failure, @"");
    STAssertNotNil(err, @"");
    STAssertEqualObjects(err.domain, kKZJSONValidationErrorDomain, @"");
}

@end