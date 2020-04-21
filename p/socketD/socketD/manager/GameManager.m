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






- (void)parseBody:(NSData *)data {
    NSLog(@"body 来了");
    NSError * error;
    NSSet *classes = [NSSet setWithObjects: NSDictionary.class, PacketH.class, nil];
    PacketH *packet = [NSKeyedUnarchiver unarchivedObjectOfClasses: classes fromData: data error: &error];
    
    NSLog(@"errorUnfold: %@", error);
    NSLog(@"Packet Data > %@", packet.data);
    NSLog(@"Packet Type > %li", (long)packet.type);
    NSLog(@"Packet Action > %li", (long)packet.action);
     
    // 落子了
    if (packet.type == PacketTypeDidAddDisc) {
        
           NSNumber *column = [(NSDictionary *)[packet  data] objectForKey:@"column"];
           NSLog(@"走 A, \n 列 %@", column);
           if (column) {
               // Notify Delegate
               NSLog(@" √ 来了没有， ha ha ha, \n 列 %@", column);
               [self.delegate manager:self didAddDiscToColumn: column.integerValue];
           }
    }
    else if ([packet type] == PacketTypeStartNewGame) {
         NSLog(@"走 B");
          // 这里真的走了，  点击 replay 的时候
        // 新开一局
        // Notify Delegate
        [self.delegate managerDidStartNewGame:self];
    }
}







- (void)addDiscToColumn:(NSInteger)column {
    // Send Packet
    NSDictionary *load = @{ @"column" : @(column) };
    PacketH *packet = [[PacketH alloc] initWithData:load type: PacketTypeDidAddDisc action:0];
    [self sendPacket: packet];
}





- (void)sendPacket:(PacketH *)packet {
    
    
    // packet to buffer
    // 包，到 缓冲
      
    // Encode Packet Data

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


 






*/
