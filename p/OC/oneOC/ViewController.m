//
//  ViewController.m
//  oneOC
//
//  Created by Jz D on 2020/4/1.
//  Copyright © 2020 Jz D. All rights reserved.
//

#import "ViewController.h"


#import "BoardCell.h"

#import "GameManager.h"
#import "HostViewController.h"
#import "JoinListController.h"

#import "Constants.h"


#define kMTMatrixWidth 7
#define kMTMatrixHeight 6



@interface ViewController ()<HostGameViewControllerDelegate, JoinGameViewControllerDelegate, GameManagerProxy>


@property (strong, nonatomic) GameManager * gameManager;


@property (weak, nonatomic) IBOutlet UIButton *hostBtn;
@property (weak, nonatomic) IBOutlet UIButton *joinBtn;
@property (weak, nonatomic) IBOutlet UIButton *disconnectBtn;



@property (weak, nonatomic) IBOutlet UIView *boardView;

@property (weak, nonatomic) IBOutlet UIButton *replayButton;


@property (weak, nonatomic) IBOutlet UILabel *gameStateLabel;

@property (assign, nonatomic) GameState gameState;


// 数据，未更改
@property (strong, nonatomic) NSArray<NSArray * > * board;


// 数据，已经更改
@property (strong, nonatomic) NSMutableArray<NSMutableArray *> * matrix;


@end

@implementation ViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Setup View
    [self setupView];
    
    self.boardView.layer.borderColor = UIColor.blueColor.CGColor;
    self.boardView.layer.borderWidth = 1;
}





- (void)setupView {
    // Reset Game
    [self resetGame];
 
    // Configure Subviews
    [self.boardView setHidden:YES];
    [self.replayButton setHidden:YES];
    [self.disconnectBtn setHidden:YES];
    [self.gameStateLabel setHidden:YES];
    
    
    // Add Tap Gesture Recognizer
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addDiscToColumn:)];
    [self.boardView addGestureRecognizer:tgr];
}



- (void)addDiscToColumn:(UITapGestureRecognizer *)tgr {
    if (self.gameState >= GameStateIWin) {
        //  GameStateYourOpponentWin,    GameStateIWin
        
        // Notify Players
        [self showWinner];
 
    } else if (self.gameState != GameStateMyTurn) {
        
        //  GameStateYourOpponentTurn
        
        
        // Show Alert
        UIAlertController * alert = [UIAlertController alertControllerWithTitle: @"It's not your turn." message: @"Warning 不啊" preferredStyle: UIAlertControllerStyleAlert];
                                  
        UIAlertAction * ok = [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated: YES completion:^{
            }];
        }];
                                  
        [alert addAction: ok];
        [self presentViewController: alert animated: YES completion:^{
            
        }];
 
    } else {
        //  GameStateMyTurn
        
        
        // 计算出了，哪一列
        // 哪一行，怎么算
        NSInteger column = [self columnForPoint:[tgr locationInView: tgr.view]];
        
        
        // MD
        [self addDiscToColumn:column withType: BoardCellTypeMine];
 // 这里是落子了，去更新状态
        // Update Game State
        // 自己操作处理了
        self.gameState = GameStateYourOpponentTurn;
        
        
        // 把消息，告知对方
        
        // Send Packet
        [self.gameManager addDiscToColumn:column];
        
        // Notify Players if Someone Has Won the Game
        
        // Notify Players if Someone Has Won the Game
        if ([self hasPlayerOfTypeWon: PlayerTypeMe]) {
            // Show Winner
            [self showWinner];
        }
    }
}



