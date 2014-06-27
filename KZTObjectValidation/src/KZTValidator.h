//
//  Created by TAKAHASHI kazuyuki on 2013/04/12.
//


#import <Foundation/Foundation.h>


@interface KZTValidator : NSObject

+ (KZTValidator *)buildValidator:(id)formatObject;

+ (KZTValidator *)blockValidator:(BOOL(^)(id object))block;

- (BOOL)validateObject:(id)object;

@end

