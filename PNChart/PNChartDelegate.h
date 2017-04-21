//
//  PNChartDelegate.h
//  PNChartDemo
//
//  Created by kevinzhow on 13-12-11.
//  Copyright (c) 2013年 kevinzhow. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PNChartDelegate <NSObject>
@optional
/**
 *  当用户点击了图标时调用的回调方法
 */
- (void)userClickedOnLineChart;

/**
 * 当用户点击图表上的曲线时调用的回调方法。
 */
- (void)userClickedOnLinePoint:(CGPoint)point lineIndex:(NSInteger)lineIndex;

/**
 * 当用户点击图表上曲线的关键点时调用的回调方法。
 */
- (void)userClickedOnLineKeyPoint:(CGPoint)point
                        lineIndex:(NSInteger)lineIndex
                       pointIndex:(NSInteger)pointIndex;
@end
