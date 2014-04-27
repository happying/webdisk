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

- (IBAction)checksumTest:(id)sender {
    NSURL* appUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString* demoPath = [[appUrl path] stringByAppendingPathComponent:@"music"];
    [[NSFileManager defaultManager] createDirectoryAtPath:demoPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        for (int i = 0; i < 10; i++) {
            NSString* fileName = [NSString stringWithFormat:@"%d.mp3", i];
            NSString* filePath = [demoPath stringByAppendingPathComponent:fileName];
            
            NSString* encryptedFileName = [NSString stringWithFormat:@"%d.mp3", i+10];
            NSString* encryptedFilePath = [demoPath stringByAppendingPathComponent:encryptedFileName];
            
            NSString* decryptedFileName = [NSString stringWithFormat:@"%d.mp3", i+20];
            NSString* decryptedFilePath = [demoPath stringByAppendingPathComponent:decryptedFileName];
            
            //将文件读入
            NSError *error1 = nil;
            NSString *astring = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:&error1];
            NSLog(@"astring:%@",astring);
            NSData* dataToEncode = [NSData dataWithContentsOfFile:filePath];
            
          
            
            //加密前md5处理
            NSString *md5encode = [self getMd5_32Bit_Data:dataToEncode];
            NSLog(@"%@",md5encode);
            
            //AES加密
            NSError *error2 = nil;
            NSString *message = astring;
            NSString *password = @"passward";
            NSString *encryptedData = [AESCrypt encryptData:dataToEncode  password:password];
            [encryptedData writeToFile: encryptedFilePath atomically:YES encoding:NSASCIIStringEncoding error:&error2];
            
            //base64加码
            dataToEncode = [GTMBase64 encodeData:dataToEncode];
            [dataToEncode writeToFile:encryptedFilePath atomically:YES ];
            
            
            //加密后md5处理
            NSData* dataToDecode = [NSData dataWithContentsOfFile:encryptedFilePath];
            NSString *md5dncode = [self getMd5_32Bit_Data:dataToDecode];
            NSLog(@"%@",md5dncode);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.textView.text = [_textView.text stringByAppendingFormat:@"第 %d 个文件加密，加码后的32位MD5：\n", i+1];
                self.textView.text = [_textView.text stringByAppendingFormat:@"%@\n", md5dncode];
                
            });
            
            //base64解码
           
            NSData* decode = [GTMBase64 decodeData:dataToDecode];
            [decode writeToFile: decryptedFilePath atomically: YES];
            
            //解密
            NSError *error3 = nil;
            message = [AESCrypt decryptData:dataToDecode  password:password];
            [message writeToFile: decryptedFilePath atomically:YES encoding:NSASCIIStringEncoding error:&error3];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.textView.text = [_textView.text stringByAppendingFormat:@"第 %d 个文件加密，加码前的32位MD5：\n", i+1];
                self.textView.text = [_textView.text stringByAppendingFormat:@"%@\n", md5encode];
                
            });
            
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.textView.text = [_textView.text stringByAppendingFormat:@"第 %d 个文件加密，加码完成\n\n", i+1];
                NSLog(@"%s line:%d 第 %d 个文件加密，加码完成\n", __FUNCTION__, __LINE__, i+1);
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textView.text = [_textView.text stringByAppendingFormat:@"that's all\n"];
            NSLog(@"%s line:%d 所有文件加密加码完成，编号为10~19的文件为加密加码后文件，编号为20~29的文件为解码解密后的文件\n", __FUNCTION__, __LINE__);
        });
    });
    
}


//32位MD5加密方式
- (NSString*)getMd5_32Bit_Data:(NSData *)data
{
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( data.bytes, data.length, result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}
    

@end
