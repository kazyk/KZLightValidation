//
//  Created by TAKAHASHI kazuyuki on 2013/04/12.
//


#import "KZLightValidation.h"

@interface KZLightValidationString : KZLightValidation
@end

@implementation KZLightValidationString
- (BOOL)validateObject:(id)object
{
    return [object isKindOfClass:[NSString class]];
}
@end

@interface KZLightValidationNumber : KZLightValidation
@end

@implementation KZLightValidationNumber
- (BOOL)validateObject:(id)object
{
    return [object isKindOfClass:[NSNumber class]];
}
@end

@interface KZLightValidationArray : KZLightValidation
@end

@implementation KZLightValidationArray
{
    KZLightValidation *_elementValidator;
}

- (KZLightValidation *)initWithFormatObject:(id)formatObject
{
    NSParameterAssert([formatObject isKindOfClass:[NSArray class]]);
    self = [super initWithFormatObject:formatObject];
    if (self) {
        if ([formatObject count] > 0) {
            _elementValidator = [KZLightValidation buildValidator:formatObject[0]];
        }
    }
    return self;
}

- (BOOL)validateObject:(id)object
{
    if (![object isKindOfClass:[NSArray class]]) {
        return NO;
    }
    if (_elementValidator == nil) {
        return YES;
    }
    for (id e in object) {
        if (![_elementValidator validateObject:e]) {
            return NO;
        }
    }
    return YES;
}
@end

@interface KZLightValidationDictionary : KZLightValidation
@end

@implementation KZLightValidationDictionary
{
    NSMutableDictionary *_elementValidators;
}

- (KZLightValidation *)initWithFormatObject:(id)formatObject
{
    NSParameterAssert([formatObject isKindOfClass:[NSDictionary class]]);
    self = [super initWithFormatObject:formatObject];
    if (self) {
        if ([formatObject count] > 0) {
            _elementValidators = [[NSMutableDictionary alloc] initWithCapacity:[formatObject count]];
            for (id key in formatObject) {
                _elementValidators[key] = [KZLightValidation buildValidator:formatObject[key]];
            }
        }
    }
    return self;
}

- (BOOL)validateObject:(id)object
{
    if (![object isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    for (id key in _elementValidators) {
        if (![_elementValidators[key] validateObject:object[key]]) {
            return NO;
        }
    }
    return YES;
}
@end


typedef BOOL (^Block)(id object);

@interface KZLightValidationBlock : KZLightValidation
@end

@implementation KZLightValidationBlock
{
    Block _block;
}

- (KZLightValidation *)initWithFormatObject:(id)formatObject
{
    NSParameterAssert(formatObject);
    self = [super initWithFormatObject:formatObject];
    if (self) {
        _block = [formatObject copy];
    }
    return self;
}

- (BOOL)validateObject:(id)object
{
    return _block(object);
}
@end



@implementation KZLightValidation

+ (instancetype)buildValidator:(id)formatObject
{
    id validator = nil;

    NSDictionary *classMap = @{
            (id)[NSString class] : [KZLightValidationString class],
            (id)[NSNumber class] : [KZLightValidationNumber class],
            (id)[NSArray class] : [KZLightValidationArray class],
            (id)[NSDictionary class] : [KZLightValidationDictionary class],
    };

    for (Class klass in classMap) {
        if ([formatObject isKindOfClass:klass]) {
            validator = [[classMap objectForKey:klass] validatorWithFormatObject:formatObject];
            break;
        }
        if ([formatObject isKindOfClass:[KZLightValidationBlock class]]) {
            validator = formatObject;
            break;
        }
    }
    if (validator == nil) {
        validator = [KZLightValidation validatorWithFormatObject:formatObject];
    }

    return validator;
}

+ (id)block:(BOOL (^)(id))block
{
    return [KZLightValidationBlock validatorWithFormatObject:block];
}


+ (instancetype)validatorWithFormatObject:(id)formatObject
{
    return [[self alloc] initWithFormatObject:formatObject];
}

- (instancetype)initWithFormatObject:(id __unused)formatObject
{
    self = [super init];
    return self;
}

- (id)init
{
    self = [self initWithFormatObject:nil];
    return self;
}

- (BOOL)validateObject:(id)object
{
    return YES;
}

@end


