//
//  TableViewController.m
//  oneOC
//
//  Created by Jz D on 2020/4/1.
//  Copyright © 2020 Jz D. All rights reserved.
//

#import "JoinListController.h"

#include "GCDAsyncSocket.h"


#import "PacketH.h"


// 目前，收数据
@interface JoinListController()<NSNetServiceDelegate, NSNetServiceBrowserDelegate, GCDAsyncSocketDelegate>
 
@property (strong, nonatomic) GCDAsyncSocket *socket;
@property (strong, nonatomic) NSMutableArray *services;
@property (strong, nonatomic) NSNetServiceBrowser *serviceBrowser;


@end

@implementation JoinListController

static NSString *ServiceCell = @"ServiceCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup View
    [self setupView];
    
    // Start Browsing
    [self startBrowsing];
}

- (void)setupView {
    // Create Cancel Button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
}




- (void)cancel:(id)sender {
       // Notify Delegate
       [self.delegate controllerDidCancelJoining:self];
    
       // Stop Browsing Services
       [self stopBrowsing];
    
       // Dismiss View Controller
       [self dismissViewControllerAnimated:YES completion:nil];
}




- (void)dealloc {
    if (_delegate) {
        _delegate = nil;
    }

}

/*
    In the dealloc method of the MTJoinGameViewController class, we clean everything up. However, because this socket is managed by the game controller, we shouldn't set the delegate to nil and neither should we set the delegate queue to NULL. The game controller is instantiated before the dealloc method is invoked, which means that the delegate of the game controller's socket is (re)set to nil when the join game view controller is deallocated.
 
 
 In other words, even though the game controller has a reference to the socket, the socket's delegate is set to nil and this renders the socket unusable to us. The solution is as simple as removing the last few lines of the dealloc method in which we set the socket's delegate to nil and the socket's delegate queue to NULL. Run the application one more time to see if we have successfully fixed that nasty bug.
 
 
 */


- (void)startBrowsing {
    if (self.services) {
        [self.services removeAllObjects];
    } else {
        self.services = [[NSMutableArray alloc] init];
    }
 
    // Initialize Service Browser
    self.serviceBrowser = [[NSNetServiceBrowser alloc] init];
 
    // Configure Service Browser
    self.serviceBrowser.delegate = self;
    [self.serviceBrowser searchForServicesOfType:@"deng._tcp." inDomain:@"local."];
}



- (void)stopBrowsing {
    if (self.serviceBrowser) {
        [self.serviceBrowser stop];
        self.serviceBrowser.delegate = nil;
        [self setServiceBrowser:nil];
    }
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return self.services ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.services.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ServiceCell];
    
       if (!cell) {
           // Initialize Table View Cell
           cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ServiceCell];
       }
    
       // Fetch Service
       NSNetService *service = [self.services objectAtIndex: indexPath.row];
    
       // Configure Cell
       [cell.textLabel setText: service.name];
    
       return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
 
    // Fetch Service
    NSNetService *service = [self.services objectAtIndex: indexPath.row];
 
    // Resolve Service
    NSLog(@"Resolve 一下， 解析处理");
    service.delegate = self;
    // 点击，服务就 gg
    
    [service resolveWithTimeout:30.0];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)serviceBrowser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    // Update Services
    [self.services addObject:service];
 
    if(!moreComing) {
        // Sort Services
        [self.services sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
 
        // Update Table View
        [self.tableView reloadData];
    }
}


- (void)netServiceBrowser:(NSNetServiceBrowser *)serviceBrowser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
    // Update Services
    [self.services removeObject:service];
 
    if(!moreComing) {
        // Update Table View
        [self.tableView reloadData];
    }
}


- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)serviceBrowser {
    [self stopBrowsing];
}



- (void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didNotSearch:(NSDictionary *)userInfo {
    [self stopBrowsing];
}



- (void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict {
    [service setDelegate:nil];
}



- (void)netServiceDidResolveAddress:(NSNetService *)service {
    // Connect With Service
    NSLog(@"Deng: Connect With Service");
    if ([self connectWithService:service]) {
        NSLog(@"Did Connect with Service: domain(%@) type(%@) name(%@) port(%i)", [service domain], [service type], [service name], (int)[service port]);
    } else {
        NSLog(@"XXX: Unable to Connect with Service: domain(%@) type(%@) name(%@) port(%i)", [service domain], [service type], [service name], (int)[service port]);
    }
}



- (BOOL)connectWithService:(NSNetService *)service {
    BOOL _isConnected = NO;
 
    // Copy Service Addresses
    NSArray *addresses = [[service addresses] mutableCopy];
 
    if (!self.socket || ![self.socket isConnected]) {
        // Initialize Socket
        NSLog(@"Initialize Socket, 新建了 Socket");
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
 
        // Connect
        while (!_isConnected && [addresses count]) {
            NSData *address = [addresses objectAtIndex:0];
 
            NSError *error = nil;
            if ([self.socket connectToAddress:address error:&error]) {
                _isConnected = YES;
 
            } else if (error) {
                NSLog(@"Unable to connect to address. Error %@ with user info %@.", error, [error userInfo]);
            }
        }
 
    } else {
        _isConnected = [self.socket isConnected];
    }
 
    return _isConnected;
}





// 读数据
- (void)socket:(GCDAsyncSocket *)socket didConnectToHost:(NSString *)host port:(UInt16)port {
       NSLog(@"Socket Did Connect to Host: %@ Port: %hu", host, port);
    
       // Notify Delegate
       [self.delegate controller:self didJoinGameOnSocket:socket];
    
       // Stop Browsing
       [self stopBrowsing];
    
       // Dismiss View Controller
       [self dismissViewControllerAnimated:YES completion:nil];
}



/*
 
    When the socket has read the complete header preceding the packet data, it will invoke the socket:didReadData:withTag: delegate method. The tag that is passed is the same tag in the readDataToLength:withTimeout:tag: method.


 As you can see below, the implementation of the socket:didReadData:withTag: is surprisingly simple.
 
 
 
 If tag is equal to 0, we pass the data variable to parseHeader:, which returns the header, that is, the length of the packet that follows the header.
 
 
 We now know the size the encoded packet and we pass that information to readDataToLength:withTimeout:tag:.
 
 
 The timeout is set to 30 (seconds) and the last parameter, the tag, is set to 1.
 
 */





@end






/*
    Browsing Services
 
 
 
    To browse for services on the local network, we use the NSNetServiceBrowser class. Before putting the NSNetServiceBrowser class to use, we need to create a few private properties. Add a class extension to the MTJoinGameViewController class and declare three properties as shown below.
 
 
 
 The first property, socket of type GCDAsyncSocket, will store a reference to the socket that will be created when a network service resolves successfully.
 
 
 
 
 2
 
 The services property (NSMutableArray) will store all the services that the service browser discovers on the network. Every time the service browser finds a new service, it will notify us and we can add it to that mutable array. This array will also serve as the data source of the view controller's table view.


 The third property, serviceBrowser, is of type NSNetServiceBrowser and will search the network for network services that are of interest to us. Also note that the MTJoinGameViewController conforms to three protocols. This will become clear when we implement the methods of each of these protocols.
 
 */








// 操作流程， Mac App 开一个 host


// iOS app join 下， 点击 resolve , 就收到包了
