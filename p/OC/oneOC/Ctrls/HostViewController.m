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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
}





- (void)cancel:(id)sender {
    // Cancel Hosting Game
    // TODO
 
    // Dismiss View Controller
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)startBroadcast {
    // Initialize GCDAsyncSocket
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
 
    // Start Listening for Incoming Connections
    NSError *error = nil;
    // 端口 0
    if ([self.socket acceptOnPort:0 error:&error]) {
        // Initialize Service
        self.service = [[NSNetService alloc] initWithDomain:@"local." type:@"_fourinarow._tcp." name:@"" port:[self.socket localPort]];
 
        
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
    NSLog(@"Accepted New Socket from %@:%hu", newSocket.connectedHost, newSocket.connectedPort);
    
    // Socket
    self.socket = newSocket;
    // Read Data from Socket
    [newSocket readDataToLength:sizeof(uint64_t) withTimeout:-1.0 tag:0];
    
    
    // Create Packet
       NSString *message = @"This is a proof of concept. 邓: 第一个包，来了";
       PacketH *packet = [[PacketH alloc] initWithData:message type:0 action:0];
    
    
    
    // 发包，很简洁
    
       // Send Packet
       [self sendPacket: packet];
}



/*
 When a connection is established, the application instance hosting the game is notified of this by the invocation of the socket:didAcceptNewSocket: delegate method of the GCDAsyncSocketDelegate protocol.
 
 
 We implemented this method in the previous article. Take a look at its implementation below to refresh your memory.


 The last line of its implementation should now be clear.

 We tell the new socket to start reading data and we pass a tag, an integer, as the last parameter.
 
 
 不清楚，什么时间
 We don't set a timeout (-1)
 because we don't know when we can expect the first packet to arrive.
 
 */




- (void)sendPacket:(PacketH *)packet {
    

    NSError * error;
    NSData * encoded = [NSKeyedArchiver archivedDataWithRootObject:packet requiringSecureCoding:NO error: &error];
    NSLog(@"error: %@", error);
    
    
    // Initialize Buffer
    NSMutableData *buffer = [[NSMutableData alloc] init];
 
    
    
    // buffer = header + packet
    
    // Fill Buffer
    uint64_t headerLength = encoded.length;
    [buffer appendBytes:&headerLength length:sizeof(uint64_t)];
    [buffer appendBytes: encoded.bytes length: headerLength];
 
    // Write Buffer
    [self.socket writeData:buffer withTimeout:-1.0 tag:0];
}

/*
 
 As I wrote earlier, we can only send binary data through a TCP connection.
 
 
 We then create another NSMutableData instance, which will be the data object that we will pass to the socket a bit later. The data object, however, does not only hold the encoded MTPacket instance. It also needs to include the header that precedes the encoded packet. We store the length of the encoded packet in a variable named headerLength which is of type uint64_t. We then append the header to the NSMutableData buffer.
 
 
 Did you spot the & symbol preceding headerLength?

 The appendBytes:length: method expects a buffer of bytes, not the value of the headerLength value. Finally, we append the contents of packetData to the buffer. The buffer is then passed to writeData:withTimeout:tag:. The CocoaAsyncSocket library takes care of the nitty gritty details of sending the data.
 
 
 
 */






// 出错啦
- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
 
    if (self.socket == socket) {
        [self.socket setDelegate:nil];
        [self setSocket:nil];
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
