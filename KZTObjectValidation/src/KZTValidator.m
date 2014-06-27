//
//  Created by TAKAHASHI kazuyuki on 2013/04/12.
//


#import "KZTValidator.h"


static NSString *const KZTValidatorFormatException = @"KZTValidatorFormatException";


@interface KZTValidator ()
+ (instancetype)validator;
- (instancetype)initWithFormatObject:(id)formatObject;
@end


@interface KZTStringValidator : KZTValidator
@end

@implementation KZTStringValidator
- (BOOL)validateObject:(id)object
{
    return [object isKindOfClass:[NSString class]];
}
@end

@interface KZTNumberValidator : KZTValidator
@end

@implementation KZTNumberValidator
- (BOOL)validateObject:(id)object
{
    return [object isKindOfClass:[NSNumber class]];
}
@end

@interface KZTArrayValidator : KZTValidator
@end

@implementation KZTArrayValidator
{
    KZTValidator *_elementValidator;
}

- (KZTValidator *)initWithFormatObject:(id)formatObject
{
    NSParameterAssert([formatObject isKindOfClass:[NSArray class]]);
    self = [super initWithFormatObject:formatObject];
    if (self) {
        if ([formatObject count] > 0) {
            _elementValidator = [KZTValidator build:formatObject[0]];
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

@interface KZTDictionaryValidator : KZTValidator
@end

@implementation KZTDictionaryValidator
{
    NSMutableDictionary *_elementValidators;
}

- (KZTValidator *)initWithFormatObject:(id)formatObject
{
    NSParameterAssert([formatObject isKindOfClass:[NSDictionary class]]);
    self = [super initWithFormatObject:formatObject];
    if (self) {
        if ([formatObject count] > 0) {
            _elementValidators = [[NSMutableDictionary alloc] initWithCapacity:[formatObject count]];
            for (id key in formatObject) {
                _elementValidators[key] = [KZTValidator build:formatObject[key]];
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


typedef BOOL (^KZTValidatorBlock)(id object);

@interface KZTBlockValidator : KZTValidator
@end

@implementation KZTBlockValidator
{
    KZTValidatorBlock _block;
}

- (KZTValidator *)initWithFormatObject:(id)formatObject
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


@interface KZTAnyValidator : KZTValidator
@end

@implementation KZTAnyValidator

- (BOOL)validateObject:(id)object
{
    return YES;
}

@end


@interface KZTNotNilValidator : KZTValidator
@end

@implementation KZTNotNilValidator

- (BOOL)validateObject:(id)object
{
    return (object != nil && object != [NSNull null]);
}

@end


@implementation KZTValidator

+ (instancetype)build:(id)formatObject
{
    id validator = nil;

    NSDictionary *classMap = @{
            (id)[NSString class] : [KZTStringValidator class],
            (id)[NSNumber class] : [KZTNumberValidator class],
            (id)[NSArray class] : [KZTArrayValidator class],
            (id)[NSDictionary class] : [KZTDictionaryValidator class],
    };

    for (Class klass in classMap) {
        if ([formatObject isKindOfClass:klass]) {
            validator = [[[classMap objectForKey:klass] alloc] initWithFormatObject:formatObject];
            break;
        }
        if ([formatObject isKindOfClass:[KZTValidator class]]) {
            validator = formatObject;
            break;
        }
    }
    if (validator == nil) {
        [[NSException exceptionWithName:KZTValidatorFormatException
                                 reason:@"format object is invalid"
                               userInfo:@{
                                       @"object": formatObject,
                               }] raise];
    }

    return validator;
}

+ (KZTValidator *)block:(BOOL(^)(id object))block
{
    return [[KZTBlockValidator alloc] initWithFormatObject:block];
}

+ (KZTValidator *)any
{
    return [KZTAnyValidator validator];
}

+ (KZTValidator *)notNil
{
    return [KZTNotNilValidator validator];
}

+ (instancetype)validator
{
    return [[self alloc] initWithFormatObject:nil];
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
    NSAssert(NO, @"not implemented");
    return YES;
}

@end


