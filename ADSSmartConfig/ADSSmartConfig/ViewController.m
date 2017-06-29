//
//  ViewController.m
//  ADSSmartConfig
//
//  Created by Adsmart on 2017/6/29.
//  Copyright © 2017年 Adsmart. All rights reserved.
//

#import "ViewController.h"
#import "ESP_SmartConfig.h"
#import "FetchNetInfo.h"

@interface ViewController ()

@property (nonatomic,strong) ESP_SmartConfig *smartConfig;

@property (nonatomic,copy) NSString *ssid; // WiFi名字

@property (nonatomic,copy) NSString *bssid; // WiFi Mac地址

@property (nonatomic,copy) NSString *password; // WiFi 密码

@end

@implementation ViewController
{
    dispatch_queue_t _confirm_queue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 初始化单例类 获取WiFi的信息
    FetchNetInfo *fetchNetInfo = [FetchNetInfo shareFetchNetInfo];
    self.ssid = fetchNetInfo.SSID;
    self.bssid = fetchNetInfo.BSSID;
    
    // 初始化WiFi的密码
    self.password = @"39218917";
    
    // 开始进入 smartConfig
    self.smartConfig = [ESP_SmartConfig shareESP_SmartConfig];
    _confirm_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    [self findSmartConfirmForResults:^(NSString *host, NSString *mac, BOOL isSuc) {
       
        NSLog(@"smart config 完成的回调");
        
    }];
    
}

// 开始寻找设备 进入SmartConfirm
- (void)findSmartConfirmForResults:(void (^)(NSString *host,NSString *mac,BOOL isSuc))callBack {
    
    NSLog(@"ESPViewController do confirm action...");
    // 开始寻找设备  这里会卡住当前的线程 所有必须要传入一个子线程
    [self.smartConfig executeForResultsWithSsid:self.ssid bssid:self.bssid password:self.password  findDeviceCount:1 workQueue:_confirm_queue completion:^(NSArray<ESPTouchResult *> *results) {
        
        // 返回结果数组
        NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
            
            ESPTouchResult *firstResult = [results firstObject];
            
            if (!firstResult.isCancelled && [firstResult isSuc]) {
                NSLog(@"smart config成功找到了设备");
                callBack([firstResult getIpAddressString],[firstResult bssid],YES);
            }
            else
            {
                NSLog(@"smart config没找到设备");
                callBack(nil,nil,NO);
            }
            
        }];
        [NSOperationQueue.mainQueue addOperation:blockOperation];
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
