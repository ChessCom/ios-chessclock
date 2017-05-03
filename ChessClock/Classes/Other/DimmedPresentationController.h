//
//  DimmedPresentationController.h
//  ChessClock
//
//  Created by Pedro Mancheno on 2017-05-03.
//  Copyright © 2017 Chess.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    DimmedPresentationAnimationBottomToTop,
    DimmedPresentationAnimationFadeIn
} DimmedPresentationAnimation;


@interface DimmedPresentationController : NSObject <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

- (void)presentViewController:(UIViewController *)presentedViewController
           fromViewController:(UIViewController *)presentingViewController
        presentationAnimation:(DimmedPresentationAnimation)animation;

- (void)presentViewController:(UIViewController *)presentedViewController
           fromViewController:(UIViewController *)presentingViewController
        presentationAnimation:(DimmedPresentationAnimation)animation
                     duration:(CGFloat)duration;

@property (assign, nonatomic) BOOL isPresenting;
@property (assign, nonatomic) DimmedPresentationAnimation animation;
@property (assign, nonatomic) CGFloat duration;

@end
