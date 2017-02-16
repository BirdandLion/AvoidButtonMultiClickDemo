//
//  UIButton+XT.h
//  防止按钮被重复点击
//
//  Created by Gandalf on 17/2/16.
//  Copyright © 2017年 Gandalf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (XT)

/**
 *  为按钮添加点击间隔 eventTimeInterval秒
 */
@property (nonatomic, assign) NSTimeInterval eventTimeInterval;

@end
