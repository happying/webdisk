//
//  WebDiskAdapter.h
//  WebDisk
//
//  Created by ccnyou on 14-4-1.
//  Copyright (c) 2014年 ccnyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Configurations.h"

@protocol WebDiskMetadata;
@protocol WebDiskAdapter;
@protocol WebDiskClientDelegate;


//
@protocol WebDiskMetadata <NSObject>

@required
- (BOOL)isDirectory;
- (NSArray *)contents;
- (NSString *)fileName;
- (NSString *)path;
- (NSDate *)lastModifiedDate;

@end


@interface WebDiskMetadata : NSObject

@end


//
@protocol WebDiskClientDelegate <NSObject>

@optional
// list 目录
- (void)webDiskClient:(id<WebDiskAdapter>)client loadedMetadata:(id<WebDiskMetadata>)metadata;

- (void)webDiskClient:(id<WebDiskAdapter>)client loadMetadataFailedWithError:(NSError *)error;

// 下载文件
- (void)webDiskClient:(id<WebDiskAdapter>)client loadedFile:(NSString *)localPath
          contentType:(NSString *)contentType metadata:(id<WebDiskMetadata>)metadata;

- (void)webDiskClient:(id<WebDiskAdapter>)client loadFileFailedWithError:(NSError *)error;

// 上传文件
- (void)webDiskClient:(id<WebDiskAdapter>)client
         uploadedFile:(NSString *)destPath
                 from:(NSString *)srcPath
             metadata:(id<WebDiskMetadata>)metadata;

- (void)webDiskClient:(id<WebDiskAdapter>)client uploadFileFailedWithError:(NSError *)error;
@end



@protocol WebDiskAdapter <NSObject, NSCopying>

- (BOOL)isLinked;
- (void)linkFromController:(UIViewController *)viewController;
- (void)loadMetadata:(NSString *)path;

- (void)loadFile:(NSString *)webDiskPath intoPath:(NSString *)loaclPath;

- (NSString *)userId;

- (void)uploadFile:(NSString *)fileName
            toPath:(NSString *)destDir
     withParentRev:(NSString *)parentRev
          fromPath:(NSString *)sourcePath;

@end

@interface WebDiskAdapter : NSObject

+ (void)initAppkey;

//+ (void)setSharedInstance:(WebDiskAdapter<WebDiskAdapter> *)instance;
//+ (WebDiskAdapter<WebDiskAdapter> *)sharedInstance;

@property (nonatomic, weak) id<WebDiskClientDelegate> delegate;

@end





