//
//  Unity.h
//  b866
//
//  Created by ccnyou on 10/2/13.
//  Copyright (c) 2013 ccnyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "NSString+ccWidgets.h"
#import "UIImageView+WebCache.h"

@interface Unity : NSObject

+ (Unity*)sharedUnity;

+ (float)currentDeviceVersion;
+ (void)presentHud:(UIView*)atView withText:(NSString* )text andImage:(UIImage *)image;


+ (UIColor *)colorWithRed:(int)red green:(int)green blue:(int)blue alpha:(CGFloat)a;
+ (UIColor *)colorWithHexString:(NSString *) hexString;

+ (NSString *)sharePlistPath;

+ (UIColor *)backgroundColor;

+ (NSString *)keyForRequestParams:(NSDictionary *)params;

+ (CGFloat)viewHeightFor:(UIViewController *)controller;


@end
