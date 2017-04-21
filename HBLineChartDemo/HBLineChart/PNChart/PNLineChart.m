//
//  PNLineChart.m
//  PNChartDemo
//
//  Created by kevin on 11/7/13.
//  Copyright (c) 2013年 kevinzhow. All rights reserved.
//

#import "PNLineChart.h"
#import "PNColor.h"
#import "PNChartLabel.h"
#import "PNLineChartData.h"
#import "PNLineChartDataItem.h"

@interface PNLineChart ()

// 每一条线（PNLineChartDate）对应的图层（CAShapeLayer）数组
@property(nonatomic) NSMutableArray<NSMutableArray<CAShapeLayer *> *> *chartLineArray;
// 每一条线（PNLineChartDate）上的点 对应的图层（CAShapeLayer）数组
@property(nonatomic) NSMutableArray<CAShapeLayer *> *chartPointArray;

// Array of line path, one for each line.
@property(nonatomic) NSMutableArray *chartPath;
// Array of point path, one for each line
@property(nonatomic) NSMutableArray *pointPath;
// Array of start and end points of each line path, one for each line
@property(nonatomic) NSMutableArray *endPointsOfPath;

// will be set to nil， if _displayAnimation is NO
@property(nonatomic) CABasicAnimation *pathAnimation;

// display grade
@property(nonatomic) NSMutableArray *gradeStringPaths;
// Array of colors when drawing each line. if chartData. rangeColors is set then different colors will be
@property(nonatomic) NSMutableArray *progressLinePathsColors;
@end

@implementation PNLineChart

@synthesize pathAnimation = _pathAnimation;

#pragma mark - initialization

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupDefaultValues];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupDefaultValues];
    }
    return self;
}

- (void)setupDefaultValues {
    // Initialization code
    self.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds = YES;
    self.userInteractionEnabled = YES;
    
    self.chartLineArray = [NSMutableArray new];
    self.pathPoints = [[NSMutableArray alloc] init];
    self.endPointsOfPath = [[NSMutableArray alloc] init];
    
    self.displayAnimated = YES;
    self.showLabel = YES;
    self.yLabelHeight = [[[[PNChartLabel alloc] init] font] pointSize];
    self.yLabelFormat = @"%1.f";
    
    // y轴取值范围
    self.yValueMax = self.yValueMin = -FLT_MAX;
    
    // 格子线
    self.showYGridLines = YES;
    self.showXGridLines = YES;
    self.yGridLinesColor = [UIColor lightGrayColor];
    self.xGridLinesColor = [UIColor lightGrayColor];
    
    self.axisOffset = 5;
    
    self.chartMarginLeft = 20.0;
    self.chartMarginRight = 20.0;
    self.chartMarginTop = 20.0;
    self.chartMarginBottom = 20.0;
    
    // 坐标轴
    self.showCoordinateAxis = YES;
    self.axisColor = [UIColor lightGrayColor];
    self.axisWidth = 0.5f;
    
    // 是否显示弧形曲线
    self.showSmoothLines = NO;
    
    // TODO: 覆盖了touch事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userClicked)];
    [self addGestureRecognizer:tap];
}

- (void)userClicked {
    if ([self.delegate respondsToSelector:@selector(userClickedOnLineChart)]) {
        [self.delegate userClickedOnLineChart];
    }
}

- (CGRect)chartDrawRect {
    CGFloat x, y, w, h;
    x = self.chartMarginLeft;
    y = self.chartMarginTop;
    w = self.frame.size.width - self.chartMarginLeft - self.chartMarginRight;
    h = self.frame.size.height - self.chartMarginTop - self.chartMarginBottom;
    return CGRectMake(x, y, w, h);
}

#pragma mark - yLabels

- (void)setYLabels:(NSArray *)yLabels {
    _yLabels = yLabels;
    if (yLabels.count < 2) {
        return;
    }
    
    CGFloat yLabelHeight;
    if (_showLabel) {
        yLabelHeight = (CGFloat)self.chartDrawRect.size.height / (yLabels.count - 1);
    } else {
        yLabelHeight = (CGFloat)(self.frame.size.height) / yLabels.count;
    }

    [self setYLabels:yLabels withHeight:yLabelHeight];
}

- (void)setYLabels:(NSArray *)yLabels withHeight:(CGFloat)height {
    _yLabelHeight = height;
    
    if (_yChartLabels) {
        for (PNChartLabel *label in _yChartLabels) {
            [label removeFromSuperview];
        }
    } else {
        _yChartLabels = [NSMutableArray new];
    }

    NSString *labelText;
    
    if (_showLabel) {
        for (int i = 0; i < yLabels.count; i++) {
            labelText = yLabels[i];

            // Y轴坐标数字 y值
            CGFloat y = (self.chartDrawRect.origin.y + self.chartDrawRect.size.height - (_yLabelHeight / 2.0)) - (i * _yLabelHeight);
            y = isnan(y) ? 0 : y;

            PNChartLabel *label = [[PNChartLabel alloc] initWithFrame:CGRectMake(0, y, self.chartDrawRect.origin.x - _axisOffset, _yLabelHeight)];
            
            [label setTextAlignment:NSTextAlignmentRight];
            label.text = labelText;
            [self setCustomStyleForYLabel:label];
            [self addSubview:label];
            [_yChartLabels addObject:label];
        }
    }
}

- (void)setCustomStyleForYLabel:(UILabel *)label {
    if (_yLabelFont) {
        label.font = _yLabelFont;
    }
    
    if (_yLabelColor) {
        label.textColor = _yLabelColor;
    }
}

#pragma mark - xLabels

- (void)setXLabels:(NSArray *)xLabels {
    _xLabels = xLabels;
    if (xLabels.count < 2) {
        return;
    }
    
    CGFloat xLabelWidth;

    if (_showLabel) {
        xLabelWidth = (CGFloat)self.chartDrawRect.size.width / (xLabels.count - 1);
    } else {
        xLabelWidth = (self.frame.size.width - _chartMarginLeft - _chartMarginRight) / [xLabels count];
    }

    return [self setXLabels:xLabels withWidth:xLabelWidth];
}

