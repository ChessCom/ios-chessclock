//
//  CHChessClockViewController.h
//  Chess.com
//
//  Created by Pedro Bolaños on 10/22/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CHChessClockSettingsManager;
@class CHTimePieceView;

@interface CHChessClockViewController : UIViewController

@property (retain, nonatomic) CHChessClockSettingsManager* settingsManager;

@end
