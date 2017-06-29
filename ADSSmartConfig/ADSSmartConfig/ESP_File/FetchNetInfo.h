//
//  FetchNetInfo.h
//  WifiWeatherClock
//
//  Created by Adsmart on 17/3/1.
//  Copyright © 2017年 Adsmart. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *kChangeFetchNetInfoNotification = @"XYChangeFetchNetInfoNotification";

static NSString *kConfirmFetchNetInfoNotification = @"XYConfirmFetchNetInfoNotification";

@interface FetchNetInfo : NSObject

@property (nonatomic,copy,readonly) NSString *SSID; // WiFi名字

@property (nonatomic,copy,readonly) NSString *BSSID; // WiFi Mac地址

@property (nonatomic,assign,readonly) BOOL isIPv4;

@property (nonatomic,assign,readonly) BOOL isIPv6;

+ (instancetype)shareFetchNetInfo; // 单例

- (NSString *)getLocalInetAddress; // 返回本地的IP地址

@end
