//
//  DropBoxAdapter.m
//  WebDisk
//
//  Created by ccnyou on 14-4-1.
//  Copyright (c) 2014年 ccnyou. All rights reserved.
//

#import "DropBoxAdapter.h"
#import <DropboxSDK/DropboxSDK.h>

@interface DropBoxAdapter () <DBRestClientDelegate>

@property (nonatomic, strong) DBSession* session;
@property (nonatomic, strong) DBRestClient* client;

@end

@interface DropBoxMetadata ()

@property (nonatomic, strong) DBMetadata* metadata;

- (id)initWithMetadata:(DBMetadata *)metadata;

@end

@implementation DropBoxAdapter

+ (void)initAppkey
{
    DBSession *dbSession = [[DBSession alloc]
                            initWithAppKey:@"bgdebclfjdbafzt"
                            appSecret:@"gsw0nonlgti0svr"
                            root:@"auto"]; // either kDBRootAppFolder or kDBRootDropbox
    [DBSession setSharedSession:dbSession];
    
}

- (id)init
{
    self = [super init];
    if (self) {
        _session = [DBSession sharedSession];
        _client = [[DBRestClient alloc] initWithSession:_session];
        _client.delegate = self;
    }
    
    return self;
}

- (id)copyWithZone:(struct _NSZone *)zone
{
    DropBoxAdapter* result = [[DropBoxAdapter allocWithZone:zone] init];
    return result;
}

#pragma mark - override methods
- (BOOL)isLinked
{
#if UNLINK_ALL
    //每次都需要授权
    static BOOL isTest = YES;
    if (isTest) {
        NSLog(@"%s line:%d unlink dropbox", __FUNCTION__, __LINE__);
        [_session unlinkAll];
        isTest = NO;
    }
#endif
    return [_session isLinked];
}

- (void)linkFromController:(UIViewController *)viewController
{
    [_session linkFromController:viewController];
}

- (void)loadMetadata:(NSString *)path
{
    [_client loadMetadata:path];
}

- (void)loadFile:(NSString *)webDiskPath intoPath:(NSString *)loaclPath
{
    [_client loadFile:webDiskPath intoPath:loaclPath];
}

- (NSString *)userId
{
    NSArray *userIds = [_session userIds];
    NSAssert([userIds count] > 0, @"这里出错了：%s %d", __FUNCTION__, __LINE__);
    //为了避免跟其他网盘用户id相同导致冲突问题
    NSString* result = [NSString stringWithFormat:@"dropbox_%@", [userIds objectAtIndex:0]];
    
    return result;
}

- (void)uploadFile:(NSString *)fileName
            toPath:(NSString *)destDir
     withParentRev:(NSString *)parentRev
          fromPath:(NSString *)sourcePath
{
    [_client uploadFile:fileName toPath:destDir withParentRev:parentRev fromPath:sourcePath];
}


#pragma mark - DBRestClientDelegate

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    DropBoxMetadata* dbMetadata = [[DropBoxMetadata alloc] init];
    dbMetadata.metadata = metadata;
    
    if ([self.delegate respondsToSelector:@selector(webDiskClient:loadedMetadata:)]) {
        [self.delegate webDiskClient:self loadedMetadata:dbMetadata];
    }
}

- (void)restClient:(DBRestClient *)client
loadMetadataFailedWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(webDiskClient:loadMetadataFailedWithError:)]) {
        [self.delegate webDiskClient:self loadMetadataFailedWithError:error];
    }
    
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)localPath
       contentType:(NSString *)contentType metadata:(DBMetadata *)metadata {
    if ([self.delegate respondsToSelector:@selector(webDiskClient:loadedFile:contentType:metadata:)]) {
        [self.delegate webDiskClient:self
                      loadedFile:localPath
                     contentType:contentType
                        metadata:[[DropBoxMetadata alloc] initWithMetadata:metadata]];
    }
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(webDiskClient:loadFileFailedWithError:)]) {
        [self.delegate webDiskClient:self loadFileFailedWithError:error];
    }
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    DropBoxMetadata* dbmetadata = [[DropBoxMetadata alloc] initWithMetadata:metadata];
    if ([self.delegate respondsToSelector:@selector(webDiskClient:uploadedFile:from:metadata:)]) {
        [self.delegate webDiskClient:self uploadedFile:destPath from:srcPath metadata:dbmetadata];
    }
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(webDiskClient:uploadFileFailedWithError:)]) {
        [self.delegate webDiskClient:self uploadFileFailedWithError:error];
    }
}

- (void)restClient:(DBRestClient *)client uploadFileChunkProgress:(CGFloat)progress forFile:(NSString *)uploadId offset:(unsigned long long)offset fromPath:(NSString *)localPath{
    NSLog(@"%s line:%d progress = %.2f", __FUNCTION__, __LINE__, progress);
}

@end



@implementation DropBoxMetadata

- (id)initWithMetadata:(DBMetadata *)metadata
{
    self = [super init];
    if (self) {
        self.metadata = metadata;
    }
    
    return self;
}
         
             
- (BOOL)isDirectory
{
    return [_metadata isDirectory];
}

- (NSArray *)contents
{
    NSMutableArray* contentsRet = [[NSMutableArray alloc] initWithCapacity:[_metadata.contents count]];
    for (DBMetadata* file in _metadata.contents) {
        DropBoxMetadata* data = [[DropBoxMetadata alloc] init];
        data.metadata = file;
        [contentsRet addObject:data];
    }
    
    return contentsRet;
}

- (NSString *)fileName
{
    return _metadata.filename;
}

- (NSString *)path
{
    return _metadata.path;
}

- (NSDate *)lastModifiedDate
{
    return [_metadata lastModifiedDate];
}

@end


