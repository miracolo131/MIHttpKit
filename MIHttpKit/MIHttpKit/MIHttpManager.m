//
//  MIHttpManager.m
//  MIHttpKit
//
//  Created by qf on 16/1/19.
//  Copyright © 2016年 MI-31. All rights reserved.
//

#import "MIHttpManager.h"

@implementation MIHttpManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithMethod:(NSString *)method url:(NSString *)url params:(NSDictionary *)params success:(Success)success failure:(Failure)failure
{
    if (self = [super init]) {
        self.method = method;
        self.url = url;
        self.params = params;
        self.completionSuccess = success;
        self.completionFailure = failure;
    }
    return self;
}

+ (instancetype)manager
{
    return [[self alloc] init];
}

+ (void)postWithUrl:(NSString *)url params:(NSDictionary *)params success:(Success)success failure:(Failure)failure
{
    MIHttpManager *manager = [[MIHttpManager alloc] initWithMethod:@"POST"
                                                                       url:url
                                                                    params:params
                                                                   success:success
                                                                   failure:failure];
    [manager start];
}

+ (void)getWithUrl:(NSString *)url params:(NSDictionary *)params success:(Success)success failure:(Failure)failure
{
    MIHttpManager *manager = [[MIHttpManager alloc] initWithMethod:@"GET"
                                                                       url:url
                                                                    params:params
                                                                   success:success
                                                                   failure:failure];
    [manager start];
}

- (void)start
{
    [self buildRequest];
    [self buildHttpBody];
    [self startTask];
}

- (void)buildRequest
{
    if ([self.method isEqualToString:@"GET"] && self.params.count > 0) {
        NSString *paramsStr = [self buildParamsString:self.params];
        self.url = [NSString stringWithFormat:@"%@?%@", self.url, paramsStr];
    }
    self.request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    self.request.timeoutInterval = 20;
    self.request.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    
    self.request.HTTPMethod = self.method;
}

- (void)buildHttpBody
{
    if (self.params.count > 0) {
        NSString *paramsStr = [self buildParamsString:self.params];
        self.request.HTTPBody = [paramsStr dataUsingEncoding:NSUTF8StringEncoding];
    }
}

- (void)startTask
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:self.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary *jsonDic = [self parseJsonData:data];
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.completionSuccess(jsonDic);
            });
            
        }else{
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.completionFailure(error);
            });
            
        }
        
    }];
    [task resume];
}

/**
 *  将json数据解析为json字典
 *
 *  @param data json数据
 *
 *  @return json字典
 */
- (NSDictionary *)parseJsonData:(NSData *)data
{
    NSError *error;
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if (error == nil) {
        return jsonDic;
    }else{
        NSString *originalStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        // 解析失败返回失败原因，与服务器发来的字符串信息
        return @{@"error" : error,
                 @"originalStr" : originalStr};
    }
}

/**
 *  将字典转换成参数字符串
 *
 *  @param params 参数字典
 *
 *  @return 参数字符串
 */
- (NSString *)buildParamsString:(NSDictionary *)params
{
    NSString *paramsStr = @"";
    NSArray *keys = [params allKeys];
    for (NSString *key in keys) {
        paramsStr = [paramsStr stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", key, params[key]]];
    }
    paramsStr = [paramsStr substringToIndex:paramsStr.length - 1];
    return paramsStr;
}


@end
