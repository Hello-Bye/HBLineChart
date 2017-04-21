//
//  PNLineChart.h
//  PNChartDemo
//
//  Created by kevin on 11/7/13.
//  Copyright (c) 2013年 kevinzhow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PNChartDelegate.h"

@class PNLineChartData;

@interface PNLineChart : UIView

@property (nonatomic, weak) id <PNChartDelegate> delegate;

// x,y坐标轴上的刻度值
@property (nonatomic, strong) NSArray *xLabels;
@property (nonatomic, strong) NSArray *yLabels;
// x轴刻度值属性
@property (nonatomic, assign) CGFloat xLabelWidth;
@property (nonatomic, strong) UIFont *xLabelFont;
@property (nonatomic, strong) UIColor *xLabelColor;
// y轴刻度值属性
@property (nonatomic, assign) CGFloat yLabelHeight;
@property (nonatomic, strong) UIFont *yLabelFont;
@property (nonatomic, strong) UIColor *yLabelColor;

@property (nonatomic, assign) CGFloat yValueMax;
@property (nonatomic, assign) CGFloat yValueMin;
@property (nonatomic, assign) CGFloat yFixedValueMax;
@property (nonatomic, assign) CGFloat yFixedValueMin;

// 曲线数组, 一个 'LineChartData' 就是一条线
@property (nonatomic, strong) NSArray<PNLineChartData *> *chartData;

//
@property (nonatomic, strong) NSMutableArray *pathPoints;
@property (nonatomic, strong) NSMutableArray *xChartLabels;
@property (nonatomic, strong) NSMutableArray *yChartLabels;

// 图表是否有动画过度 默认yes
@property (nonatomic, assign) BOOL displayAnimated;

// 是否显示坐标轴上的刻度值 默认yes
@property (nonatomic, assign) BOOL showLabel;

// 格子线 默认yes  颜色 gray
@property (nonatomic, assign) BOOL showYGridLines;
@property (nonatomic, assign) BOOL showXGridLines;
@property (nonatomic, strong) UIColor *yGridLinesColor;
@property (nonatomic, strong) UIColor *xGridLinesColor;

// 画图上下左右间距
@property (nonatomic, assign) CGFloat chartMarginLeft;
@property (nonatomic, assign) CGFloat chartMarginRight;
@property (nonatomic, assign) CGFloat chartMarginTop;
@property (nonatomic, assign) CGFloat chartMarginBottom;

// 画图区域（根据上下左右间距调整）
@property (nonatomic, assign, readonly) CGRect chartDrawRect;

// 坐标文字和坐标轴之间的间距  默认 5
@property (nonatomic, assign) CGFloat axisOffset;

// 是否显示坐标轴 默认yes
@property (nonatomic, getter = isShowCoordinateAxis) BOOL showCoordinateAxis;
@property (nonatomic, strong) UIColor *axisColor;
@property (nonatomic, assign) CGFloat axisWidth;

// 坐标轴数值标签（x轴代表什么，y轴代表什么）
@property (nonatomic, strong) NSString *xUnit;
@property (nonatomic, strong) NSString *yUnit;


// y轴的刻度数值格式(小数位数). 默认 @"%1.f"
@property (nonatomic, strong) NSString *yLabelFormat;

//
@property (nonatomic, assign) BOOL thousandsSeparator;
@property (nonatomic, copy) NSString* (^yLabelBlockFormatter)(CGFloat);

// 是否显示弧形的曲线 默认no
@property (nonatomic, assign) BOOL showSmoothLines;

// 开始画图
- (void)strokeChart;


+ (CGSize)sizeOfString:(NSString *)text withWidth:(float)width font:(UIFont *)font;

+ (CGPoint)midPointBetweenPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2;
+ (CGPoint)controlPointBetweenPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2;

@end
