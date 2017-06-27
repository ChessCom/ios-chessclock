//
//  CHTableViewCell.h
//  ChessClock
//
//  Created by Pedro Bolaños on 6/27/17.
//  Copyright © 2017 Chess.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHTableViewCell : UITableViewCell

- (void)setupStyle;
- (void)setupStyleWithShouldDuplicateSettings:(BOOL)shouldDuplicateSettings;

@end
