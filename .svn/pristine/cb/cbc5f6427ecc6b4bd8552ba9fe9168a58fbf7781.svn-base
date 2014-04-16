//
//  Unity.m
//  b866
//
//  Created by ccnyou on 10/2/13.
//  Copyright (c) 2013 ccnyou. All rights reserved.
//

#import "Unity.h"
#import "Configurations.h"

@interface Unity ()


@end

static Unity* unity = nil;

@implementation Unity



+ (Unity*)sharedUnity
{
    @synchronized(self)
    {
        if (!unity)
        {
            (void)[[self alloc] init];
        }
    }
    
    
    return unity;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (!unity) {
            unity = [super allocWithZone:zone];
            return unity;
        }
    }
    
    return nil;
}

+ (void)presentHud:(UIView*)atView withText:(NSString* )text andImage:(UIImage *)image {
    static BDKNotifyHUD* notify = nil;
    if (notify == nil) {
        notify = [BDKNotifyHUD notifyHUDWithImage:image text:text];
        notify.center = CGPointMake(atView.center.x, atView.center.y - 20);
    }
    
    if (notify.isAnimating) {
        return;
    }
    
    [atView addSubview:notify];
    [notify presentWithDuration:1.0f speed:0.5f inView:atView completion:^{
        [notify removeFromSuperview];
        notify = nil;
    }];
}

+ (float)currentDeviceVersion
{
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    return version;
}


+ (UIColor*)colorWithRed:(int)red green:(int)green blue:(int)blue alpha:(CGFloat)a
{
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:a];
}

+ (UIColor *) colorWithHexString: (NSString *) hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            break;
        default:
            [NSException raise:@"Invalid color value" format: @"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
            break;
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

+ (NSString *)sharePlistPath
{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
    return plistPath;
}

+ (UIColor *)backgroundColor
{
    return [self colorWithHexString:@"#DDDDDD"];
}

+ (NSString *)keyForRequestParams:(NSDictionary *)params
{
    return @"unused";
}

+ (CGFloat)viewHeightFor:(UIViewController *)controller
{
    UIView* view = controller.view;
    UINavigationController* nav = controller.navigationController;
    UITabBarController* tabbar = controller.tabBarController;
    CGFloat rawHeight = view.bounds.size.height;
    //NSLog(@"%s line:%d %f, %f", __FUNCTION__, __LINE__, view.bounds.size.height, view.frame.size.height);
    if (nav != nil && nav.navigationBar.hidden == NO) {
            rawHeight -= nav.navigationBar.frame.size.height;
    }
    
    if (controller.hidesBottomBarWhenPushed == NO) {
        rawHeight -= tabbar.tabBar.frame.size.height;
    }
    
    return rawHeight;
}

@end

