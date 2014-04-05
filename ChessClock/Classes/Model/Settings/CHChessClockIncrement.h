//
//  CHChessClockIncrement.h
//  Chess.com
//
//  Created by Pedro Bolaños on 10/24/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CHTimePiece;

@interface CHChessClockIncrement : NSObject

@property (assign, nonatomic) NSUInteger incrementValue;

- (id)initWithIncrementValue:(NSUInteger)incrementValue;

- (void)timePieceStarted:(CHTimePiece*)timePiece;
- (void)timePieceStopped:(CHTimePiece*)timePiece;
- (void)updateWithDelta:(NSTimeInterval)delta andTimePiece:(CHTimePiece*)timePiece;
- (NSString*)incrementDescription;

@end
