//
//  LoginWebViewController.m
//  WebDisk
//
//  Created by ccnyou on 14-4-1.
//  Copyright (c) 2014年 ccnyou. All rights reserved.
//

#import "LoginWebViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "WebDiskAdapter.h"
#import "DropBoxAdapter.h"
#import "ExplorerViewController.h"
#import "Unity.h"

@interface LoginWebViewController () <WebDiskClientDelegate>

@property (nonatomic, strong) WebDiskAdapter<WebDiskAdapter>* client;
@property (nonatomic, assign) SEL lastLoginSelector;

@end

@implementation LoginWebViewController

static LoginWebViewController *g_instance = nil;

+ (LoginWebViewController *)sharedInstance
{
    return g_instance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"网盘登录";
    g_instance = self;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didPressLinkDropBox {
    _lastLoginSelector = @selector(didPressLinkDropBox);
    
    static DropBoxAdapter* dropBoxAdapter = nil;
    if (dropBoxAdapter == nil) {
        dropBoxAdapter = [[DropBoxAdapter alloc] init];
    } 
    
    dropBoxAdapter.delegate = self;
    _client = dropBoxAdapter;
    
    if (![_client isLinked]) {
        [_client linkFromController:self];
    } else {
        ExplorerViewController* exploereViewController = [[ExplorerViewController alloc] initWithNibName:nil bundle:nil];
        exploereViewController.client = _client;
        exploereViewController.path = @"/";
        [self.navigationController pushViewController:exploereViewController animated:YES];
    }

}


- (void)loginDidSuccess
{
    [Unity presentHud:self.view withText:@"登录成功" andImage:[UIImage imageNamed:@"checkmark.png"]];
    [self performSelector:_lastLoginSelector withObject:nil afterDelay:1];
}


@end
