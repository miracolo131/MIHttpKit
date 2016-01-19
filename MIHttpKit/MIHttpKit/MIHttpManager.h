//
//  MIHttpManager.h
//  MIHttpKit
//
//  Created by qf on 16/1/19.
//  Copyright © 2016年 MI-31. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  请求成功回调
 *
 *  @param json 请求到的json字典
 */
typedef void (^ Success) (NSDictionary *json);

/**
 *  请求失败
 *
 *  @param error 错误信息
 */
typedef void (^ Failure) (NSError *error);

@interface MIHttpManager : NSObject

/**
 *  请求url
 */
@property (nonatomic, copy) NSString *url;

/**
 *  请求方式
 */
@property (nonatomic, assign) NSString *method;

/**
 *  请求参数字典
 */
@property (nonatomic, strong) NSDictionary *params;

/**
 *  请求
 */
@property (nonatomic, strong) NSMutableURLRequest *request;

/**
 *  请求成功回调
 */
@property (nonatomic, copy) Success completionSuccess;

/**
 *  请求失败回调
 */
@property (nonatomic, copy) Failure completionFailure;

/**
 *  初始化
 *
 *  @param method            请求方式
 *  @param url               请求url
 *  @param params            请求参数
 *  @param completionHandler 请求完成回调
 *
 *  @return
 */
- (instancetype)initWithMethod:(NSString *)method
                           url:(NSString *)url
                        params:(NSDictionary *)params
                       success:(Success)success
                       failure:(Failure)failure;

+ (instancetype)manager;

+ (void)postWithUrl:(NSString *)url
             params:(NSDictionary *)params
            success:(Success)success
            failure:(Failure)failure;

+ (void)getWithUrl:(NSString *)url
            params:(NSDictionary *)params
           success:(Success)success
           failure:(Failure)failure;


@end
