//
//  UIButton+XT.m
//  防止按钮被重复点击
//
//  Created by Gandalf on 17/2/16.
//  Copyright © 2017年 Gandalf. All rights reserved.
//

#import "UIButton+XT.h"
#import <objc/runtime.h>

// 默认时间间隔
#define defaultInterval 1

@interface UIButton()

// 忽略点击时间  YES：是  NO：否
@property (nonatomic, assign) BOOL isIgnoreEvent;

@end

@implementation UIButton (XT)

static const char *UIControl_eventTimeInterval = "UIControl_eventTimeInterval";
static const char *UIControl_enventIsIgnoreEvent = "UIControl_enventIsIgnoreEvent";

// runtime动态绑定属性
- (void)setIsIgnoreEvent:(BOOL)isIgnoreEvent
{
    objc_setAssociatedObject(self, UIControl_enventIsIgnoreEvent, @(isIgnoreEvent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)isIgnoreEvent
{
    return [objc_getAssociatedObject(self, UIControl_enventIsIgnoreEvent) boolValue];
}

- (void)setEventTimeInterval:(NSTimeInterval)eventTimeInterval
{
    objc_setAssociatedObject(self, UIControl_eventTimeInterval, @(eventTimeInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSTimeInterval)eventTimeInterval
{
    return [objc_getAssociatedObject(self, UIControl_eventTimeInterval) doubleValue];
}

+ (void)load
{
    // method swizzling
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector = @selector(sendAction:to:forEvent:);
        SEL destinationSelector = @selector(xt_sendAction:to:forEvent:);
        
        Method originalMethod = class_getInstanceMethod(self, originalSelector);
        Method destinationMethod = class_getInstanceMethod(self, destinationSelector);
        
        BOOL isExist = class_addMethod(self, originalSelector, method_getImplementation(destinationMethod), method_getTypeEncoding(destinationMethod));
        
        if (isExist) {
            // 直接替换
            class_replaceMethod(self, destinationSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            // 添加失败了 说明本类中有destinationMethod的实现，此时只需要将originalMethod和destinationMethod的IMP互换一下即可
            method_exchangeImplementations(originalMethod, destinationMethod);
        }
    });
}

- (void)xt_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    self.eventTimeInterval = self.eventTimeInterval == 0 ? defaultInterval : self.eventTimeInterval;
    
    if (self.isIgnoreEvent) {
        return;
    } else if (self.eventTimeInterval > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.eventTimeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setIsIgnoreEvent:NO];
        });
    }
    
    self.isIgnoreEvent = YES;
    // 调用被替换的方法
    [self xt_sendAction:action to:target forEvent:event];
}

@end
