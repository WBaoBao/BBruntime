//
//  DWExchangeTwoMethod.m
//  runtime
//
//  Created by apple on 2018/7/6.
//  Copyright © 2018年 baobao. All rights reserved.
//

#import "DWExchangeTwoMethod.h"
#import <objc/runtime.h>

@implementation DWExchangeTwoMethod

- (instancetype)init
{
    self = [super init];
    if (self) {
       
        
    }
    return self;
}

- (void)play {
    NSLog(@"这是一个实例方法");
}

+ (void)work {
    NSLog(@"这是一个类方法");
}

@end
