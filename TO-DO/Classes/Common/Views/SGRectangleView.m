//
// Created by Siegrain on 16/11/3.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "SGRectangleView.h"

@interface SGRectangleView ()
@property(nonatomic, strong) CALayer *rectangleLayer;
@end

@implementation SGRectangleView
#pragma mark - accessors

- (void)setColor:(UIColor *)color {
    _color = color;
    
    [self setNeedsDisplay];
}

#pragma mark - initial

- (instancetype)init {
    if (self = [super init]) {
        [self setupViews];
        [self bindConstraints];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];
    
    _rectangleLayer = [CALayer layer];
    [self.layer addSublayer:_rectangleLayer];
}

- (void)bindConstraints {
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _rectangleLayer.frame = CGRectMake(0, 0, kScreenWidth, self.height);
}

- (void)drawShape:(CGContextRef)ctx {
    //画椭圆，如果长宽相等就是圆
//    CGContextAddEllipseInRect(ctx, CGRectMake(0, 250, 50, 50));
    //画矩形,长宽相等就是正方形
//    CGContextAddRect(ctx, CGRectMake(70, 250, 50, 50));
    //画多边形，多边形是通过path完成的
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, &CGAffineTransformIdentity, kScreenWidth, 0);
    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, 0, self.height);
    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, kScreenWidth, self.height);
    CGPathCloseSubpath(path);
    CGContextAddPath(ctx, path);
    
    //填充
    CGContextFillPath(ctx);
	CGPathRelease(path);
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    UIColor *color = _color ?: [UIColor whiteColor];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //设置笔触颜色
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);//设置颜色有很多方法，我觉得这个方法最好用
    //设置笔触宽度
    CGContextSetLineWidth(ctx, 2);
    //设置填充色
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    //设置拐点样式
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    //Line cap 线的两端的样式
    CGContextSetLineCap(ctx, kCGLineCapRound);
    //画矩形,画椭圆，多边形
    [self drawShape:ctx];
    [_rectangleLayer drawInContext:ctx];
}
@end
