//
//  TYChartView.m
//  TuyaSmartPublic
//
//  Created by GeekZooStudio on 17/4/18.
//  Copyright © 2017年 Tuya. All rights reserved.
//

#import "TYChartView.h"
#import "UIView+TPAdditions.h"

#define outdoorLineColor    [UIColor greenColor]
#define indoorLineColor     [UIColor redColor]

@interface TYChartView () <PNChartDelegate>
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *outdoorPMTitle;
@property (nonatomic, strong) UIView *outdoorIconView;
@property (nonatomic, strong) UILabel *indoorPMTitle;
@property (nonatomic, strong) UIView *indoorIconView;
@end

@implementation TYChartView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self addChartView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addChartView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.bgView.frame = CGRectMake(10, 10, self.width - 20, self.height - 10);
    self.topView.frame = CGRectMake(8, 8, self.bgView.width - 20, 48);
    self.lineView.frame = CGRectMake(0, self.topView.height - onePixel, self.topView.width, onePixel);
    
    self.titleLabel.frame = CGRectMake(15, 0, 50, self.topView.height);
    
    if (self.hideOutdoorLabel) {
        self.indoorCurrentPM.frame = CGRectMake(self.topView.width - 10 - 28, 0, 28, self.topView.height);
        self.indoorPMTitle.frame = CGRectMake(self.indoorCurrentPM.left - 5 - 28, 0, 28, self.topView.height);
        self.indoorIconView.frame = CGRectMake(self.indoorPMTitle.left - 10, (self.topView.height - 8) / 2.0, 8, 8);
    } else {
        self.outdoorCurrentPM.frame = CGRectMake(self.topView.width - 10 - 28, 0, 28, self.topView.height);
        self.outdoorPMTitle.frame = CGRectMake(self.outdoorCurrentPM.left - 5 - 28, 0, 28, self.topView.height);
        self.outdoorIconView.frame = CGRectMake(self.outdoorPMTitle.left - 10, (self.topView.height - 8) / 2.0, 8, 8);
        
        self.indoorCurrentPM.frame = CGRectMake(self.outdoorIconView.left - 20 - 28, 0, 28, self.topView.height);
        self.indoorPMTitle.frame = CGRectMake(self.indoorCurrentPM.left - 5 - 28, 0, 28, self.topView.height);
        self.indoorIconView.frame = CGRectMake(self.indoorPMTitle.left - 10, (self.topView.height - 8) / 2.0, 8, 8);
    }
    
    self.lineChart.frame = CGRectMake(self.topView.left, self.topView.top + self.topView.height, self.topView.width, self.bgView.height - self.topView.top - self.topView.height - 10);
}

- (void)addChartView {
    self.backgroundColor = [UIColor clearColor];
    
    self.bgView = ({
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
        bgView.layer.cornerRadius = 2;
        bgView.layer.masksToBounds = YES;
        bgView;
    });
    [self addSubview:self.bgView];
    
    self.topView = ({
        UIView *topView = [[UIView alloc] init];
        topView.backgroundColor = [UIColor clearColor];
        
        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.15];
        [topView addSubview:self.lineView];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.text = @"PM2.5";
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        [topView addSubview:self.titleLabel];
        
        self.outdoorCurrentPM = [[UILabel alloc] init];
        self.outdoorCurrentPM.textColor = [UIColor whiteColor];
        self.outdoorCurrentPM.font = [UIFont systemFontOfSize:14];
        self.outdoorCurrentPM.textAlignment = NSTextAlignmentLeft;
        [topView addSubview:self.outdoorCurrentPM];
        
        self.outdoorPMTitle = [[UILabel alloc] init];
        self.outdoorPMTitle.text = @"室外";
        self.outdoorPMTitle.textColor = [UIColor whiteColor];
        self.outdoorPMTitle.font = [UIFont systemFontOfSize:12];
        self.outdoorPMTitle.textAlignment = NSTextAlignmentRight;
        [topView addSubview:self.outdoorPMTitle];
        
        self.outdoorIconView = [[UIView alloc] init];
        self.outdoorIconView.backgroundColor = outdoorLineColor;
        [topView addSubview:self.outdoorIconView];
        
        self.indoorCurrentPM = [[UILabel alloc] init];
        self.indoorCurrentPM.textColor = [UIColor whiteColor];
        self.indoorCurrentPM.font = [UIFont systemFontOfSize:14];
        self.indoorCurrentPM.textAlignment = NSTextAlignmentLeft;
        [topView addSubview:self.indoorCurrentPM];
        
        self.indoorPMTitle = [[UILabel alloc] init];
        self.indoorPMTitle.text = @"室内";
        self.indoorPMTitle.textColor = [UIColor whiteColor];
        self.indoorPMTitle.font = [UIFont systemFontOfSize:12];
        self.indoorPMTitle.textAlignment = NSTextAlignmentRight;
        [topView addSubview:self.indoorPMTitle];
        
        self.indoorIconView = [[UIView alloc] init];
        self.indoorIconView.backgroundColor = indoorLineColor;
        [topView addSubview:self.indoorIconView];
        
        topView;
    });
    [self.bgView addSubview:self.topView];
    
    self.lineChart = ({
        // line chart
        PNLineChart *lineChart = [[PNLineChart alloc] init];
        lineChart.backgroundColor = [UIColor clearColor];
        lineChart.delegate = self;
        lineChart.chartMarginRight = 20;
        
        lineChart.yLabelColor = [UIColor whiteColor];
        lineChart.yLabelFont = [UIFont systemFontOfSize:10.0];
        lineChart.xLabelColor = [UIColor whiteColor];
        lineChart.xLabelFont = [UIFont systemFontOfSize:10.0];
        
        lineChart.axisWidth = onePixel;
        lineChart.axisColor = [[UIColor whiteColor] colorWithAlphaComponent:0.15];
        lineChart.yGridLinesColor = [[UIColor whiteColor] colorWithAlphaComponent:0.15];
        lineChart.xGridLinesColor = [[UIColor whiteColor] colorWithAlphaComponent:0.15];
        
        // 线1
        self.indoorLineChartData = [PNLineChartData new];
        self.indoorLineChartData.dataTitle = @"室内";
        self.indoorLineChartData.color = indoorLineColor;
//        self.indoorLineChartData.showPointLabel = YES;
//        self.indoorLineChartData.pointLabelColor = [UIColor whiteColor];
        
        // 线2
        self.outdoorLineChartData = [PNLineChartData new];
        self.outdoorLineChartData.dataTitle = @"室外";
        self.outdoorLineChartData.color = outdoorLineColor;
//        self.outdoorLineChartData.showPointLabel = YES;
//        self.outdoorLineChartData.pointLabelColor = [UIColor whiteColor];
        
        lineChart.chartData = @[self.indoorLineChartData, self.outdoorLineChartData];
        lineChart;
    });
    
    [self.lineChart strokeChart];
    [self.bgView addSubview:self.lineChart];
}

#pragma mark - PNChartDelegate

- (void)userClickedOnLineChart {
    if ([self.delegate respondsToSelector:@selector(userClickedOnLineChart)]) {
        [self.delegate userClickedOnLineChart];
    }
}

@end
