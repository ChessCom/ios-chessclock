//
//  CHTimePieceView.h
//  Chess.com
//
//  Created by Pedro Bolaños on 10/23/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHTimePieceView : UIView

@property (assign, nonatomic) IBOutlet UILabel* availableTimeLabel;
@property (assign, nonatomic) IBOutlet UILabel* movesCountLabel;

- (void)highlight;
- (void)unhighlightAndActivate:(BOOL)activate;
- (void)timeEnded;
- (void)setTimeControlStageDotCount:(NSUInteger)dotCount;
- (void)updateTimeControlStage:(NSUInteger)stageIndex;

@end
