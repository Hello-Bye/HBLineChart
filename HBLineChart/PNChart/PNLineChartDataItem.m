//
// Created by Jörg Polakowski on 14/12/13.
// Copyright (c) 2013 kevinzhow. All rights reserved.
//

#import "PNLineChartDataItem.h"

@interface PNLineChartDataItem ()

@property (readwrite) CGFloat y;    
@property (readwrite) CGFloat rawY;
@end

@implementation PNLineChartDataItem

+ (PNLineChartDataItem *)dataItemWithY:(CGFloat)y {
    return [[PNLineChartDataItem alloc] initWithY:y andRawY:y];
}

+ (PNLineChartDataItem *)dataItemWithY:(CGFloat)y andRawY:(CGFloat)rawY {
    return [[PNLineChartDataItem alloc] initWithY:y andRawY:rawY];
}

- (id)initWithY:(CGFloat)y andRawY:(CGFloat)rawY {
    if (self = [super init]) {
        self.y = y;
        self.rawY = rawY;
    }
    return self;
}

@end
