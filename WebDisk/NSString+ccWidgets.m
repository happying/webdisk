//
//  NSObject+ccWidgets.m
//  HelloWorld
//
//  Created by ccnyou on 9/29/13.
//  Copyright (c) 2013 ccnyou. All rights reserved.
//

#import "NSString+ccWidgets.h"

@implementation NSString (ccWidgets)

+ (NSString*)stringWithFrame:(CGRect)frame
{
    NSString* resultString = [NSString stringWithFormat:@"[frame:(%.2f, %.2f, %.2f, %.2f)]",
                              frame.origin.x,
                              frame.origin.y,
                              frame.size.width,
                              frame.size.height
                              ];
    return resultString;
}

//- (CGFloat)calculateTextHeight:(UIFont*)font width:(NSUInteger)width
//{
//    CGSize size = [self sizeWithFont:font constrainedToSize:CGSizeMake(width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
//    CGFloat delta = size.height;
//    return delta;
//}

@end
