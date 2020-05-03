//
//  SocketManager.h
//  ss
//
//  Created by Jz D on 2020/4/30.
//  Copyright © 2020 Jz D. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


  
/// 掉线类型（服务端掉线，或用户主动退出）
typedef NS_ENUM(NSInteger, SocketDisconnectType)
{
    /// 服务器掉线，默认为0
    SocketOfflineByServer = 0,
      
    /// 用户主动cut
    SocketOfflineByUser = 1
};
  
@interface SocketManager : NSObject
  
/// 掉线类型
@property (nonatomic, assign) SocketDisconnectType disconnecType;
  
/// 文件路径
@property (nonatomic, copy) NSString *filePath;
  
/// 单例
+ (SocketManager *)sharedSocket;
  
/// socket连接
- (void)socketConnectWithHost:(NSString *)host port:(UInt16)port;
  
/// socket连接断开
- (void)socketDisconnect;
  
/// GCDSocket连接
- (void)GCDSocketConnectWithHost:(NSString *)host port:(UInt16)port;;
  
/// GCDSocket连接断开
- (void)GCDSocketDisconnect;
  
@end

NS_ASSUME_NONNULL_END
