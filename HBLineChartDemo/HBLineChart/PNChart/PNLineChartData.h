//
// Created by Jörg Polakowski on 14/12/13.
// Copyright (c) 2013 kevinzhow. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PNLineChartPointStyle) {
    PNLineChartPointStyleNone = 0,
    PNLineChartPointStyleCircle = 1,
    PNLineChartPointStyleSquare = 3,
    PNLineChartPointStyleTriangle = 4
};

@class PNLineChartDataItem;

//typedef PNLineChartDataItem *(^LCLineChartDataGetter)(NSUInteger item);
typedef  PNLineChartDataItem * (^LCLineChartDataGetter)( NSString *key);


// 曲线区间范围颜色对象
@interface PNLineChartColorRange : NSObject<NSCopying>

@property(nonatomic) BOOL inclusive;
@property(nonatomic) NSRange range;
@property(nonatomic, retain) UIColor *color;

- (id)initWithRange:(NSRange)range color:(UIColor *)color;
@end

#pragma mark -

// 曲线对象，一个 ‘PNLineChartData’ 就是一条曲线
@interface PNLineChartData : NSObject
//@property (nonatomic, strong) NSArray *datas;
@property (nonatomic, strong) NSDictionary *datas; // key:value x轴点：y轴点

@property (nonatomic, assign) NSUInteger itemCount;
@property (nonatomic, copy)   LCLineChartDataGetter getData;
@property (nonatomic, copy)   NSString *dataTitle;
@property (nonatomic, assign) CGFloat lineWidth; // defult is 1.0
@property (nonatomic, assign) CGFloat alpha;    // defult is 1.0
@property (nonatomic, strong) UIColor *color;   // defult is blue

// 弯曲折点文字
@property (nonatomic, assign) BOOL showPointLabel;  // defult is NO
@property (nonatomic, strong) UIColor *pointLabelColor; // defult is black
@property (nonatomic, strong) UIFont *pointLabelFont;   // defult is 5
@property (nonatomic, copy)   NSString *pointLabelFormat;   // defult is "%1.f"

/**
 *  曲线区间颜色数组，这个属性值会改变曲线对应区间的线段颜色
 */
@property(nonatomic, strong) NSArray<PNLineChartColorRange *> *rangeColors;

/**
 *  弯曲处的颜色
 */
@property (nonatomic, strong) UIColor *inflexionPointColor;
/**
 *  弯曲处的样式
 */
@property (nonatomic, assign) PNLineChartPointStyle inflexionPointStyle;
/**
 *  inflexionPointStyle 不为 None 时有效, 弯曲处的宽度.
 */
@property (nonatomic, assign) CGFloat inflexionPointWidth;

@end
