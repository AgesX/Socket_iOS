//
//  GameManager.m
//  oneOC
//
//  Created by Jz D on 2020/4/6.
//  Copyright © 2020 Jz D. All rights reserved.
//


 /*


#pragma mark -
#pragma mark Initialization
- (instancetype)initWithSocket:(GCDAsyncSocket *)socket {
    self = [super init];
 
    if (self) {
        // Socket
        self.socket = socket;
        self.socket.delegate = self;
 
        // Start Reading Data
        [self.socket readDataToLength:sizeof(uint64_t) withTimeout:-1.0 tag:TAG_HEAD];
    }
 
    return self;
}


- (void)testConnection {
    // Create Packet
    NSLog(@"testConnection 来了没有");
    NSString *message = @"This is a proof of concept. 啊哈哈";
    
   // NSString *message = @"This is a proof o";
    PacketH *packet = [[PacketH alloc] initWithData:message type:0 action:0];
 
    //  Send Packet
    [self sendPacket: packet];
}
// 长连接，控制，真是联动的好呀


- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
 
    if (self.socket == socket) {
        self.socket.delegate = nil;
        self.socket = nil;
    }
 
    // Notify Delegate
    [self.delegate managerDidDisconnect:self];
}



 // tag 1 , 走了没有
- (void)socket:(GCDAsyncSocket *)socket didReadData:(NSData *)data withTag:(long)tag {
    if (tag == 0) {
        uint64_t bodyLength = [self parseHeader:data];
        // tag 1
        
        // 在这里走的
        [socket readDataToLength:bodyLength withTimeout:-1.0 tag:1];
 
    } else if (tag == 1) {
        [self parseBody:data];
        [socket readDataToLength:sizeof(uint64_t) withTimeout:-1.0 tag:0];
    }
}











*/
