//
//  HostViewController.m
//  oneOC
//
//  Created by Jz D on 2020/4/1.
//  Copyright © 2020 Jz D. All rights reserved.
//

#import "HostViewController.h"

#include "GCDAsyncSocket.h"


#import "PacketH.h"

// 目前，发送数据
@interface HostViewController ()<NSNetServiceDelegate, GCDAsyncSocketDelegate>
 
@property (strong, nonatomic) NSNetService *service;
@property (strong, nonatomic) GCDAsyncSocket *socket;



@end

@implementation HostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    
    // Start Broadcast
    [self startBroadcast];
}



- (void)setupView {
    // Create Cancel Button
    self.view.backgroundColor = UIColor.yellowColor;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
}





- (void)cancel:(id)sender {
    // Cancel Hosting Game
    [self.delegate controllerDidCancelHosting:self];
    
    // End Broadcast
    [self endBroadcast];
    
    // Dismiss View Controller
    [self dismissViewControllerAnimated:YES completion:nil];
}




- (void)dealloc {
    if (_delegate) {
        _delegate = nil;
    }
 
    if (_socket) {
        [_socket setDelegate:nil delegateQueue:NULL];
        _socket = nil;
    }
}





- (void)startBroadcast {
    // Initialize GCDAsyncSocket
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
 
    // Start Listening for Incoming Connections
    NSError *error = nil;
    // 端口 0
    if ([self.socket acceptOnPort:0 error:&error]) {
        // Initialize Service
        self.service = [[NSNetService alloc] initWithDomain:@"local." type:@"deng._tcp." name:@"" port:[self.socket localPort]];
 
        
//  Because we didn't pass a name, it automatically uses the name of the device.
        
        
        
        // Configure Service
        [self.service setDelegate:self];
 
        // Publish Service
        [self.service publish];
 
    } else {
        NSLog(@"Unable to create socket. Error %@ with user info %@.", error, [error userInfo]);
    }
}


/*
    The second step is to tell the socket to accept incoming connections by sending it a message of acceptOnPort:error:.

 We pass 0 as the port number, which means that it is up to the operating system to supply us with a port (number) that is available.


 This is generally the safest solution as we don't always know whether a particular port is in use or not. By letting the system choose a port on our behalf, we can be certain that the port (number) we get back is available. If the call is successful, that is, returning YES and not throwing an error, we can initialize the network service.
 
 */




/*
    The order in which all this takes place is important. The network service that we initialize needs to know the port number on which to listen for incoming connections. To initialize the network service,
 
 we pass (1) a domain, which is always local. for the local domain,
 
 
 (2) the network service type, which is a string that uniquely identifies the network service (not the instance of our application),
 
 (3) the name by which the network service is identified on the network,
 
 and (4) the port on which the network service is published.
 
 */



- (void)netServiceDidPublish:(NSNetService *)service {
    NSLog(@"∑  ø  Bonjour Service Published: domain(%@) type(%@) name(%@) port(%i)", service.domain, service.type, service.name, (int)service.port);
}




- (void)netService:(NSNetService *)service didNotPublish:(NSDictionary *)errorDict {
    NSLog(@"Failed to Publish Service: domain(%@) type(%@) name(%@) - %@", service.domain, service.type, service.name, errorDict);
}



- (void)socket:(GCDAsyncSocket *)socket didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
      NSLog(@"Accepted New Socket from %@:%hu", [newSocket connectedHost], [newSocket connectedPort]);
    
       // Notify Delegate
       [self.delegate controller:self didHostGameOnSocket:newSocket];
    
    // 转移代理对象，转移引用后，
    
    // 解除自己的引用
    
    
       // End Broadcast
       [self endBroadcast];
    
       // Dismiss View Controller
       [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)endBroadcast {
    if (self.socket) {
        [self.socket setDelegate:nil delegateQueue:NULL];
        [self setSocket:nil];
    }
 
    if (self.service) {
        [self.service setDelegate:nil];
        [self setService:nil];
    }
}





@end





/*
 
    As the documentation states, the delegate and delegate queue of the new socket are the same as the delegate and delegate queue of the old socket.
 
 
 
 What many people often forget is that we need to tell the new socket to start reading data and set the timeout to -1 (no timeout).
 
 
 Behind the scenes, the CocoaAsyncSocket library creates a read and a write stream for us, but we should tell the socket to monitor the read stream for incoming data.
 
 */







/*
 
 
 Because networking can be a bit messy from time to time,
 you may have noticed that I have inserted a few log statements here and there.

 
 
 
 Logging is your best friend when creating applications that involve networking.


 
 Don't hesitate to throw in a few log statements if you are not sure what is happening under the hood.
 
 
 */
