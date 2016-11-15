//
//  ViewController.m
//  MultipeerConnectivityDemo
//
//  Created by HCL黄 on 16/11/15.
//  Copyright © 2016年 HCL黄. All rights reserved.
//

#import "ViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

#define server_type @"HH"

@interface ViewController () <MCBrowserViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MCSessionDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

/** 会话 */
@property (nonatomic, strong) MCSession *session;
/** 广告 */
@property (nonatomic, strong) MCAdvertiserAssistant *assistant;
/** 蓝牙浏览器 */
@property (nonatomic, strong) MCBrowserViewController *browser;
/** peerID */
@property (nonatomic, strong) MCPeerID *selectPeerID;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建一个用户ID
    MCPeerID *peerId = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
    // 创建一个蓝牙会话
    self.session = [[MCSession alloc] initWithPeer:peerId];
    // 设置代理
    self.session.delegate = self;
}

- (IBAction)connectBlueTooth:(id)sender
{
    // 连接蓝牙
    self.browser = [[MCBrowserViewController alloc] initWithServiceType:server_type session:self.session];
    // 设置代理
    self.browser.delegate = self;
    // 跳转到浏览控制器
    [self presentViewController:self.browser animated:YES completion:nil];
}
- (IBAction)selectImageView:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
    
}
- (IBAction)sendImage:(id)sender
{
    if (self.imageView.image == nil) {
        return;
    }
    // MCSessionSendDataReliable  // 安全发送， 效率比较低
    // MCSessionSendDataUnreliable // 不安全发送， 效率比较高
    NSError *error = nil;
    [self.session sendData:UIImagePNGRepresentation(self.imageView.image) toPeers:@[self.selectPeerID] withMode:MCSessionSendDataUnreliable error:&error];
    NSLog(@"error = %@",error.description);
}

- (IBAction)find:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    if (s.isOn) {
        // 广告 只要是这个广告是可用的 那么久可以被其他设备搜索到
        self.assistant = [[MCAdvertiserAssistant alloc] initWithServiceType:server_type discoveryInfo:nil session:self.session];
        // 开启广告
        [self.assistant start];
    }
    else {
        [self.assistant stop];
    }
}
#pragma mark - session的代理方法
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    
}
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    
}
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    
}
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = [UIImage imageWithData:data];
    });
}
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    switch (state) {
        case MCSessionStateConnected:
            NSLog(@"连接成功");
            break;
        case MCSessionStateConnecting:
            NSLog(@"正在连接");
            break;
        case MCSessionStateNotConnected:
            NSLog(@"没有连接");
            break;
        default:
            break;
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    self.imageView.image = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - MCBrowserViewControllerDelegate
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    NSLog(@"完成");
    [self.browser dismissViewControllerAnimated:YES completion:nil];
}
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    NSLog(@"退出");
    [self.browser dismissViewControllerAnimated:YES completion:nil];
    
}
- (BOOL)browserViewController:(MCBrowserViewController *)browserViewController shouldPresentNearbyPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary<NSString *,NSString *> *)info
{
    NSLog(@"选中某个蓝牙");
    self.selectPeerID = peerID;
    return YES;
}
@end
