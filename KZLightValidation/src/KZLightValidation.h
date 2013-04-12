//
//  Created by TAKAHASHI kazuyuki on 2013/04/12.
//


#import <Foundation/Foundation.h>


@interface KZLightValidation : NSObject

+ (KZLightValidation *)buildValidator:(id)formatObject;

+ (instancetype)validatorWithFormatObject:(id)formatObject;

- (instancetype)initWithFormatObject:(id)formatObject;

- (BOOL)validateObject:(id)object;

@end