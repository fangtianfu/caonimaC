//
//  ESP_SmartConfig.m
//  WifiWeatherClock
//
//  Created by Adsmart on 2017/4/8.
//  Copyright © 2017年 Adsmart. All rights reserved.
//

#import "ESP_SmartConfig.h"
#import "ESPTouchTask.h"

static ESP_SmartConfig *_smartConfig = nil;

@interface ESP_SmartConfig ()

// without the condition, if the user tap confirm/cancel quickly enough,
// the bug will arise. the reason is follows:
// 0. task is starting created, but not finished
// 1. the task is cancel for the task hasn't been created, it do nothing
// 2. task is created
// 3. Oops, the task should be cancelled, but it is running
@property (nonatomic,strong) NSCondition *_condition;
// to cancel ESPTouchTask when
@property (atomic,strong) ESPTouchTask *_esptouchTask;

@end

@implementation ESP_SmartConfig

+ (instancetype)shareESP_SmartConfig {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _smartConfig = [[ESP_SmartConfig alloc] init];
        _smartConfig._condition = [[NSCondition alloc] init]; // 初始化一个锁
        
    });
    
    return _smartConfig;
}

#pragma mark - the example of how to use executeForResults
- (void)executeForResultsWithSsid:(NSString *)ssid bssid:(NSString *)bssid password:(NSString *)password findDeviceCount:(NSInteger)count workQueue:(dispatch_queue_t)workQueue completion: (void (^)(NSArray<ESPTouchResult *> *results))completion {
    
    dispatch_async(workQueue, ^{
       
        NSLog(@"ESPViewController do the execute work...");
        
        [self._condition lock];
        self._esptouchTask = [[ESPTouchTask alloc]initWithApSsid:ssid andApBssid:bssid andApPwd:password andIsSsidHiden:NO];
        [self._condition unlock];
        NSArray * esptouchResults = [self._esptouchTask executeForResults:count];
        NSLog(@"ESPViewController executeForResult() result is: %@",esptouchResults);
        
        completion(esptouchResults);

    });
    
}

- (void)cancel {
    
    [self._condition lock];
    if (self._esptouchTask != nil)
    {
        [self._esptouchTask interrupt];
    }
    [self._condition unlock];
}

@end