- (void)setXLabels:(NSArray *)xLabels withWidth:(CGFloat)width {
    _xLabelWidth = width;
    
    if (_xChartLabels) {
        for (PNChartLabel *label in _xChartLabels) {
            [label removeFromSuperview];
        }
    } else {
        _xChartLabels = [NSMutableArray new];
    }

    NSString *labelText;

    if (_showLabel) {
        for (NSUInteger i = 0; i < xLabels.count; i++) {
            labelText = xLabels[i];

            CGFloat x = (self.chartDrawRect.origin.x - (_xLabelWidth / 2.0)) + (i * _xLabelWidth);
            CGFloat y = self.chartDrawRect.origin.y + self.chartDrawRect.size.height + self.axisOffset;

            x = isnan(x) ? 0 : x;
            y = isnan(y) ? 0 : y;
            
            PNChartLabel *label = [[PNChartLabel alloc] initWithFrame:CGRectMake(x, y, _xLabelWidth, _chartMarginBottom - self.axisOffset)];
            
            [label setTextAlignment:NSTextAlignmentCenter];
            label.text = i == 0 ? @"" : labelText;
            [self setCustomStyleForXLabel:label];
            [self addSubview:label];
            [_xChartLabels addObject:label];
        }
    }
}

- (void)setCustomStyleForXLabel:(UILabel *)label {
    if (_xLabelFont) {
        label.font = _xLabelFont;
    }
    if (_xLabelColor) {
        label.textColor = _xLabelColor;
    }
}

#pragma mark - Touch at point

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(userClickedOnLinePoint:lineIndex:)]) {
        [self touchPoint:touches withEvent:event];
    }
    
    if ([self.delegate respondsToSelector:@selector(userClickedOnLineKeyPoint:lineIndex:pointIndex:)]) {
        [self touchKeyPoint:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(userClickedOnLinePoint:lineIndex:)]) {
        [self touchPoint:touches withEvent:event];
    }
    
    if ([self.delegate respondsToSelector:@selector(userClickedOnLineKeyPoint:lineIndex:pointIndex:)]) {
        [self touchKeyPoint:touches withEvent:event];
    }
}

- (void)touchPoint:(NSSet *)touches withEvent:(UIEvent *)event {
    // 获取用户点击的point
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    for (NSUInteger p = 0; p < _pathPoints.count; p++) {
        NSArray *linePointsArray = _endPointsOfPath[p];

        if (linePointsArray.count <= 0) {
            continue;
        }
        for (NSUInteger i = 0; i < linePointsArray.count - 1; i += 2) {
            CGPoint p1 = [linePointsArray[i] CGPointValue];
            CGPoint p2 = [linePointsArray[i + 1] CGPointValue];

            // 从点到线的最近距离
            /*
             直线方程式 l: Ax0+By0+C = 0
             ps: A = y2 - y1
                 B = x1 - x2
                 c = x2 * y1 - x1 * y2;
             
             点P(x0, y0)到直线l的距离 公式：|Ax0+By0+C| / √(A²+B²)
             √(A²+B²) = 直线长度
             函数: fabs(double) 取绝对值，hypot(double, double) 已知直角三角形两边长 求斜边长
            */
//            float distance = (float)fabs(((p2.x - p1.x) * (touchPoint.y - p1.y)) - ((p1.x - touchPoint.x) * (p1.y - p2.y)));
            double distance = fabs((p2.y - p1.y) * touchPoint.x + (p1.x - p2.x) * touchPoint.y + ((p2.x * p1.y) -(p1.x * p2.y)));
            distance = distance / hypot(p2.y - p1.y, p1.x - p2.x);

            // 注意，多线段查找，计算点到线的距离时，会有其他线段的延迟线的因素，并不准确，所以一定还要判断点是否在当前线段范围内
            BOOL dp1 = hypot(touchPoint.y - p1.y, p1.x - touchPoint.x) < hypot(p2.y - p1.y, p1.x - p2.x);
            BOOL dp2 = hypot(touchPoint.y - p2.y, p2.x - touchPoint.x) < hypot(p2.y - p1.y, p1.x - p2.x);
            if (distance <= 5.0 && dp1 && dp2) {
                // 点击位置距离线距离小于5， 遍历找出这跳线
                NSUInteger lineIndex = 0;
                for (NSArray<UIBezierPath *> *paths in _chartPath) {
                    for (UIBezierPath *path in paths) {
                        BOOL pointContainsPath = (CGPathContainsPoint(path.CGPath, NULL, p1, NO) && CGPathContainsPoint(path.CGPath, NULL, p2, NO));
                        if (pointContainsPath) {
                            [self.delegate userClickedOnLinePoint:touchPoint lineIndex:lineIndex];
                            return;
                        }
                    }
                    lineIndex++;
                }
            }
        }
    }
}

- (void)touchKeyPoint:(NSSet *)touches withEvent:(UIEvent *)event {
    // 获取用户点击的point
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];

    for (NSUInteger p = 0; p < _pathPoints.count; p++) {
        NSArray *linePointsArray = _pathPoints[p];
        
        if (linePointsArray.count <= 0) {
            continue;
        }
        for (NSUInteger i = 0; i < linePointsArray.count - 1; i += 1) {
            CGPoint p1 = [linePointsArray[i] CGPointValue];
            CGPoint p2 = [linePointsArray[i + 1] CGPointValue];

            // 点到点的距离
            double distanceToP1 = hypot(touchPoint.x - p1.x, touchPoint.y - p1.y);
            double distanceToP2 = hypot(touchPoint.x - p2.x, touchPoint.y - p2.y);

            float distance = MIN(distanceToP1, distanceToP2);

            if (distance <= 5.0) {
                [self.delegate userClickedOnLineKeyPoint:touchPoint
                                               lineIndex:p
                                              pointIndex:(distance == distanceToP2 ? i + 1 : i)];
                return;
            }
        }
    }
}

#pragma mark - Draw Chart

/**
 *  开始画图，要删除之前的，再画新的
 */
