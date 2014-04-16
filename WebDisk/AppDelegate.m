//
//  AppDelegate.m
//  WebDisk
//
//  Created by ccnyou on 14-4-1.
//  Copyright (c) 2014年 ccnyou. All rights reserved.
//

#import "AppDelegate.h"
#import <DropboxSDK/DropboxSDK.h>
#import "DropBoxAdapter.h"
#import "LoginWebViewController.h"
#import "UploadViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
#if !TARGET_IPHONE_SIMULATOR
    NSURL* appUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString* logPath = [[appUrl path] stringByAppendingPathComponent:@"webdisk.log.txt"];
    const char* szLogPath = logPath.UTF8String;
    remove(szLogPath);
    freopen(szLogPath, "ab+", stdout);
    freopen(szLogPath, "ab+", stderr);
#endif
    
    [DropBoxAdapter initAppkey];
    
//    int tagIndex = 0;
//    LoginWebViewController* loginViewController = [[LoginWebViewController alloc] initWithNibName:nil bundle:nil];
//    UINavigationController* webdiskNavigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
//    webdiskNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"网盘" image:[UIImage imageNamed:@"1.png"] tag:tagIndex++];
//    
//    UploadViewController* uploadViewController = [[UploadViewController alloc] initWithNibName:nil bundle:nil];
//    UINavigationController* uploadNavigationController = [[UINavigationController alloc] initWithRootViewController:uploadViewController];
//    uploadNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"上传" image:[UIImage imageNamed:@"2.png"] tag:tagIndex++];
//    
//    UITabBarController* tabbarController = [[UITabBarController alloc] init];
//    tabbarController.viewControllers = @[webdiskNavigationController, uploadNavigationController];
//    
//    self.window.rootViewController = tabbarController;
//    
//    self.window.backgroundColor = [UIColor whiteColor];
//    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
  sourceApplication:(NSString *)source annotation:(id)annotation {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"Dropbox linked successfully!");
            NSLog(@"%s line:%d url = %@\nsource = %@\nannotation=%@", __FUNCTION__, __LINE__, url, source, annotation);
            LoginWebViewController* loginViewController = [LoginWebViewController sharedInstance];
            [loginViewController loginDidSuccess];
        }
        return YES;
    }
    // Add whatever other url handling code your app requires here
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
