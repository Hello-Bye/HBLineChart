//
// Created by Jörg Polakowski on 14/12/13.
// Copyright (c) 2013 kevinzhow. All rights reserved.
//

#import "PNLineChartData.h"
#import "PNLineChartDataItem.h"

@implementation PNLineChartColorRange

- (id)initWithRange:(NSRange)range color:(UIColor *)color {
    self = [super init];
    if (self) {
        self.range = range;
        self.color = color;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    PNLineChartColorRange *copy = [[self class] allocWithZone:zone];
    copy.color = self.color;
    copy.range = self.range;
    return copy;
}

@end

#pragma mark -

@implementation PNLineChartData

- (id)init
{
    self = [super init];
    if (self) {
        [self setupDefaultValues];
    }
    
    return self;
}

//- (void)setDatas:(NSArray *)datas {
//    _datas = datas;
//    self.itemCount = datas.count;
//    self.getData = ^(NSUInteger index) {
//        CGFloat yValue = [datas[index] floatValue];
//        return [PNLineChartDataItem dataItemWithY:yValue];
//    };
//}
- (void)setDatas:(NSDictionary *)datas {
    _datas = datas;
    self.itemCount = datas.count;
    self.getData = ^(NSString *key) {
        NSNumber *yValue = datas[key];
        
        return yValue != nil ? [PNLineChartDataItem dataItemWithY:yValue.floatValue] : nil;
    };
}

- (void)setupDefaultValues
{
//    _datas = [NSArray array];
    _datas = [NSDictionary dictionary];
    _inflexionPointStyle = PNLineChartPointStyleNone;
    _inflexionPointWidth = 1.0;
    _lineWidth = 1.0;
    _color = [UIColor blueColor];
    _alpha = 1.0;
    _showPointLabel = NO;
    _pointLabelColor = [UIColor blackColor];
    _pointLabelFont = [UIFont systemFontOfSize:5.0];
    _pointLabelFormat = @"%1.f";
    _rangeColors = nil;
}

@end
