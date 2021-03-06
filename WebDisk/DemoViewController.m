//
//  DemoViewController.m
//  WebDisk
//
//  Created by ccnyou on 14-4-26.
//  Copyright (c) 2014年 ccnyou. All rights reserved.
//

#import "DemoViewController.h"
#import "ZipArchive.h"
#import "AESCrypt.h"
#import "GTMDefines.h"
#import "GTMBase64.h"
#import <CommonCrypto/CommonDigest.h>


@interface DemoViewController () <ZipArchiveDelegate>

@property (nonatomic, strong) ZipArchive* zipArchive;
@property (nonatomic, strong) IBOutlet UITextView* textView;
    
@end

@implementation DemoViewController

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
	// Do any additional setup after loading the view.
    _zipArchive = [[ZipArchive alloc] init];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
- (IBAction)compressTest:(id)sender {
    NSURL* appUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString* demoPath = [[appUrl path] stringByAppendingPathComponent:@"music"];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:demoPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString* zipFilePath = [demoPath stringByAppendingFormat:@"/big_files.zip"];
    [_zipArchive CreateZipFile2:zipFilePath];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        for (int i = 0; i < 10; i++) {
            NSString* fileName = [NSString stringWithFormat:@"%d.mp3", i];
            NSString* filePath = [demoPath stringByAppendingPathComponent:fileName];
            [_zipArchive addFileToZip:filePath newname:fileName];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.textView.text = [_textView.text stringByAppendingFormat:@"添加 %d 个文件完成\n", i+1];
                NSLog(@"%s line:%d 添加 %d 个文件完成\n", __FUNCTION__, __LINE__, i+1);
            });
        }
        
        [_zipArchive CloseZipFile2];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textView.text = [_textView.text stringByAppendingFormat:@"压缩文件完成\n"];
            NSLog(@"%s line:%d 压缩文件完成\n", __FUNCTION__, __LINE__);
        });
    });
    
}
//
//- (IBAction)checksumTest:(id)sender {
//    NSURL* appUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
//    NSString* demoPath = [[appUrl path] stringByAppendingPathComponent:@"music"];
//    [[NSFileManager defaultManager] createDirectoryAtPath:demoPath withIntermediateDirectories:YES attributes:nil error:nil];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        for (int i = 0; i < 10; i++) {
//            NSString* fileName = [NSString stringWithFormat:@"%d.mp3", i];
//            NSString* filePath = [demoPath stringByAppendingPathComponent:fileName];
//            
//            NSString* decryptedFileName = [NSString stringWithFormat:@"%d.mp3", i+20];
//            NSString* decryptedFilePath = [demoPath stringByAppendingPathComponent:decryptedFileName];
//            
//            //将文件读入
//            NSData* fileData = [NSData dataWithContentsOfMappedFile:filePath];
//          
//            
//            //加密前md5处理
//            NSString *md5encode = [self getMD5:fileData];
//            NSLog(@"%@", md5encode);
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.textView.text = [_textView.text stringByAppendingFormat:@"第 %d 个文件的32位MD5：%@\n", i+1, md5encode];
//            });
//            
//            //AES加密
//            NSString *password = @"password";
//            NSData *encryptedData = [AESCrypt encrypt:fileData  password:password];
//            
//            //base64加码
//            NSData* base64 = [GTMBase64 encodeData:encryptedData];
//            
//            //加密后md5处理
//            NSString *md5decode = [self getMD5:base64];
//            NSLog(@"%@", md5decode);
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.textView.text = [_textView.text stringByAppendingFormat:@"第 %d 个文件加密，加码后的32位MD5：\n", i+1];
//                self.textView.text = [_textView.text stringByAppendingFormat:@"%@\n", md5decode];
//            });
//            
//            //base64解码
//            NSData* base64Decode = [GTMBase64 decodeData:base64];
//            
//            //解密
//            NSData* decryptedData = [AESCrypt decrypt:base64Decode  password:password];
//            [decryptedData writeToFile:decryptedFilePath atomically:YES];
//            
//            //解密后md5处理
//            md5decode = [self getMD5:decryptedData];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.textView.text = [_textView.text stringByAppendingFormat:@"第 %d 个文件解密后的32位MD5：\n", i+1];
//                self.textView.text = [_textView.text stringByAppendingFormat:@"%@\n", md5decode];
//                
//            });
//            
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.textView.text = [_textView.text stringByAppendingFormat:@"第 %d 个文件测试完成\n\n", i+1];
//                NSLog(@"%s line:%d 第 %d 个文件加密，加码完成\n", __FUNCTION__, __LINE__, i+1);
//            });
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.textView.text = [_textView.text stringByAppendingFormat:@"that's all\n"];
//            NSLog(@"%s line:%d 所有文件加密加码完成，编号为10~19的文件为加密加码后文件，编号为20~29的文件为解码解密后的文件\n", __FUNCTION__, __LINE__);
//        });
//    });
//    
//}


//用于生成int大小的文件
- (IBAction)checksumTest:(id)sender {
//    int size = [sender tag];
    int fileSize = 65534;
    
    NSMutableString *temp = [NSMutableString stringWithCapacity:65535];
    NSString *text0 = @"";
    NSMutableString *text1 = [NSMutableString stringWithCapacity:2];
    NSMutableString *text2 = [NSMutableString stringWithCapacity:11];
    NSMutableString *text3 = [NSMutableString stringWithCapacity:101];
    
    NSString *filename = @"test.txt";
    NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSLog(@"%@", localDir);
    NSString *localPath = [localDir stringByAppendingPathComponent:filename];
    
    for (int i = 100; i > 0; i--) {
        int random = arc4random() % 10;
        [text3 appendFormat:@"%d",random];
    }
    
    for (int i = 10; i > 0; i--) {
        int random = arc4random() % 10;
        [text2 appendFormat:@"%d",random];
    }
    
    int random = arc4random() % 10;
    [text1 appendFormat:@"%d",random];
    
    
    if (fileSize >= 100) {
        int num = fileSize/100;
        fileSize = fileSize - num*100;
        for (; num>0; num--) {
            [temp appendString:text3];
        }
    }
    if (fileSize >= 10) {
        int num = fileSize/10;
        fileSize = fileSize - num*10;
        for (; num>0; num--) {
            [temp appendString:text2];
        }
    }
    if (fileSize >= 0) {
        
        for (; fileSize > 0; fileSize--) {
            [temp appendString:text1];
        }
    }
    
    [temp appendString:text0];
    NSLog(@"大小是 %d 字节", [temp length]);
    [temp writeToFile:localPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
}


//32位MD5加密方式
- (NSString*)getMD5:(NSData *)data
{
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, data.length, result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
