//
//  Created by TAKAHASHI kazuyuki on 2013/04/12.
//


#import <Foundation/Foundation.h>


@interface KZTValidator : NSObject

+ (KZTValidator *)buildValidator:(id)formatObject;

+ (id)block:(BOOL(^)(id object))block;

- (BOOL)validateObject:(id)object;

@end