- (void)strokeChart {
    // 找出y轴最大最小值，并计算出y轴label
    [self setupYAxis];
    
    // 删除所有形状图层，然后再添加新的
    [self removeLayers];
    
    // Cavan height and width needs to be set before
    // setNeedsDisplay is invoked because setNeedsDisplay
    // will invoke drawRect and if Cavan dimensions is not
    // set the chart will be misplaced
    [self recreatePointLayers];
    
    if (self.showLabel) {
        self.chartMarginLeft = 25;
    } else {
        self.chartMarginLeft = 20;
    }
    
    [self prepareYLabelsWithData:_chartData];

    _chartPath = [[NSMutableArray alloc] init];
    _pointPath = [[NSMutableArray alloc] init];
    _gradeStringPaths = [NSMutableArray array];
    _progressLinePathsColors = [[NSMutableArray alloc] init];

    [self calculateChartPath:_chartPath
               andPointsPath:_pointPath
            andPathKeyPoints:_pathPoints
       andPathStartEndPoints:_endPointsOfPath
  andProgressLinePathsColors:_progressLinePathsColors];
    
    [self populateChartLines];
    
    // Draw each line
    for (NSUInteger lineIndex = 0; lineIndex < self.chartData.count; lineIndex++) {
        PNLineChartData *chartData = self.chartData[lineIndex];
        NSArray<CAShapeLayer *> *chartLines = self.chartLineArray[lineIndex];
        CAShapeLayer *pointLayer = (CAShapeLayer *) self.chartPointArray[lineIndex];
        UIGraphicsBeginImageContext(self.frame.size);
        if (chartData.inflexionPointColor) {
            pointLayer.strokeColor = [[chartData.inflexionPointColor
                    colorWithAlphaComponent:chartData.alpha] CGColor];
        } else {
            pointLayer.strokeColor = [PNGreen CGColor];
        }
        // setup the color of the chart line
        NSArray<UIBezierPath *> *progressLines = _chartPath[lineIndex];
        UIBezierPath *pointPath = _pointPath[lineIndex];

        pointLayer.path = pointPath.CGPath;

        [CATransaction begin];
        for (NSUInteger index = 0; index < progressLines.count; index++) {
            CAShapeLayer *chartLine = chartLines[index];
            //chartLine strokeColor is already set. no need to override here
            [chartLine addAnimation:self.pathAnimation forKey:@"strokeEndAnimation"];
            chartLine.strokeEnd = 1.0;
        }

        // if you want cancel the point animation, comment this code, the point will show immediately
        if (chartData.inflexionPointStyle != PNLineChartPointStyleNone) {
            [pointLayer addAnimation:self.pathAnimation forKey:@"strokeEndAnimation"];
        }

        [CATransaction commit];

        NSMutableArray *textLayerArray = self.gradeStringPaths[lineIndex];
        for (CATextLayer *textLayer in textLayerArray) {
            CABasicAnimation *fadeAnimation = [self fadeAnimation];
            [textLayer addAnimation:fadeAnimation forKey:nil];
        }

        UIGraphicsEndImageContext();
    }
    [self setNeedsDisplay];
    
    if (self.showLabel) {
        self.yLabels = self.yLabels;
        self.xLabels = self.xLabels;
    }
}

- (void)populateChartLines {
    for (NSUInteger lineIndex = 0; lineIndex < self.chartData.count; lineIndex++) {
        NSArray<UIBezierPath *> *progressLines = self.chartPath[lineIndex];
        // each chart line can be divided into multiple paths because
        // we need ot draw each path with different color
        // if there is not rangeColors then there is only one progressLinePath per chart
        NSArray<UIColor *> *progressLineColors = self.progressLinePathsColors[lineIndex];
        [self.chartLineArray[lineIndex] removeAllObjects];
        NSUInteger progressLineIndex = 0;;
        for (UIBezierPath *progressLinePath in progressLines) {
            PNLineChartData *chartData = self.chartData[lineIndex];
            CAShapeLayer *chartLine = [CAShapeLayer layer];
            chartLine.lineCap = kCALineCapButt;
            chartLine.lineJoin = kCALineJoinRound;
            chartLine.fillColor = self.backgroundColor.CGColor;
            chartLine.lineWidth = chartData.lineWidth;
            chartLine.path = progressLinePath.CGPath;
            chartLine.strokeStart = 0.0;
            chartLine.strokeEnd = 0.0;
            chartLine.strokeColor = progressLineColors[progressLineIndex].CGColor;
            [self.layer addSublayer:chartLine];
            [self.chartLineArray[lineIndex] addObject:chartLine];
            progressLineIndex++;
        }
    }
}

- (void)calculateChartPath:(NSMutableArray *)chartPath
             andPointsPath:(NSMutableArray *)pointsPath
          andPathKeyPoints:(NSMutableArray *)pathPoints
     andPathStartEndPoints:(NSMutableArray *)pointsOfPath