- (void)showWinner {
    if (self.gameState < GameStateIWin){
        return;
    }
 
    // Show Replay Button
    [self.replayButton setHidden:NO];
 
    NSString *message = nil;
 
    if (self.gameState == GameStateIWin) {
        message = @"赢啦 ✌️ - You have won the game.";
    } else if (self.gameState == GameStateYourOpponentWin) {
        message = @"你 gg 了，Your opponent has won the game.";
    }
 
    // Show Alert
    UIAlertController * alert = [UIAlertController alertControllerWithTitle: @"We Have a Winner" message: message preferredStyle: UIAlertControllerStyleAlert];
                              
    UIAlertAction * ok = [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
                              
    [alert addAction: ok];
    [self presentViewController: alert animated: YES completion:^{
    }];
    
}




/*
    The columnForPoint:

 method


 is nothing more than a simple calculation


 to infer the column based on the coordinates of point.
 
 
 */

- (NSInteger)columnForPoint:(CGPoint)point {
    return floorf(point.x / floorf(self.boardView.frame.size.width / kMTMatrixWidth));
}





- (void)addDiscToColumn:(NSInteger)column withType:(BoardCellType)cellType {
    // Update Matrix
    NSMutableArray *columnArray = [self.matrix objectAtIndex:column];
    [columnArray addObject: @(cellType)];
 
    // Update Cells
    BoardCell *cell = [[self.board objectAtIndex:column] objectAtIndex: (columnArray.count - 1)];
    cell.cellType = cellType;
    
}

/*
    Because we overrode the setCellType: method in MTBoardCell, the board cell's background color will be updated automatically.
 
 
 // 感觉是，五子棋
 
 */



- (BOOL)hasPlayerOfTypeWon: (PlayerType) playerType {
    BOOL _hasWon = NO;
    NSInteger _counter = 0;
    BoardCellType targetType = BoardCellTypeYours;
    if (playerType == PlayerTypeMe){
        targetType = BoardCellTypeMine;
    }
 
    // Check Vertical Matches
    // 竖着来
    for (NSArray *line in self.board) {
        _counter = 0;
 
        for (BoardCell *cell in line) {
            _counter = (cell.cellType == targetType) ? _counter + 1 : 0;
            _hasWon = (_counter > 3) ? YES : _hasWon;
 
            if (_hasWon){
                break;
            }
        }
 
        if (_hasWon){
            break;
        }
    }
 
    if (!_hasWon) {
        // Check Horizontal Matches
        for (int i = 0; i < kMTMatrixHeight; i++) {
            _counter = 0;
 
            for (int j = 0; j < kMTMatrixWidth; j++) {
                BoardCell *cell = [(NSArray *)[self.board objectAtIndex:j] objectAtIndex:i];
                _counter = (cell.cellType == targetType) ? _counter + 1 : 0;
                _hasWon = (_counter > 3) ? YES : _hasWon;
 
                if (_hasWon) break;
            }
 
            if (_hasWon) break;
        }
    }
 
    if (!_hasWon) {
        // Check Diagonal Matches
        //  对角线
        //  - First Pass
        for (int i = 0; i < kMTMatrixWidth; i++) {
            _counter = 0;
 
            // Forward
            for (int j = i, row = 0; j < kMTMatrixWidth && row < kMTMatrixHeight; j++, row++) {
                BoardCell *cell = [(NSArray *)[self.board objectAtIndex:j] objectAtIndex:row];
                _counter = (cell.cellType == targetType) ? _counter + 1 : 0;
                _hasWon = (_counter > 3) ? YES : _hasWon;
 
                if (_hasWon) break;
            }
 
            if (_hasWon) break;
 
            _counter = 0;
 
            // Backward
            for (int j = i, row = 0; j >= 0 && row < kMTMatrixHeight; j--, row++) {
                BoardCell *cell = [(NSArray *)[self.board objectAtIndex:j] objectAtIndex:row];
                _counter = (cell.cellType == targetType) ? _counter + 1 : 0;
                _hasWon = (_counter > 3) ? YES : _hasWon;
 
                if (_hasWon) break;
            }
 
            if (_hasWon) break;
        }
    }
 
    if (!_hasWon) {
        // Check Diagonal Matches - Second Pass
        for (int i = 0; i < kMTMatrixWidth; i++) {
            _counter = 0;
 
            // Forward
            for (int j = i, row = (kMTMatrixHeight - 1); j < kMTMatrixWidth && row >= 0; j++, row--) {
                BoardCell *cell = [(NSArray *)[self.board objectAtIndex:j] objectAtIndex:row];
                _counter = (cell.cellType == targetType) ? _counter + 1 : 0;
                _hasWon = (_counter > 3) ? YES : _hasWon;
 
                if (_hasWon) break;
            }
 
            if (_hasWon) break;
 
            _counter = 0;
 
            // Backward
            for (int j = i, row = (kMTMatrixHeight - 1); j >= 0 && row >= 0; j--, row--) {
                BoardCell *cell = [(NSArray *)[self.board objectAtIndex:j] objectAtIndex:row];
                _counter = (cell.cellType == targetType) ? _counter + 1 : 0;
                _hasWon = (_counter > 3) ? YES : _hasWon;
 
                if (_hasWon) break;
            }
 
            if (_hasWon) break;
        }
    }
 
    // Update Game State
    if (_hasWon) {
        self.gameState = GameStateYourOpponentWin;
        if (playerType == PlayerTypeMe){
            self.gameState = GameStateIWin;
        }
    }
 
    return _hasWon;
}







- (void)startGameWithSocket:(GCDAsyncSocket *)socket {
    // Initialize Game Controller
    self.gameManager = [[GameManager alloc] initWithSocket:socket];
 
    // Configure Game Controller
    self.gameManager.delegate = self;
 
    // Hide/Show Buttons
    [self.boardView setHidden:NO];
    [self.hostBtn setHidden:YES];
    [self.joinBtn setHidden:YES];
    [self.disconnectBtn setHidden:NO];

    [self.gameStateLabel setHidden:NO];
}






- (void)resetGame {
    for (NSArray * eles in self.board) {
        for (UIView * v in eles){
            [v removeFromSuperview];
        }
    }
    self.board = nil;
    self.matrix = nil;
    
    // Hide Replay Button
    [self.replayButton setHidden:YES];
 
    
    
    
    // Helpers
    CGSize size = self.boardView.frame.size;
    CGFloat cellWidth = floorf(size.width / kMTMatrixWidth);
    CGFloat cellHeight = floorf(size.height / kMTMatrixHeight);
    NSMutableArray *buffer = [[NSMutableArray alloc] initWithCapacity:kMTMatrixWidth];
 
    for (int i = 0; i < kMTMatrixWidth; i++) {
        NSMutableArray *column = [[NSMutableArray alloc] initWithCapacity: kMTMatrixHeight];
        //  board 数组里面， 都是一列一列的纵向的数据
        for (int j = 0; j < kMTMatrixHeight; j++) {
            CGRect frame = CGRectMake(i * cellWidth, (size.height - ((j + 1) * cellHeight)), cellWidth, cellHeight);
            BoardCell *cell = [[BoardCell alloc] initWithFrame:frame];
            [cell setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
            [self.boardView addSubview:cell];
            [column addObject:cell];
        }
 
        [buffer addObject: column.copy];
    }
 
    // Initialize Board
    self.board = buffer.copy;
 
    // Initialize Matrix
    self.matrix = [[NSMutableArray alloc] initWithCapacity:kMTMatrixWidth];
 
    for (int i = 0; i < kMTMatrixWidth; i++) {
        NSMutableArray *column = [[NSMutableArray alloc] initWithCapacity:kMTMatrixHeight];
        [self.matrix addObject:column];
    }
}






- (IBAction)hostGame:(UIButton *)sender {
    
    
    // Initialize Host Game View Controller
       HostViewController *vc = [[HostViewController alloc] init];
    
       // Configure Host Game View Controller
       vc.delegate = self;
    
       // Initialize Navigation Controller
       UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    
       // Present Navigation Controller
       [self presentViewController:nc animated:YES completion:nil];
    
    
    
}








- (IBAction)joinGame:(UIButton *)sender {
    
    
    
    // Initialize Join Game View Controller
       JoinListController *vc = [[JoinListController alloc] initWithStyle:UITableViewStylePlain];
    
       // Configure Join Game View Controller
      vc.delegate = self;
    
       // Initialize Navigation Controller
       UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    
       // Present Navigation Controller
       [self presentViewController:nc animated:YES completion:nil];
    
    
    
}






- (IBAction)disconnectIt:(UIButton *)sender {
    
    
    
    [self endGame];
    
}



- (IBAction)replayGame:(UIButton *)sender {
    
    
    // Reset Game
       [self resetGame];
    
       // Update Game State
       self.gameState = GameStateMyTurn;
    
    
      // 提示对手
      // Notify Opponent of New Game
       [self.gameManager startNewGame];
    
}







///


- (void)managerDidStartNewGame: (GameManager *) manager {
    // Reset Game
    [self resetGame];
 
    // Update Game State
    self.gameState = GameStateYourOpponentTurn;
}





- (void)managerDidDisconnect:(GameManager *) manager {
    NSLog(@"%s", __PRETTY_FUNCTION__);
 
    // End Game
    [self endGame];
}



// 收到了，对方的操作
- (void)manager:(GameManager *)manager didAddDiscToColumn:(NSInteger)column {
    // Update Game
    [self addDiscToColumn:column withType: BoardCellTypeYours];
 
    
    
     if([self hasPlayerOfTypeWon: PlayerTypeYou]) {
            // Show Winner
            [self showWinner];

       }else{
             // Update State
             self.gameState = GameStateMyTurn;
       }
}


- (void)endGame {
    // Clean Up
    self.gameManager.delegate = nil;
    self.gameManager = nil;
    
    // Hide/Show Buttons
     [self.boardView setHidden:YES];
   [self.hostBtn setHidden:NO];
   [self.joinBtn setHidden:NO];
   [self.disconnectBtn setHidden:YES];

    [self.gameStateLabel setHidden:YES];
}




#pragma mark -
#pragma mark Host Game View Controller Methods

/*
 We simply update the gameState property in the controller:didHostGameOnSocket: and controller:didJoinGameOnSocket: delegate methods.
 
 
 The result is that only the player hosting the game can add a disc to the board.
 
 */


// 联机，游戏大战



- (void)controller:(HostViewController *)controller didHostGameOnSocket:(GCDAsyncSocket *)socket{
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
// 这里是轮到他落子了
    // 发起操作
    // Update Game State
    self.gameState = GameStateMyTurn;
    
    // Start Game with Socket
    [self startGameWithSocket:socket];
    
    //  NSLog(@"testConnection 来没");
    // Test Connection
    //  [self.gameManager testConnection];
}



- (void)controllerDidCancelHosting:(HostViewController *)controller{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    
}


 
#pragma mark -
#pragma mark Join Game View Controller Methods


- (void)controller:(JoinListController *)controller didJoinGameOnSocket:(GCDAsyncSocket *)socket{
    NSLog(@"%s", __PRETTY_FUNCTION__);
// 这里是轮到他落子了
    // 发起操作
    // Update Game State
    self.gameState = GameStateYourOpponentTurn;
    
    
    // Start Game with Socket
    [self startGameWithSocket:socket];
}




- (void)controllerDidCancelJoining:(JoinListController *)controller{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    
}



- (void)setGameState: (GameState) gameState {
    if (_gameState != gameState) {
        _gameState = gameState;
 
        // Update View
        [self updateView];
    }
}




- (void)updateView {
    // Update Game State Label
    switch (self.gameState) {
        case GameStateMyTurn: {
            self.gameStateLabel.text = @"It is your turn.";
            break;
        }
        case GameStateYourOpponentTurn: {
            self.gameStateLabel.text = @"It is your opponent's turn.";
            break;
        }
        case GameStateIWin: {
            self.gameStateLabel.text = @"You have won.";
            break;
        }
        case GameStateYourOpponentWin: {
            self.gameStateLabel.text = @"Your opponent has won.";
            break;
        }
        default: {
            self.gameStateLabel.text = nil;
            break;
        }
    }
}



@end
