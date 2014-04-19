//
//  WebDiskAdapter.m
//  WebDisk
//
//  Created by ccnyou on 14-4-1.
//  Copyright (c) 2014年 ccnyou. All rights reserved.
//

#import "WebDiskAdapter.h"
#import "DropBoxAdapter.h"

@implementation WebDiskMetadata
//
//- (BOOL)isDirectory
//{
//    [NSException raise:@"UnImplmentation Method" format:@"%s %d", __FUNCTION__, __LINE__];
//    return NO;
//}
//
//- (NSArray *)contents
//{
//    [NSException raise:@"UnImplmentation Method" format:@"%s %d", __FUNCTION__, __LINE__];
//    return nil;
//}
//
//- (NSString *)fileName
//{
//    [NSException raise:@"UnImplmentation Method" format:@"%s %d", __FUNCTION__, __LINE__];
//    return nil;
//}
//
//- (NSString *)path
//{
//    [NSException raise:@"UnImplmentation Method" format:@"%s %d", __FUNCTION__, __LINE__];
//    return nil;
//}
//
//- (NSDate *)lastModifiedDate
//{
//    [NSException raise:@"UnImplmentation Method" format:@"%s %d", __FUNCTION__, __LINE__];
//    return nil;
//}

@end


@implementation WebDiskAdapter

static WebDiskAdapter<WebDiskAdapter> *g_instance;

+ (void)initAppkey
{
    [DropBoxAdapter initAppkey];
}

+ (void)setSharedInstance:(WebDiskAdapter<WebDiskAdapter> *)instance
{
    g_instance = instance;
}

+ (WebDiskAdapter<WebDiskAdapter> *)sharedInstance
{
    return g_instance;
}



@end