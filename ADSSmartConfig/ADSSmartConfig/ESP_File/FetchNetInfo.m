//
//  FetchNetInfo.m
//  WifiWeatherClock
//
//  Created by Adsmart on 17/3/1.
//  Copyright © 2017年 Adsmart. All rights reserved.
//

#import "FetchNetInfo.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "ESP_NetUtil.h"
#import "AFNetworkReachabilityManager.h"
#import <UIKit/UIKit.h>

static FetchNetInfo *_fetchNetInfo = nil;

static BOOL flag = YES;

@interface FetchNetInfo ()
{
    AFNetworkReachabilityManager *_afNetworkReachabilityManager;
}
@end

@implementation FetchNetInfo

+ (instancetype)shareFetchNetInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _fetchNetInfo = [[FetchNetInfo alloc] init];
                
    });
    return _fetchNetInfo;
}
    
- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        __weak typeof(self) weakSelf = self;
        _afNetworkReachabilityManager = [AFNetworkReachabilityManager sharedManager];
        [_afNetworkReachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            
            switch (status) {
                case AFNetworkReachabilityStatusNotReachable:{
                    NSLog(@"网络不通：%@",@(status) );
                    break;
                }
                case AFNetworkReachabilityStatusReachableViaWiFi:{
                    NSLog(@"网络通过WIFI连接：%@",@(status));
                    break;
                }
                    
                case AFNetworkReachabilityStatusReachableViaWWAN:{
                    NSLog(@"网络通过无线连接：%@",@(status) );
                    break;
                }
                default:
                    break;
            }
            
            [weakSelf doApplicationDidBecomeActiveNotification];
            
            // 网络状态发送了改变
            [[NSNotificationCenter defaultCenter] postNotificationName:kChangeNetworkStateNotification object:nil];
            
            // 开机的第一次不需要进去
            if (flag) {
                flag = NO;
                [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(doApplicationDidBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
            }
            
        }];
        [_afNetworkReachabilityManager startMonitoring];  //开启网络监视器；
        
    }
    return self;
    
}

- (void)doApplicationDidBecomeActiveNotification {
    
    NSDictionary *netInfo = [self fetchNetInfo];
    NSString *ssid = [self fetchSsidWithFetchNetInfo:netInfo];
    // 说明修改了WiFi或者关闭了WiFi
    if (![_SSID isEqualToString:ssid]) {
        _SSID = ssid;
        _BSSID = [self fetchBssidWithFetchNetInfo:netInfo];
        
        [self checkWhetherIPv4andIPv6_Supported]; // 验证 IPv4 IPv6
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kChangeFetchNetInfoNotification object:self];
        
    }
    
    NSLog(@"getLocalInetAddress = %@  _SSID = %@ _BSSID = %@",[self getLocalInetAddress],_SSID,_BSSID);
    
    // 开机的第一次不需要进去
    if (ssid && flag == NO) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self]; // 取消之前的
        [self performSelector:@selector(confirmWifiState) withObject:nil afterDelay:2.5 inModes:@[NSRunLoopCommonModes]];
    }
    
}

#pragma mark - WiFi有可能正在连接但是没有真正连接上  做一个延时去重新启动udpsocket的端口监听
- (void)confirmWifiState {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kConfirmFetchNetInfoNotification object:self];
    
}

- (void)checkWhetherIPv4andIPv6_Supported {
    
    NSString *localInetAddr4 = [ESP_NetUtil getLocalIPv4];
    if (![ESP_NetUtil isIPv4PrivateAddr:localInetAddr4]) {
        localInetAddr4 = nil;
    }
    NSString *localInetAddr6 = [ESP_NetUtil getLocalIPv6];
    _isIPv4 = localInetAddr4 != nil;
    _isIPv6 = localInetAddr6 != nil;
    
}

- (NSString *)getLocalInetAddress {
    
    return _isIPv4 ? [ESP_NetUtil getLocalIPv4] : [ESP_NetUtil getLocalIPv6];
    
}

- (NSString *)fetchSsidWithFetchNetInfo:(NSDictionary *)netInfo
{
    return [netInfo objectForKey:@"SSID"];
}
    
- (NSString *)fetchBssidWithFetchNetInfo:(NSDictionary *)netInfo
{
    return [netInfo objectForKey:@"BSSID"];
}
    
// refer to http://stackoverflow.com/questions/5198716/iphone-get-ssid-without-private-library
- (NSDictionary *)fetchNetInfo
{
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    NSLog(@"%s: Supported interfaces: %@", __func__, interfaceNames);
    
    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        NSLog(@"%s: %@ => %@", __func__, interfaceName, SSIDInfo);
        
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            break;
        }
    }
    return SSIDInfo;
}

@end
