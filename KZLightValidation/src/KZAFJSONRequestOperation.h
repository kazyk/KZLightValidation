//
//  Created by TAKAHASHI kazuyuki on 2013/04/12.
//


#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@class KZLightValidation;

@interface KZAFJSONRequestOperation : AFJSONRequestOperation

+ (instancetype)operationWithRequest:(NSURLRequest *)urlRequest
                    JSONFormatObject:(id)formatObject
                             success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                             failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (instancetype)operationWithRequest:(NSURLRequest *)urlRequest
                       JSONValidator:(KZLightValidation *)validator
                             success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                             failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

@end