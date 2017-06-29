//
//  ESP_SmartConfig.h
//  WifiWeatherClock
//
//  Created by Adsmart on 2017/4/8.
//  Copyright © 2017年 Adsmart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPTouchResult.h"

@interface ESP_SmartConfig : NSObject

+ (instancetype)shareESP_SmartConfig;

/**
 开始寻找设备

 @param ssid ssid
 @param bssid bssid
 @param password password
 @param count 需要寻找的个数
 @param workQueue 工作线程 必须是非主线程
 @param completion 寻找的结果 results中满足 !touchResult.isCancelled && touchResult.isSuc  即是成功找到了
 */
- (void)executeForResultsWithSsid:(NSString *)ssid bssid:(NSString *)bssid password:(NSString *)password findDeviceCount:(NSInteger)count workQueue:(dispatch_queue_t)workQueue completion: (void (^)(NSArray<ESPTouchResult *> *results))completion;

/**
 取消寻找设备
 */
- (void)cancel;

@end
