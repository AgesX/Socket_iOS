//
//  TableViewController.h
//  oneOC
//
//  Created by Jz D on 2020/4/1.
//  Copyright © 2020 Jz D. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@class GCDAsyncSocket;
@protocol JoinGameViewControllerDelegate;
 
@interface JoinListController: UITableViewController
 
@property (weak, nonatomic) id<JoinGameViewControllerDelegate> delegate;
 
@end
 
@protocol JoinGameViewControllerDelegate


- (void)controller:(JoinListController *)controller didJoinGameOnSocket:(GCDAsyncSocket *)socket;
- (void)controllerDidCancelJoining:(JoinListController *)controller;


@end

NS_ASSUME_NONNULL_END
