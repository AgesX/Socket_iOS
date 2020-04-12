//
//  ViewController.m
//  oneOC
//
//  Created by Jz D on 2020/4/1.
//  Copyright © 2020 Jz D. All rights reserved.
//

#import "ViewController.h"

#import "JoinListController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}








- (IBAction)joinGame:(UIButton *)sender {
    
    
    
    // Initialize Join Game View Controller
       JoinListController *vc = [[JoinListController alloc] initWithStyle: UITableViewStylePlain];
    
       // Initialize Navigation Controller
       UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    
       // Present Navigation Controller
       [self presentViewController:nc animated:YES completion:nil];
    
    
    
    
    
    
    
    
    
}






@end
