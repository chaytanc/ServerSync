//
//  HealthBar.m
//  ModelVale
//
//  Created by Chaytan Inman on 7/14/22.
//

#import "HealthBarView.h"

@interface HealthBarView()
@property (nonatomic, strong) CAShapeLayer* shapeLayer;
@property (nonatomic, assign) NSInteger barWidth;
@property (nonatomic, assign) NSInteger barHeight;
@property (nonatomic, assign) CGRect barRect;
@property (nonatomic, assign) CGPoint leftTopPoint;
@property (nonatomic, assign) CGPoint rightTopPoint;
@property (nonatomic, assign) CGPoint leftBottomPoint;
@property (nonatomic, assign) CGPoint rightBottomPoint;
@property (nonatomic, assign) CGPoint topMidPoint;
@property (nonatomic, assign) CGPoint bottomMidPoint;

@end

@implementation HealthBarView



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self initPoints];
    self.shapeLayer = [CAShapeLayer new];
    self.shapeLayer.fillColor = self.backgroundColor.CGColor;
    self.shapeLayer.strokeColor = UIColor.blueColor.CGColor ;
    self.shapeLayer.lineWidth = 1;
    // shapeLayer.frame is the drawable area
    self.shapeLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    // Todo make into function for drawing bar object
    // Draw the top line
//    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:self.barRect cornerRadius:10];
//    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:self.barRect byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:(CGSize) {10, 10}];
//    self.shapeLayer.path = path.CGPath
    ;
    [self drawNoArcHealthBar:10 thickness:10];

    [self.layer addSublayer:self.shapeLayer];
}

- (void) initPoints {
    // Top left is 0,0
    // todo make these points represent the four corners of the health bar, not the frame
    NSInteger margin = 50; // todo calc margin based on width
    NSInteger top = self.bounds.origin.y + margin;
    NSInteger left = self.bounds.origin.x + margin;
    NSInteger bottom = self.bounds.size.height - margin;
    NSInteger right = self.bounds.size.width - margin;

    self.leftTopPoint = CGPointMake(left, top);
    self.rightTopPoint = CGPointMake(right, top);
    self.leftBottomPoint = CGPointMake(left, bottom);
    self.rightBottomPoint = CGPointMake(right, bottom);
    self.barWidth = right - left;
    self.barHeight = bottom - top;
    self.barRect = CGRectMake(left, top, self.barWidth, self.barHeight);

}

// https://stackoverflow.com/questions/50527832/how-to-draw-a-curved-line-using-cashapelayer-and-bezierpath-in-swift-4
- (void) drawNoArcHealthBar: (CGFloat)endRoundness thickness: (CGFloat)thickness {
    
    CGPoint pointsCenter = CGPointMake((self.leftTopPoint.x+self.rightTopPoint.x)*0.5, (self.leftTopPoint.y+self.rightTopPoint.y)*0.5);
    
    NSLog(@"to: (%f, %f)",self.rightTopPoint.x, self.rightTopPoint.y);
    NSLog(@"from: (%f, %f)",self.leftTopPoint.x, self.leftTopPoint.y);
    NSLog(@"center: (%f, %f)",pointsCenter.x, pointsCenter.y);
    // XXX Hypothesis: displaces x by
//    CGPoint centerDisplacement = CGPointMake((from.y-to.y), (from.x-to.x));
    
    //todo XXX make middlepoint independent of endroundness or always further out than control point
    CGPoint leftMiddlePoint = CGPointMake(self.leftTopPoint.x - endRoundness*1.1, self.leftTopPoint.y + 0.5*self.barHeight);
    CGPoint rightMiddlePoint = CGPointMake(self.rightTopPoint.x + endRoundness*1.1, self.rightTopPoint.y + 0.5*self.barHeight);
    
    // Drawing from top left to top right then down and back around, clockwise
    CGPoint rightTopControlPoint = CGPointMake(self.rightTopPoint.x + endRoundness, self.rightTopPoint.y + endRoundness*0.5);

    CGPoint rightBottomControlPoint = CGPointMake(self.rightBottomPoint.x + endRoundness, self.rightTopPoint.y - endRoundness*0.5);

    CGPoint leftTopControlPoint = CGPointMake(self.leftTopPoint.x - endRoundness, self.leftTopPoint.y + self.barHeight*0.5);

    CGPoint leftBottomControlPoint = CGPointMake(self.leftBottomPoint.x - endRoundness, self.leftBottomPoint.y - endRoundness*0.5);

    
    UIBezierPath* path = [UIBezierPath new];
    [path moveToPoint:self.leftTopPoint];
    [path addLineToPoint:self.rightTopPoint];
    [path addQuadCurveToPoint:rightMiddlePoint controlPoint:rightTopControlPoint];
    [path addQuadCurveToPoint:self.rightBottomPoint controlPoint:rightBottomControlPoint];
    [path addLineToPoint:self.leftBottomPoint];
    [path addQuadCurveToPoint:leftMiddlePoint controlPoint:leftBottomControlPoint];
    [path addQuadCurveToPoint:self.leftTopPoint controlPoint:leftTopControlPoint];
    [path closePath];
    self.shapeLayer.path = path.CGPath;
}

// Todo
- (void) drawArchedHealthBar {
    
}

@end