andProgressLinePathsColors:(NSMutableArray *)progressLinePathsColors {
    
    // Draw each line
    for (NSUInteger lineIndex = 0; lineIndex < self.chartData.count; lineIndex++) {
        PNLineChartData *chartData = self.chartData[lineIndex];

//        CGFloat yValue;
        NSMutableArray<UIBezierPath *> *progressLines = [NSMutableArray new];
        NSMutableArray<UIColor *> *progressLineColors = [NSMutableArray new];

        UIBezierPath *pointPath = [UIBezierPath bezierPath];
        [pointPath setLineJoinStyle:kCGLineJoinRound];
        [pointPath setLineCapStyle:kCGLineCapButt];
        
        [chartPath insertObject:progressLines atIndex:lineIndex];
        [pointsPath insertObject:pointPath atIndex:lineIndex];
        [progressLinePathsColors insertObject:progressLineColors atIndex:lineIndex];
        
        
        NSMutableArray *gradePathArray = [NSMutableArray array];
        [self.gradeStringPaths addObject:gradePathArray];
        
        NSMutableArray *linePointsArray = [[NSMutableArray alloc] init];
        NSMutableArray *lineStartEndPointsArray = [[NSMutableArray alloc] init];
        CGFloat last_x = 0.0;
        CGFloat last_y = 0.0;
        NSMutableArray<NSDictionary<NSString *, NSValue *> *> *progressLinePaths = [NSMutableArray new];
        
        UIColor *defaultColor = chartData.color != nil ? chartData.color : [UIColor greenColor];
        CGFloat inflexionWidth = chartData.inflexionPointWidth;
        
        for (NSUInteger i = 0; i < self.xLabels.count; i++) {
            NSString *key = self.xLabels[i];
            
            NSValue *from = nil;
            NSValue *to = nil;

//            yValue = chartData.getData(key).y;
            PNLineChartDataItem *item = chartData.getData(key);
            if (item == nil) {
                continue;
            }
            
            CGFloat x = i * (self.chartDrawRect.size.width / (self.xLabels.count - 1)) + self.chartDrawRect.origin.x;
            CGFloat y = [self yValuePositionInLineChart:item.y];

            // 折点样式 Circular(圆圈)
            if (chartData.inflexionPointStyle == PNLineChartPointStyleCircle) {
                
                CGRect circleRect = CGRectMake(x - inflexionWidth / 2, y - inflexionWidth / 2, inflexionWidth, inflexionWidth);
                CGPoint circleCenter = CGPointMake(circleRect.origin.x + (circleRect.size.width / 2), circleRect.origin.y + (circleRect.size.height / 2));

                [pointPath moveToPoint:CGPointMake(circleCenter.x + (inflexionWidth / 2), circleCenter.y)];
                [pointPath addArcWithCenter:circleCenter radius:inflexionWidth / 2 startAngle:0 endAngle:(CGFloat) (2 * M_PI) clockwise:YES];

                // 折点处的数值文字
                if (chartData.showPointLabel) {
                    [gradePathArray addObject:[self createPointLabelFor:item.rawY pointCenter:circleCenter width:inflexionWidth withChartData:chartData]];
                }

                if (i > 0 && (last_y > 0 && last_x > 0)) {
                    // 计算三角形线的点
                    float distance = (float) sqrt(pow(x - last_x, 2) + pow(y - last_y, 2));
                    float last_x1 = last_x + (inflexionWidth / 2) / distance * (x - last_x);
                    float last_y1 = last_y + (inflexionWidth / 2) / distance * (y - last_y);
                    float x1 = x - (inflexionWidth / 2) / distance * (x - last_x);
                    float y1 = y - (inflexionWidth / 2) / distance * (y - last_y);
                    from = [NSValue valueWithCGPoint:CGPointMake(last_x1, last_y1)];
                    to = [NSValue valueWithCGPoint:CGPointMake(x1, y1)];
                }
                
            } else if (chartData.inflexionPointStyle == PNLineChartPointStyleSquare) {
                // 折点样式 Square(正方形)
                CGRect squareRect = CGRectMake(x - inflexionWidth / 2, y - inflexionWidth / 2, inflexionWidth, inflexionWidth);
                CGPoint squareCenter = CGPointMake(squareRect.origin.x + (squareRect.size.width / 2), squareRect.origin.y + (squareRect.size.height / 2));

                [pointPath moveToPoint:CGPointMake(squareCenter.x - (inflexionWidth / 2), squareCenter.y - (inflexionWidth / 2))];
                [pointPath addLineToPoint:CGPointMake(squareCenter.x + (inflexionWidth / 2), squareCenter.y - (inflexionWidth / 2))];
                [pointPath addLineToPoint:CGPointMake(squareCenter.x + (inflexionWidth / 2), squareCenter.y + (inflexionWidth / 2))];
                [pointPath addLineToPoint:CGPointMake(squareCenter.x - (inflexionWidth / 2), squareCenter.y + (inflexionWidth / 2))];
                [pointPath closePath];

                // 折点处的数值文字
                if (chartData.showPointLabel) {
                    [gradePathArray addObject:[self createPointLabelFor:item.rawY pointCenter:squareCenter width:inflexionWidth withChartData:chartData]];
                }

                if (i > 0 && (last_y > 0 && last_x > 0)) {
                    // 计算正方形线的点
                    float distance = (float) sqrt(pow(x - last_x, 2) + pow(y - last_y, 2));
                    float last_x1 = last_x + (inflexionWidth / 2);
                    float last_y1 = last_y + (inflexionWidth / 2) / distance * (y - last_y);
                    float x1 = x - (inflexionWidth / 2);
                    float y1 = y - (inflexionWidth / 2) / distance * (y - last_y);
                    from = [NSValue valueWithCGPoint:CGPointMake(last_x1, last_y1)];
                    to = [NSValue valueWithCGPoint:CGPointMake(x1, y1)];
                }
                
            } else if (chartData.inflexionPointStyle == PNLineChartPointStyleTriangle) {
                // 折点样式 Triangle(三角形)
                CGRect squareRect = CGRectMake(x - inflexionWidth / 2, y - inflexionWidth / 2, inflexionWidth, inflexionWidth);

                CGPoint startPoint = CGPointMake(squareRect.origin.x, squareRect.origin.y + squareRect.size.height);
                CGPoint endPoint = CGPointMake(squareRect.origin.x + (squareRect.size.width / 2), squareRect.origin.y);
                CGPoint middlePoint = CGPointMake(squareRect.origin.x + (squareRect.size.width), squareRect.origin.y + squareRect.size.height);

                [pointPath moveToPoint:startPoint];
                [pointPath addLineToPoint:middlePoint];
                [pointPath addLineToPoint:endPoint];
                [pointPath closePath];

                // 显示折点处数值文字
                if (chartData.showPointLabel) {
                    [gradePathArray addObject:[self createPointLabelFor:item.rawY pointCenter:middlePoint width:inflexionWidth withChartData:chartData]];
                }

                if (i > 0 && (last_y > 0 && last_x > 0)) {
                    // 计算三角形的点
                    float distance = (float) (sqrt(pow(x - last_x, 2) + pow(y - last_y, 2)) * 1.4);
                    float last_x1 = last_x + (inflexionWidth / 2) / distance * (x - last_x);
                    float last_y1 = last_y + (inflexionWidth / 2) / distance * (y - last_y);
                    float x1 = x - (inflexionWidth / 2) / distance * (x - last_x);
                    float y1 = y - (inflexionWidth / 2) / distance * (y - last_y);
                    from = [NSValue valueWithCGPoint:CGPointMake(last_x1, last_y1)];
                    to = [NSValue valueWithCGPoint:CGPointMake(x1, y1)];
                }
                
            } else {
                // 折点没有样式
                CGPoint pointCenter = CGPointMake(x, y);
                
                // 折点处的数值文字
                if (chartData.showPointLabel) {
                    [gradePathArray addObject:[self createPointLabelFor:item.rawY pointCenter:pointCenter width:inflexionWidth withChartData:chartData]];
                }
                
                if (i > 0 && (last_y > 0 && last_x > 0)) {
                    from = [NSValue valueWithCGPoint:CGPointMake(last_x, last_y)];
                    to = [NSValue valueWithCGPoint:CGPointMake(x, y)];
                }
            }
            
            if (from != nil && to != nil) {
                [progressLinePaths addObject:@{@"from": from,  @"to":to}];
                [lineStartEndPointsArray addObject:from];
                [lineStartEndPointsArray addObject:to];
            }
            
            [linePointsArray addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
            last_x = x;
            last_y = y;
        }

        [pointsOfPath addObject:[lineStartEndPointsArray copy]];
        [pathPoints addObject:[linePointsArray copy]];
        // if rangeColors is not nil then it means we need to draw the chart
        // with different colors. colorRangesBetweenP1.. function takes care of
        // partitioning the p1->p2 into segments from which we can create UIBezierPath
        if (self.showSmoothLines && chartData.itemCount >= 4) {
            for (NSDictionary<NSString *, NSValue *> *item in progressLinePaths) {
                NSArray<NSDictionary *> *calculatedRanges = [self colorRangesBetweenP1:[item[@"from"] CGPointValue]
                                                                                    P2:[item[@"to"] CGPointValue]
                                                                           rangeColors:chartData.rangeColors
                                                                          defaultColor:defaultColor];
                
                for (NSDictionary *range in calculatedRanges) {
                    UIBezierPath *currentProgressLine = [UIBezierPath bezierPath];
                    CGPoint segmentP1 = [range[@"from"] CGPointValue];
                    CGPoint segmentP2 = [range[@"to"] CGPointValue];
                    [currentProgressLine moveToPoint:segmentP1];
                    CGPoint midPoint = [PNLineChart midPointBetweenPoint1:segmentP1 andPoint2:segmentP2];
                    [currentProgressLine addQuadCurveToPoint:midPoint
                                                controlPoint:[PNLineChart controlPointBetweenPoint1:midPoint andPoint2:segmentP1]];
                    [currentProgressLine addQuadCurveToPoint:segmentP2
                                                controlPoint:[PNLineChart controlPointBetweenPoint1:midPoint andPoint2:segmentP2]];
                    [progressLines addObject:currentProgressLine];
                    [progressLineColors addObject:range[@"color"]];
                }
            }
        } else {
            for (NSDictionary<NSString *, NSValue *> *item in progressLinePaths) {
                NSArray<NSDictionary *> *calculatedRanges = [self colorRangesBetweenP1:[item[@"from"] CGPointValue]
                                                                                    P2:[item[@"to"] CGPointValue]
                                                                           rangeColors:chartData.rangeColors
                                                                          defaultColor:defaultColor];
                
                for (NSDictionary *range in calculatedRanges) {
                    UIBezierPath *currentProgressLine = [UIBezierPath bezierPath];
                    [currentProgressLine moveToPoint:[range[@"from"] CGPointValue]];
                    [currentProgressLine addLineToPoint:[range[@"to"] CGPointValue]];
                    [progressLines addObject:currentProgressLine];
                    [progressLineColors addObject:range[@"color"]];
                }
            }
        }
    }
}

#pragma mark - Set Chart Data

- (void)setChartData:(NSArray *)data {
    if (data != _chartData) {
        _chartData = data;
    }
}

- (void)setupYAxis {
    self.yFixedValueMax = CGFLOAT_MIN;
    self.yFixedValueMin = CGFLOAT_MAX;
    self.yLabels = [NSArray array];
    
    // 找出最大最小值
    for (PNLineChartData *d in self.chartData) {
        for (int i = 0; i < d.itemCount; i++) {
            PNLineChartDataItem *yItem = d.getData(d.datas.allKeys[i]); // TODO:
            self.yFixedValueMin = yItem.y < self.yFixedValueMin ? yItem.y : self.yFixedValueMin;
            self.yFixedValueMax = yItem.y > self.yFixedValueMax ? yItem.y : self.yFixedValueMax;
        }
    }
    
    if (self.yFixedValueMin == CGFLOAT_MAX && self.yFixedValueMax == CGFLOAT_MIN) {
        return;
    }
    
    // 最小值向下取整十
    int min = floor(self.yFixedValueMin);
    self.yFixedValueMin = min - (min % 10);
    // 最大值向上取整十
    int max = ceil(self.yFixedValueMax);
    self.yFixedValueMax = max + 10 - (max % 10);
    
    NSInteger rowCount = 6;
    if (self.yFixedValueMax - self.yFixedValueMin != 0) {
        NSInteger numberInterval = (self.yFixedValueMax - self.yFixedValueMin) / (rowCount - 1); // 行数 - 1 = 间隔
        NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:rowCount];
        for (int i = 0; i < rowCount; i++) {
            NSString *yLabel = [NSString stringWithFormat:@"%ld", (NSInteger)self.yFixedValueMin + i * numberInterval];
            [tempArr addObject:yLabel];
        }
        self.yLabels = [NSArray arrayWithArray:tempArr];
    } else {
        self.yFixedValueMin -= 5;
        self.yFixedValueMax += 5;
        self.yLabels = @[[NSString stringWithFormat:@"%ld", (NSInteger)self.yFixedValueMin],
                         [NSString stringWithFormat:@"%ld", (NSInteger)((self.yFixedValueMax - self.yFixedValueMin) / 2 + self.yFixedValueMin)],
                         [NSString stringWithFormat:@"%ld", (NSInteger)self.yFixedValueMax]];
    }
}

