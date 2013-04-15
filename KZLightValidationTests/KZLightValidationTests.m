//
//  KZLightValidationTests.m
//  KZLightValidationTests
//
//  Created by kazuyuki takahashi on 04/12/13.
//  Copyright (c) 2013 kazuyuki takahashi. All rights reserved.
//

#import "KZLightValidationTests.h"
#import "KZLightValidation.h"

@implementation KZLightValidationTests

- (void)testNilFormat
{
    KZLightValidation *validator = [KZLightValidation buildValidator:nil];
    STAssertTrue([validator validateObject:nil], @"");
    STAssertTrue([validator validateObject:@""], @"");
    STAssertTrue([validator validateObject:@[]], @"");
    STAssertTrue([validator validateObject:@{}], @"");
    STAssertTrue([validator validateObject:@123], @"");
}

- (void)testSimpleString
{
    KZLightValidation *validator = [KZLightValidation buildValidator:@""];
    STAssertTrue([validator validateObject:@"hoge"], @"");
    STAssertTrue([validator validateObject:@""], @"");
    STAssertFalse([validator validateObject:nil], @"");
    STAssertFalse([validator validateObject:@1], @"");
    STAssertFalse([validator validateObject:@[]], @"");
    STAssertFalse([validator validateObject:@{}], @"");
}

- (void)testSimpleNumber
{
    KZLightValidation *validator = [KZLightValidation buildValidator:@1];
    STAssertTrue([validator validateObject:@1], @"");
    STAssertTrue([validator validateObject:@0], @"");
    STAssertFalse([validator validateObject:@"hoge"], @"");
    STAssertFalse([validator validateObject:@""], @"");
    STAssertFalse([validator validateObject:nil], @"");
    STAssertFalse([validator validateObject:@[]], @"");
    STAssertFalse([validator validateObject:@{}], @"");
}

- (void)testSimpleArray
{
    KZLightValidation *validator = [KZLightValidation buildValidator:@[]];
    STAssertTrue([validator validateObject:@[]], @"");
    BOOL b = [validator validateObject:@[@1, @"123", @{}, @[]]];
    STAssertTrue(b, @"");
    STAssertFalse([validator validateObject:@"hoge"], @"");
    STAssertFalse([validator validateObject:@""], @"");
    STAssertFalse([validator validateObject:nil], @"");
    STAssertFalse([validator validateObject:@{}], @"");
}

- (void)testSimpleDictionary
{
    KZLightValidation *validator = [KZLightValidation buildValidator:@{}];
    STAssertTrue([validator validateObject:@{}], @"");
    id obj = @{
            @"a": @"123",
            @"b": @[],
            @"c": @123,
    };
    STAssertTrue([validator validateObject:obj], @"");
    STAssertFalse([validator validateObject:@"hoge"], @"");
    STAssertFalse([validator validateObject:@""], @"");
    STAssertFalse([validator validateObject:nil], @"");
    STAssertFalse([validator validateObject:@[]], @"");
}

- (void)testArrayOfString
{
    KZLightValidation *validator = [KZLightValidation buildValidator:@[@""]];
    STAssertTrue([validator validateObject:@[]], @"");
    STAssertTrue([validator validateObject:@[@"abc"]], @"");
    id obj1 = @[@"a", @"b", @"c"];
    STAssertTrue([validator validateObject:obj1], @"");
    id obj2 = @[@"a", @"b", @"c", @1];
    STAssertFalse([validator validateObject:obj2], @"");
}

- (void)testCompositeDictionary
{
    KZLightValidation *validator = [KZLightValidation buildValidator:@{
            @"a": @"string",
            @"b": @123,
            @"c": @[],
    }];

    id obj1 = @{
            @"a": @"aaa",
            @"b": @12345,
            @"c": @[@"a", @"b", @"c", @1, @[]],
            @"d": @"hogehoge",
    };
    STAssertTrue([validator validateObject:obj1], @"");

    id obj2 = @{
            @"a": @"aaa",
            @"b": @12345,
    };
    STAssertFalse([validator validateObject:obj2], @"");

    id obj3 = @{
            @"a": @"aaa",
            @"b": @100,
            @"c": @{@"wrong type": @"aaa"},
    };
    STAssertFalse([validator validateObject:obj3], @"");
}

- (void)testNestedDictionary
{
    KZLightValidation *validator = [KZLightValidation buildValidator:@{
            @"a": @{
                    @"b": @"string",
                    @"c": @123,
            },
    }];

    id obj1 = @{
            @"a": @{
                    @"b": @"aaa",
                    @"c": @123,
            },
    };
    STAssertTrue([validator validateObject:obj1], @"");

    id obj2 = @{
            @"a": @{
                    @"b": @"aaa",
                    @"c": @"wrong type",
            },
    };
    STAssertFalse([validator validateObject:obj2], @"");
}

- (void)testBlock
{
    KZLightValidation *validator = [KZLightValidation buildValidator:@{
            @"a": [KZLightValidation block:^BOOL(id object) {
                return ([object isEqual:@"ok"]);
            }]
    }];

    id obj1 = @{
            @"a": @"ok"
    };
    STAssertTrue([validator validateObject:obj1], @"");

    id obj2 = @{
            @"a": @"ng"
    };
    STAssertFalse([validator validateObject:obj2], @"");
}

@end
