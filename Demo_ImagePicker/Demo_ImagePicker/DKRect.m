//
//  DKRect.m
//  Demo_ImagePicker
//
//  Created by ldk on 13-9-11.
//  Copyright (c) 2013年 DK. All rights reserved.
//

#import "DKRect.h"

@implementation DKRect

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}




- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetLineWidth(context, 1.0);
    CGContextAddRect(context, CGRectMake(rect.origin.x, rect.origin.y , rect.size.width, rect.size.height));
    CGContextStrokePath(context);
   
}


@end
