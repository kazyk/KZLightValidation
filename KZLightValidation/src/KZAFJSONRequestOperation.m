//
//  Created by TAKAHASHI kazuyuki on 2013/04/12.
//


#import "KZAFJSONRequestOperation.h"
#import "KZLightValidation.h"

NSString *const kKZJSONValidationErrorDomain = @"KZJSONValidationError";

@implementation KZAFJSONRequestOperation

+ (instancetype)operationWithRequest:(NSURLRequest *)urlRequest
                    JSONFormatObject:(id)formatObject
                             success:(void (^)(NSURLRequest *, NSHTTPURLResponse *, id))success
                             failure:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id))failure
{
    return [self operationWithRequest:urlRequest
                        JSONValidator:[KZLightValidation buildValidator:formatObject]
                              success:success
                              failure:failure];
}

+ (instancetype)operationWithRequest:(NSURLRequest *)urlRequest
                       JSONValidator:(KZLightValidation *)validator
                             success:(void (^)(NSURLRequest *, NSHTTPURLResponse *, id))success
                             failure:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id))failure
{
    return [self JSONRequestOperationWithRequest:urlRequest
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                             if (validator != nil && [validator validateObject:JSON]) {
                                                 if (success) {
                                                     success(request, response, JSON);
                                                 }
                                             } else {
                                                 if (failure) {
                                                     NSError *err = [NSError errorWithDomain:kKZJSONValidationErrorDomain
                                                                                        code:0
                                                                                    userInfo:nil];
                                                     failure(request, response, err, JSON);
                                                 }
                                             }
                                         }
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             if (failure) {
                                                 failure(request, response, error, JSON);
                                             }
                                         }];
}


@end