- (void)removeLayers {
    for (NSArray<CALayer *> *layers in self.chartLineArray) {
        for (CALayer *layer in layers) {
            [layer removeFromSuperlayer];
        }
    }
    
    for (CALayer *layer in self.chartPointArray) {
        [layer removeFromSuperlayer];
    }
    
    for (NSArray<CALayer *> *paths in self.gradeStringPaths) {
        for (CALayer *layer in paths) {
            [layer removeFromSuperlayer];
        }
    }
    
    self.chartLineArray = [NSMutableArray arrayWithCapacity:_chartData.count];
    self.chartPointArray = [NSMutableArray arrayWithCapacity:_chartData.count];
}

- (void)recreatePointLayers {
    for (PNLineChartData *chartData in _chartData) {
        // create as many chart line layers as there are data-lines
        [self.chartLineArray addObject:[NSMutableArray new]];
        
        // create point
        CAShapeLayer *pointLayer = [CAShapeLayer layer];
        pointLayer.strokeColor = [[chartData.color colorWithAlphaComponent:chartData.alpha] CGColor];
        pointLayer.lineCap = kCALineCapRound;
        pointLayer.lineJoin = kCALineJoinBevel;
        pointLayer.fillColor = nil;
        pointLayer.lineWidth = chartData.lineWidth;
        [self.layer addSublayer:pointLayer];
        [self.chartPointArray addObject:pointLayer];
    }
}

