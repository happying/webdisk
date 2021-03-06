//
//  ExplorerViewController.m
//  WebDisk
//
//  Created by ccnyou on 14-4-1.
//  Copyright (c) 2014年 ccnyou. All rights reserved.
//

#import "ExplorerViewController.h"
#import "Unity.h"
#import "WebDiskAdapter.h"
#import "MBProgressHUD.h"

@interface ExplorerViewController ()
<PullingRefreshTableViewDelegate, UITableViewDataSource,
UITableViewDelegate, WebDiskClientDelegate, MBProgressHUDDelegate>

@property (nonatomic, strong) PullingRefreshTableView* tableView;
@property (nonatomic, strong) NSArray* files;
@property (nonatomic, strong) NSMutableArray* cachedFiles;
@property (nonatomic, strong) NSCondition* condition;
@property (nonatomic, strong) MBProgressHUD* progressHud;
@property (nonatomic, strong) NSIndexPath* lastSelectedCellIndexPath;

@end

@implementation ExplorerViewController

static __weak ExplorerViewController* g_sharedExplorer = nil;

+ (ExplorerViewController *)sharedExplorer
{
    return g_sharedExplorer;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _files = nil;
        _cachedFiles = [[NSMutableArray alloc] init];
        _condition = [[NSCondition alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self initBgAttributes];
    [self initControls];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_files == nil) {
        [self.tableView launchRefreshing];
    }
    
    g_sharedExplorer = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initBgAttributes
{
    if ([_path isEqualToString:@"/"]) {
        self.navigationItem.title = @"所有文件";
    } else {
        self.navigationItem.title = [_path lastPathComponent];
    }
}

- (void)initControls
{
    _tableView = [[PullingRefreshTableView alloc] initWithFrame:CGRectMake(0, 64, 320, 548) pullingDelegate:self];
    _tableView.headerOnly = YES;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
}

#pragma mark - common methods

- (NSString *)loaclPathForWebDisk:(NSString *)fileName
{
    NSString* webDiskPath = [_path stringByAppendingPathComponent:fileName];
    //NSLog(@"%s line:%d webDiskPath = %@", __FUNCTION__, __LINE__, webDiskPath);
    NSURL* appUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    NSString* userId = [_client userId];
    NSString* localRoot = [[appUrl path] stringByAppendingPathComponent:userId];
    NSString* localPath = [localRoot stringByAppendingPathComponent:webDiskPath];
    //NSLog(@"%s line:%d loaclPath = %@", __FUNCTION__, __LINE__, localPath);
    
    return localPath;
}

- (BOOL)isWebFileExpired:(id<WebDiskMetadata>)file
{
    BOOL result = YES;
    
    NSString* fileName = [file fileName];
    NSString* localPath = [self loaclPathForWebDisk:fileName];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:localPath]) {
        NSError* error = nil;
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:localPath error:&error];
        NSDate* loaclFileDate = [fileAttributes objectForKey:NSFileCreationDate];
        NSDate* webFileDate = [file lastModifiedDate];
        if ([loaclFileDate laterDate:webFileDate]) {
            result = NO;
        } else {
            //服务器的文件更新，文件已过期
            result = YES;
        }
        
    }
    
    return result;
}

- (BOOL)isWebFileDownloaded:(id<WebDiskMetadata>)file
{
    BOOL result = NO;
    NSString* fileName = [file fileName];
    NSString* localPath = [self loaclPathForWebDisk:fileName];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:localPath]) {
        result = YES;
    }
    
    return result;
}

- (UIImage *)imageForWebDiskFile:(id<WebDiskMetadata>)file
{
    UIImage* image = nil;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* fileName = [file fileName];
    NSString* localPath = [self loaclPathForWebDisk:fileName];
    if ([fileManager fileExistsAtPath:localPath]) {
        NSError* error = nil;
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:localPath error:&error];
        NSDate* loaclFileDate = [fileAttributes objectForKey:NSFileCreationDate];
        NSDate* webFileDate = [file lastModifiedDate];
        if ([loaclFileDate laterDate:webFileDate]) {
            image = [UIImage imageNamed:@"file_sync.png"];
        } else {
            //不同步
            image = [UIImage imageNamed:@"file_old.png"];
        }
        
    } else {
        //未下载
        image = [UIImage imageNamed:@"file.png"];
    }
    
    return image;
}

#pragma mark - ScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.tableView tableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self.tableView tableViewDidEndDragging:scrollView];
}

#pragma mark - TableView

- (void)showDownloadHud
{
    _progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    _progressHud.delegate = self;
    _progressHud.labelText = @"下载中...";
    _progressHud.dimBackground = YES;
    [self.view addSubview:_progressHud];
    
    [_progressHud show:YES];
}

