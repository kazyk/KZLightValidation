//
//  Created by TAKAHASHI kazuyuki on 2013/04/12.
//


#import <Foundation/Foundation.h>


@interface KZTValidator : NSObject

+ (KZTValidator *)build:(id)formatObject;

+ (KZTValidator *)block:(BOOL(^)(id object))block;

+ (KZTValidator *)any;

+ (KZTValidator *)notNil;

- (BOOL)validateObject:(id)object;

@end