// 计算y轴的取值范围  最大最小值
- (void)prepareYLabelsWithData:(NSArray *)data {
    CGFloat yMax = self.yFixedValueMax;
    CGFloat yMin = self.yFixedValueMin;
//    NSMutableArray *yLabelsArray = [NSMutableArray new];

    for (PNLineChartData *d in data) {
        // create as many chart line layers as there are data-lines
        for (NSUInteger i = 0; i < d.itemCount; i++) {
            CGFloat yValue = d.getData(d.datas.allKeys[i]).y;
//            [yLabelsArray addObject:[NSString stringWithFormat:@"%f", yValue]];
            yMax = fmaxf(yMax, yValue);
            yMin = fminf(yMin, yValue);
        }
    }
    
//    if (_yValueMin == -FLT_MAX) {
        _yValueMin = yMin;
//    }
    
//    if (_yValueMax == -FLT_MAX) {
        _yValueMax = yMax;
//    }
}

#define IOS7_OR_LATER [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0

- (void)drawRect:(CGRect)rect {
    if (self.isShowCoordinateAxis) {

        CGContextRef ctx = UIGraphicsGetCurrentContext();
        UIGraphicsPopContext();
        UIGraphicsPushContext(ctx);
        
        CGContextSetLineWidth(ctx, self.axisWidth);
        CGContextSetStrokeColorWithColor(ctx, [self.axisColor CGColor]);

        // draw coordinate axis
        CGContextMoveToPoint(ctx, self.chartDrawRect.origin.x, self.chartDrawRect.origin.y);
        CGContextAddLineToPoint(ctx, self.chartDrawRect.origin.x, self.chartDrawRect.origin.y + self.chartDrawRect.size.height);
        CGContextAddLineToPoint(ctx, self.chartDrawRect.origin.x + self.chartDrawRect.size.width, self.chartDrawRect.origin.y + self.chartDrawRect.size.height);
        CGContextAddLineToPoint(ctx, self.chartDrawRect.origin.x + self.chartDrawRect.size.width, self.chartDrawRect.origin.y);
        CGContextStrokePath(ctx);

        // 坐标系箭头
//        // draw y axis arrow
//        CGContextMoveToPoint(ctx, _chartMarginBottom + yAxisOffset - 3, 6);
//        CGContextAddLineToPoint(ctx, _chartMarginBottom + yAxisOffset, 0);
//        CGContextAddLineToPoint(ctx, _chartMarginBottom + yAxisOffset + 3, 6);
//        CGContextStrokePath(ctx);
//
//        // draw x axis arrow
//        CGContextMoveToPoint(ctx, xAxisWidth - 6, yAxisHeight - 3);
//        CGContextAddLineToPoint(ctx, xAxisWidth, yAxisHeight);
//        CGContextAddLineToPoint(ctx, xAxisWidth - 6, yAxisHeight + 3);
//        CGContextStrokePath(ctx);

        
        // x、y主坐标轴上的标签
        // draw y unit
        UIFont *font = [UIFont systemFontOfSize:11];
        if ([self.yUnit length]) {
            CGFloat height = [PNLineChart sizeOfString:self.yUnit withWidth:30.f font:font].height;
            CGRect drawRect = CGRectMake(_chartMarginLeft + 10 + 5, 0, 30.f, height);
            [self drawTextInContext:ctx text:self.yUnit inRect:drawRect font:font color:self.yLabelColor];
        }

        // draw x unit
        if ([self.xUnit length]) {
            CGFloat height = [PNLineChart sizeOfString:self.xUnit withWidth:30.f font:font].height;
            CGRect drawRect = CGRectMake(CGRectGetWidth(rect) - _chartMarginLeft + 5, _chartMarginBottom + self.chartDrawRect.size.height - height / 2, 25.f, height);
            [self drawTextInContext:ctx text:self.xUnit inRect:drawRect font:font color:self.xLabelColor];
        }
    }
    
    if (self.showYGridLines) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGPoint point;
        CGFloat yStepHeight = (CGFloat)self.chartDrawRect.size.height / (_yLabels.count - 1);
        if (self.yGridLinesColor) {
            CGContextSetStrokeColorWithColor(ctx, self.yGridLinesColor.CGColor);
        } else {
            CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
        }
        for (NSUInteger i = 1; i < _yLabels.count; i++) {
            point = CGPointMake(self.chartDrawRect.origin.x, (self.chartDrawRect.origin.y + i * yStepHeight));
            CGContextMoveToPoint(ctx, point.x, point.y);
            // add dotted style grid
//            CGFloat dash[] = {6, 5};
            // dot diameter is 20 points
            CGContextSetLineWidth(ctx, self.axisWidth);
//            CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 0.0, 0.2);
            CGContextSetLineCap(ctx, kCGLineCapRound);
//            CGContextSetLineDash(ctx, 0.0, dash, 2);
            CGContextAddLineToPoint(ctx, self.chartDrawRect.origin.x + self.chartDrawRect.size.width, point.y);
            CGContextStrokePath(ctx);
        }
    }
    
    if (self.showXGridLines) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGPoint point;
        CGFloat xStepHeight = self.chartDrawRect.size.width / (self.xLabels.count - 1);
        if (self.xGridLinesColor) {
            CGContextSetStrokeColorWithColor(ctx, self.xGridLinesColor.CGColor);
        } else {
            CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
        }
        for (NSUInteger i = 0; i < self.xLabels.count; i++) {
            point = CGPointMake(self.chartDrawRect.origin.x + i * xStepHeight, (self.chartDrawRect.origin.y + self.chartDrawRect.size.height));
            CGContextMoveToPoint(ctx, point.x, point.y);
            // add dotted style grid
            //            CGFloat dash[] = {6, 5};
            // dot diameter is 20 points
            CGContextSetLineWidth(ctx, self.axisWidth);
//            CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 0.0, 0.2);
            CGContextSetLineCap(ctx, kCGLineCapRound);
            //            CGContextSetLineDash(ctx, 0.0, dash, 2);
            CGContextAddLineToPoint(ctx, point.x, self.chartDrawRect.origin.y);
            CGContextStrokePath(ctx);
        }
    }

    [super drawRect:rect];
}

