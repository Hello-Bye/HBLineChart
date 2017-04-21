//
//  TYChartView.h
//  TuyaSmartPublic
//
//  Created by GeekZooStudio on 17/4/18.
//  Copyright © 2017年 Tuya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNChart.h"

@protocol TYChartViewDelegate <NSObject>
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

@interface TYChartView : UIView
@property (nonatomic, weak) id<TYChartViewDelegate> delegate;

@property (nonatomic, strong) PNLineChart *lineChart;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *outdoorCurrentPM;
@property (nonatomic, strong) UILabel *indoorCurrentPM;

@property (nonatomic, strong) PNLineChartData *outdoorLineChartData;
@property (nonatomic, strong) PNLineChartData *indoorLineChartData;

@property (nonatomic, assign) BOOL hideOutdoorLabel;
@end