- (void)onSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<WebDiskMetadata> file = [_files objectAtIndex:indexPath.row];
    if ([file isDirectory]) {
        ExplorerViewController* explorerViewController = [[ExplorerViewController alloc] initWithNibName:nil bundle:nil];
        explorerViewController.client = self.client;
        explorerViewController.path = [file path];
        [self.navigationController pushViewController:explorerViewController animated:YES];
        
    } else {
        //文件未下载或者文件已过期
        if (![self isWebFileDownloaded:file] || [self isWebFileExpired:file]) {
            [NSThread detachNewThreadSelector:@selector(showDownloadHud) toTarget:self withObject:nil];
            [self downloadFile:[file fileName]];
        } else {
            NSLog(@"%s %d 文件 %@ 不需要重复下载", __FUNCTION__, __LINE__, [file fileName]);
        }

    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _lastSelectedCellIndexPath = indexPath;
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSelector:@selector(onSelectRowAtIndexPath:) withObject:indexPath afterDelay:0.5f];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_files count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cellRet = nil;
    //间距的cell
    static NSString* identifier = @"CellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    
    if (indexPath.row < _files.count) {
        id<WebDiskMetadata> file = [_files objectAtIndex:indexPath.row];
        if ([file isDirectory]) {
            
            cell.imageView.image = [UIImage imageNamed:@"directory.png"];
            cell.textLabel.text = [file.path lastPathComponent];

        } else {
            cell.imageView.image = [self imageForWebDiskFile:file];
            cell.textLabel.text = [file fileName];
        }
        
    } else {
        cell.imageView.image = nil;
        cell.textLabel.text = @"";
    }

    cellRet = cell;
    
    return cellRet;
}



#pragma mark - Pulling Refresh Table View Delegate
- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView
{
    NSLog(@"%s line:%d", __FUNCTION__, __LINE__);
}

- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView
{
    [self performSelector:@selector(loadData) withObject:nil afterDelay:1.f];
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
    self.progressHud = nil;
}

#pragma mark - Data Methods

- (void) loadData
{
    [_client setDelegate:self];
    [_client loadMetadata:_path];
}

- (void)downloadFile:(NSString *)fileName
{
    NSString* dropboxPath = [_path stringByAppendingPathComponent:fileName];
    NSLog(@"%s line:%d droppthh = %@", __FUNCTION__, __LINE__, dropboxPath);
    NSURL* appUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    NSString* userId = [_client userId];
    NSString* loaclRoot = [[appUrl path] stringByAppendingPathComponent:userId];
    NSString* localPath = [loaclRoot stringByAppendingPathComponent:dropboxPath];
    NSLog(@"%s line:%d loaclPath = %@", __FUNCTION__, __LINE__, localPath);
    
    NSString* localDirectory = [localPath substringToIndex:[localPath length] - [[localPath lastPathComponent] length]];
    [[NSFileManager defaultManager] createDirectoryAtPath:localDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    [_client loadFile:dropboxPath intoPath:localPath];
}

#pragma mark - WebDiskClientDelegate
- (void)webDiskClient:(id<WebDiskAdapter>)client loadedMetadata:(id<WebDiskMetadata>)metadata;
{
    if ([metadata isDirectory]) {
        for (id file in [metadata contents]) {
            [_cachedFiles addObject:file];
        }
    }
    
    _files = _cachedFiles;
    _cachedFiles = [NSMutableArray new];
    [_tableView tableViewDidFinishedLoading];
    [_tableView reloadData];
}

- (void)webDiskClient:(id<WebDiskAdapter>)client loadMetadataFailedWithError:(NSError *)error
{
    NSLog(@"%s line:%d error = %@", __FUNCTION__, __LINE__, error);
    
    NSString* msg = error.localizedDescription;
    [_tableView tableViewDidFinishedLoading];
    [Unity presentHud:self.tableView withText:msg andImage:[UIImage imageNamed:@"error.png"]];
}


- (void)webDiskClient:(id<WebDiskAdapter>)client loadedFile:(NSString *)localPath
          contentType:(NSString *)contentType metadata:(id<WebDiskMetadata>)metadata
{
    NSLog(@"%s line:%d %@", __FUNCTION__, __LINE__, _lastSelectedCellIndexPath);
    UITableViewCell* cell = [_tableView cellForRowAtIndexPath:_lastSelectedCellIndexPath];
    cell.imageView.image = [UIImage imageNamed:@"file_sync.png"];

    [_progressHud hide:YES];
}

- (void)webDiskClient:(id<WebDiskAdapter>)client loadFileFailedWithError:(NSError *)error
{
    NSLog(@"%s %d error = %@", __FUNCTION__, __LINE__, error);
    [_progressHud hide:YES];
}

@end