#pragma mark - private methods

/**
 *  计算曲线yValue对应的图表y
 */
- (CGFloat)yValuePositionInLineChart:(CGFloat)y {
    CGFloat innerGrade;
    if (_yValueMax == _yValueMin) {
        innerGrade = 0.5;
    } else {
        innerGrade = (CGFloat)(y - _yValueMin) / (_yValueMax - _yValueMin);
    }
    
    return (self.chartDrawRect.origin.y + self.chartDrawRect.size.height) - (innerGrade * self.chartDrawRect.size.height);
}

/**
 * return array of segments which represents the color and path
 * for each segments.
 * for instance if p1.y=1 and p2.y=10
 * and rangeColor = use blue for 2<y<3 and red for 4<y<6
 * then this function divides the space between p1 and p2 into three segments
 *  segment #1 : 1-2 : default color
 *  segment #2 : 2-3 : blue
 *  segment #3 : 3-4 : default color
 *  segment #4 : 4-6 : red
 *  segment #5: 6-10 : default color
 *
 *  keep in mind that the rangeColors values are based on the chartData so it needs to
 *  convert those values to coordinates which are valid between yValueMin and yValueMax
 *
 *  in order to find whether there is an overlap between any of the rangeColors and the
 *  p1-p2 it uses NSIntersectionRange to intersect their yValues.
 *
 * @param p1 .
 * @param p2 .
 * @param rangeColors .
 * @param defaultColor .
 * @return .
 */
- (NSArray *)colorRangesBetweenP1:(CGPoint)p1
                               P2:(CGPoint)p2
                      rangeColors:(NSArray<PNLineChartColorRange *> *)rangeColors
                     defaultColor:(UIColor *)defaultColor {
    
    if (rangeColors && rangeColors.count > 0 && p2.x > p1.x) {
        PNLineChartColorRange *colorForRangeInfo = [[rangeColors firstObject] copy];
        NSArray *remainingRanges = nil;
        if (rangeColors.count > 1) {
            remainingRanges = [rangeColors subarrayWithRange:NSMakeRange(1, rangeColors.count - 1)];
        }
        // tRange : convert the rangeColors.range values to value between yValueMin and yValueMax
        CGFloat transformedStart = [self yValuePositionInLineChart:(CGFloat)
                colorForRangeInfo.range.location];
        CGFloat transformedEnd = [self yValuePositionInLineChart:(CGFloat)
                (colorForRangeInfo.range.location + colorForRangeInfo.range.length)];

        NSRange pathRange = NSMakeRange((NSUInteger) fmin(p1.y, p2.y), (NSUInteger) fabs(p2.y - p1.y));
        NSRange tRange = NSMakeRange((NSUInteger) fmin(transformedStart, transformedEnd),
                (NSUInteger) fabs(transformedEnd - transformedStart));
        if (NSIntersectionRange(tRange, pathRange).length > 0) {
            CGPoint partition1EndPoint;
            CGPoint partition2EndPoint;
            NSArray *partition1 = @[];
            NSDictionary *partition2 = nil;
            NSArray *partition3 = @[];
            if (p2.y >= p1.y) {
                partition1EndPoint = CGPointMake([PNLineChart xOfY:(CGFloat) fmax(p1.y, tRange.location)
                                                     betweenPoint1:p1
                                                         andPoint2:p2], (CGFloat) fmax(p1.y, tRange.location));
                partition2EndPoint = CGPointMake([PNLineChart xOfY:(CGFloat) fmin(p2.y, tRange.location + tRange.length)
                                                     betweenPoint1:p1
                                                         andPoint2:p2], (CGFloat) fmin(p2.y, tRange.location + tRange.length));
            } else {
                partition1EndPoint = CGPointMake([PNLineChart xOfY:(CGFloat) fmin(p1.y, tRange.location + tRange.length)
                                                     betweenPoint1:p1
                                                         andPoint2:p2], (CGFloat) fmin(p1.y, tRange.location + tRange.length));
                partition2EndPoint = CGPointMake([PNLineChart xOfY:(CGFloat) fmax(p2.y, tRange.location)
                                                     betweenPoint1:p1
                                                         andPoint2:p2], (CGFloat) fmax(p2.y, tRange.location));
            }
            if (p1.y != partition1EndPoint.y) {
                partition1 = [self colorRangesBetweenP1:p1
                                                     P2:partition1EndPoint
                                            rangeColors:remainingRanges
                                           defaultColor:defaultColor];
            }
            partition2 = @{
                    @"color": colorForRangeInfo.color,
                    @"from": [NSValue valueWithCGPoint:partition1EndPoint],
                    @"to": [NSValue valueWithCGPoint:partition2EndPoint]};
            if (p2.y != partition2EndPoint.y) {
                partition3 = [self colorRangesBetweenP1:partition2EndPoint
                                                     P2:p2
                                            rangeColors:remainingRanges
                                           defaultColor:defaultColor];
            }
            return [[partition1 arrayByAddingObject:partition2] arrayByAddingObjectsFromArray:partition3];
        } else {

            return [self colorRangesBetweenP1:p1
                                           P2:p2
                                  rangeColors:remainingRanges
                                 defaultColor:defaultColor];
        }
    } else {
        return @[@{
                @"color": defaultColor,
                @"from": [NSValue valueWithCGPoint:p1],
                @"to": [NSValue valueWithCGPoint:p2]}];
    }
}

