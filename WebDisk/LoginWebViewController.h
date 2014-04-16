//
//  LoginWebViewController.h
//  WebDisk
//
//  Created by ccnyou on 14-4-1.
//  Copyright (c) 2014年 ccnyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginWebViewController : UIViewController

+ (LoginWebViewController *)sharedInstance;

- (void)loginDidSuccess;

@end
