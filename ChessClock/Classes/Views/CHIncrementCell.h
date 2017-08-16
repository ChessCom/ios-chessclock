//
//  CHIncrementCell.h
//  ChessClock
//
//  Created by Pedro Bolaños on 6/27/17.
//  Copyright © 2017 Chess.com. All rights reserved.
//

#import "CHTableViewCell.h"

//------------------------------------------------------------------------------
#pragma mark - CHIncrementCellDelegate
//------------------------------------------------------------------------------
@class CHIncrementCell;

@protocol CHIncrementCellDelegate <NSObject>

- (void)incrementCell:(CHIncrementCell*)cell changedToIncrementWithIndex:(NSUInteger)index;

@end

//------------------------------------------------------------------------------
#pragma mark - CHIncrementCell
//------------------------------------------------------------------------------
@interface CHIncrementCell : CHTableViewCell

@property (weak, nonatomic) id<CHIncrementCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel* descriptionLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl* segmentedControl;

@end