+ (CGFloat)xOfY:(CGFloat)y betweenPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 {
    CGFloat m = (point2.y - point1.y) / (point2.x - point1.x);
    // formulate = y - y1 = m (x - x1) = mx - mx1 -> mx = y - y1 + mx1 ->
    // x = (y - y1 + mx1) / m
    return (y - point1.y + m * point1.x) / m;
}

#pragma mark -

+ (CGPoint)controlPointBetweenPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 {
    CGPoint controlPoint = [self midPointBetweenPoint1:point1 andPoint2:point2];
    CGFloat diffY = abs((int) (point2.y - controlPoint.y));
    if (point1.y < point2.y)
        controlPoint.y += diffY;
    else if (point1.y > point2.y)
        controlPoint.y -= diffY;
    return controlPoint;
}

+ (CGPoint)midPointBetweenPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 {
    return CGPointMake((point1.x + point2.x) / 2, (point1.y + point2.y) / 2);
}

#pragma mark -

/**
 *  显示x、y主坐标轴上的标签
 */
- (void)drawTextInContext:(CGContextRef)ctx text:(NSString *)text inRect:(CGRect)rect font:(UIFont *)font color:(UIColor *)color {
    if (IOS7_OR_LATER) {
        NSMutableParagraphStyle *priceParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        priceParagraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        priceParagraphStyle.alignment = NSTextAlignmentLeft;

        if (color != nil) {
            [text drawInRect:rect
              withAttributes:@{NSParagraphStyleAttributeName: priceParagraphStyle, NSFontAttributeName: font,
                      NSForegroundColorAttributeName: color}];
        } else {
            [text drawInRect:rect
              withAttributes:@{NSParagraphStyleAttributeName: priceParagraphStyle, NSFontAttributeName: font}];
        }
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [text drawInRect:rect
                withFont:font
           lineBreakMode:NSLineBreakByTruncatingTail
               alignment:NSTextAlignmentLeft];
#pragma clang diagnostic pop
    }
}

/**
 *  显示x、y主坐标轴上的标签
 */
+ (CGSize)sizeOfString:(NSString *)text withWidth:(float)width font:(UIFont *)font {
    CGSize size = CGSizeMake(width, MAXFLOAT);
    
    if ([text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSDictionary *tdic = @{NSFontAttributeName: font};
        size = [text boundingRectWithSize:size
                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                               attributes:tdic
                                  context:nil].size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        size = [text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
#pragma clang diagnostic pop
    }
    
    return size;
}

#pragma mark - setter and getter

/**
 *  显示曲线上每个点得具体数字
 */
- (CATextLayer *)createPointLabelFor:(CGFloat)grade pointCenter:(CGPoint)pointCenter width:(CGFloat)width withChartData:(PNLineChartData *)chartData {
    CATextLayer *textLayer = [[CATextLayer alloc] init];
    [textLayer setAlignmentMode:kCAAlignmentCenter];
    [textLayer setForegroundColor:[chartData.pointLabelColor CGColor]];
    [textLayer setBackgroundColor:self.backgroundColor.CGColor];

    if (chartData.pointLabelFont != nil) {
        [textLayer setFont:(__bridge CFTypeRef) (chartData.pointLabelFont)];
        textLayer.fontSize = [chartData.pointLabelFont pointSize];
    }

    CGFloat textHeight = (CGFloat)(textLayer.fontSize * 1.1);
    // FIXME: convert the grade to string and use its length instead of hardcoding 8
    CGFloat w = [[NSString stringWithFormat:chartData.pointLabelFormat, grade]
                 boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, textHeight)
                 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                 attributes:@{NSFontAttributeName:chartData.pointLabelFont}
                 context:nil].size.width;
//    NSLog(@"point width - %f", w);
//    CGFloat textWidth = width * 8;
    CGFloat textWidth = w;
    CGFloat textStartPosY;

    textStartPosY = pointCenter.y - textLayer.fontSize;

    [self.layer addSublayer:textLayer];

    if (chartData.pointLabelFormat != nil) {
        [textLayer setString:[[NSString alloc] initWithFormat:chartData.pointLabelFormat, grade]];
    } else {
        [textLayer setString:[[NSString alloc] initWithFormat:_yLabelFormat, grade]];
    }

    [textLayer setFrame:CGRectMake(0, 0, textWidth, textHeight)];
    [textLayer setPosition:CGPointMake(pointCenter.x, textStartPosY)];
    textLayer.contentsScale = [UIScreen mainScreen].scale;

    return textLayer;
}

- (CABasicAnimation *)fadeAnimation {
    CABasicAnimation *fadeAnimation = nil;
    if (self.displayAnimated) {
        fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeAnimation.fromValue = @0.0F;
        fadeAnimation.toValue = @1.0F;
        fadeAnimation.duration = 2.0;
    }
    return fadeAnimation;
}

- (CABasicAnimation *)pathAnimation {
    if (self.displayAnimated && !_pathAnimation) {
        _pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        _pathAnimation.duration = 1.0;
        _pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        _pathAnimation.fromValue = @0.0f;
        _pathAnimation.toValue = @1.0f;
    }
    if(!self.displayAnimated) {
        _pathAnimation = nil;
    }
    return _pathAnimation;
}

@end
