//
//  UploadViewController.m
//  WebDisk
//
//  Created by ccnyou on 14-4-3.
//  Copyright (c) 2014年 ccnyou. All rights reserved.
//

#import "UploadViewController.h"
#import "ExplorerViewController.h"
#import "WebDiskAdapter.h"
#import "MBProgressHUD.h"

@interface UploadViewController () <WebDiskClientDelegate, MBProgressHUDDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView* tableView;

@property (nonatomic, strong) WebDiskAdapter<WebDiskAdapter>* client;
@property (nonatomic, strong) MBProgressHUD* progressHud;
@property (nonatomic, strong) NSMutableArray* uploadingFiles;

@end

@implementation UploadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _uploadingFiles = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    ExplorerViewController* explorer = [ExplorerViewController sharedExplorer];
    _client = [explorer.client copy];
    _client.delegate = self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showUploadHud
{
    _progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    _progressHud.delegate = self;
    _progressHud.labelText = @"上传中...";
    _progressHud.dimBackground = YES;
    [self.view addSubview:_progressHud];
    
    [_progressHud show:YES];
}

#pragma mark - Action

- (IBAction)addFile:(id)sender
{
    if (_client == nil) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"请先登录" message:@"请先选择网盘进行登录" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    // Write a file to the local documents directory
    NSString *text = @"Hello world. This is a test file for ccnyou";
    NSString *filename = @"working-draft.txt";
    NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *localPath = [localDir stringByAppendingPathComponent:filename];
    [text writeToFile:localPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    // Upload file to Dropbox
    ExplorerViewController* explorer = [ExplorerViewController sharedExplorer];
    NSString *destDir = explorer.path;
    [NSThread detachNewThreadSelector:@selector(showUploadHud) toTarget:self withObject:nil];
    [self.client uploadFile:filename toPath:destDir withParentRev:nil fromPath:localPath];
}




#pragma mark - Delegate

- (void)webDiskClient:(id<WebDiskAdapter>)client
         uploadedFile:(NSString *)destPath
                 from:(NSString *)srcPath
             metadata:(id<WebDiskMetadata>)metadata
{
    NSLog(@"%s line:%d %@", __FUNCTION__, __LINE__, [metadata path]);
    
    [_progressHud hide:YES];
}

- (void)webDiskClient:(id<WebDiskAdapter>)client uploadFileFailedWithError:(NSError *)error
{
    NSLog(@"%s line:%d error = %@", __FUNCTION__, __LINE__, error);
    [_progressHud hide:YES];
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
    self.progressHud = nil;
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_uploadingFiles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identify = @"uploading";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    
    cell.textLabel.text = @"ok";
    
    return cell;
}

@end