//
//  CHTimePieceView.m
//  Chess.com
//
//  Created by Pedro Bolaños on 10/23/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import "CHTimePieceView.h"
#import "CHUtil.h"
#import "UIColor+ChessClock.h"
#import <QuartzCore/QuartzCore.h>

//------------------------------------------------------------------------------
#pragma mark - Private methods declarations
//------------------------------------------------------------------------------
@interface CHTimePieceView()

@property (assign, nonatomic) IBOutlet UIButton* timePieceButton;
@property (assign, nonatomic) IBOutlet UIView* timeStagesView;

@end

//------------------------------------------------------------------------------
#pragma mark - CHTimePieceView implementation
//------------------------------------------------------------------------------
@implementation CHTimePieceView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    BOOL isiPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    CGFloat fontSize = isiPad ? 200.0 : 90.0;
    
    if ([UIFont respondsToSelector:@selector(monospacedDigitSystemFontOfSize:weight:)])
    {
        self.availableTimeLabel.font = [UIFont monospacedDigitSystemFontOfSize:fontSize
                                                                        weight:UIFontWeightBold];
    }
    else
    {
        self.availableTimeLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    }
}

- (void)highlight
{
    self.availableTimeLabel.textColor = [UIColor whiteColor];    
    self.timePieceButton.userInteractionEnabled = YES;
    
    self.backgroundColor = [UIColor selectedTimePieceButtonColor];
}

- (void)unhighlightAndActivate:(BOOL)activate
{
    self.availableTimeLabel.textColor = [UIColor unselectedTimePieceTextColor];
    self.timePieceButton.userInteractionEnabled = activate;
    
    self.backgroundColor = [UIColor unselectedTimePieceButtonColor];
}

- (void)timeEnded
{
    self.availableTimeLabel.textColor = [UIColor whiteColor];
    self.timePieceButton.userInteractionEnabled = NO;

    self.backgroundColor = [UIColor timeEndedButtonColor];
}

- (void)setTimeControlStageDotCount:(NSUInteger)dotCount
{
    for (UIView* view in [self.timeStagesView subviews]) {
        [view removeFromSuperview];
    }
    
    if (dotCount == 1)
    {
        return;
    }
    
    UIImage* timeStageNotCompletedImage = [UIImage imageNamed:@"chessClock_timeStageNotCompleted"];
    CGSize timeStagesViewSize = self.timeStagesView.frame.size;
    CGFloat distanceBetweenDots = timeStageNotCompletedImage.size.width + 4.0f;
    float posX = timeStageNotCompletedImage.size.width * 0.5f;
    float posY = timeStagesViewSize.height * 0.5f;
    
    for (NSUInteger i = 0; i < dotCount; i++) {
        UIImageView* imageView = [[UIImageView alloc] initWithImage:timeStageNotCompletedImage];
        imageView.center = CGPointMake(posX, posY);
        [self.timeStagesView addSubview:imageView];
        
        posX += distanceBetweenDots;
    }
    
    // Select the first time stage by default
    [self updateTimeControlStage:1];
}

- (void)updateTimeControlStage:(NSUInteger)stageIndex
{
    NSArray* subviews = self.timeStagesView.subviews;
    if (stageIndex <= [subviews count]) {
        UIView* view = [self.timeStagesView.subviews objectAtIndex:stageIndex - 1];
        if ([view isKindOfClass:[UIImageView class]]) {
            UIImageView* imageView = (UIImageView*)view;
            UIImage* timeStageCompletedImage = [UIImage imageNamed:@"chessClock_timeStageCompleted"];
            imageView.image = timeStageCompletedImage;
        }
    }
}

@end
