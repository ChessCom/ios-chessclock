//
//  CHIncrementCell.m
//  ChessClock
//
//  Created by Pedro Bolaños on 6/27/17.
//  Copyright © 2017 Chess.com. All rights reserved.
//

#import "CHIncrementCell.h"

@implementation CHIncrementCell

- (IBAction)segmentControlValueChanged
{
    [self.delegate incrementCell:self changedToIncrementWithIndex:self.segmentedControl.selectedSegmentIndex];
}

@end
