//
//  HostViewController.h
//  oneOC
//
//  Created by Jz D on 2020/4/1.
//  Copyright © 2020 Jz D. All rights reserved.
//

// Bonjo , 感觉就是 DNS 发现设备


// Socket 就是建立连接

// 收包，发包






#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN



@class GCDAsyncSocket;
@protocol HostGameViewControllerDelegate;
 
@interface HostViewController : UIViewController
 
@property (weak, nonatomic) id<HostGameViewControllerDelegate> delegate;
 
@end
 
@protocol HostGameViewControllerDelegate
- (void)controller:(HostViewController *)controller didHostGameOnSocket:(GCDAsyncSocket *)socket;
- (void)controllerDidCancelHosting:(HostViewController *)controller;
@end


NS_ASSUME_NONNULL_END
