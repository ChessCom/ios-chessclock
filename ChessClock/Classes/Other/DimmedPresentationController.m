//
//  DimmedPresentationController.m
//  ChessClock
//
//  Created by Pedro Mancheno on 2017-05-03.
//  Copyright © 2017 Chess.com. All rights reserved.
//

#import "DimmedPresentationController.h"

static const CGFloat DimmedPresentationControllerAnimationDuration = 0.25f;

/**
 * Presents a view controller modally by superposing it's view on top of the
 * presenting's view, but retaining it's context.
 *
 * Useful for creating a modal presentation with a dimmed background.
 */

@implementation DimmedPresentationController

- (instancetype)init
{
    if (self = [super init]) {
        self.duration = DimmedPresentationControllerAnimationDuration;
    }
    
    return self;
}

- (void)presentViewController:(UIViewController *)willPresentViewController
           fromViewController:(UIViewController *)presentingViewController
        presentationAnimation:(DimmedPresentationAnimation)animation
{
    self.animation = animation;
    willPresentViewController.modalPresentationStyle = UIModalPresentationCustom;
    willPresentViewController.transitioningDelegate = self;
    willPresentViewController.modalPresentationCapturesStatusBarAppearance = YES;
    
    [willPresentViewController setNeedsStatusBarAppearanceUpdate];
    
    //this means the same controller is already pushed, lets skip this call then
    if ([presentingViewController.presentedViewController isKindOfClass:willPresentViewController.class]) {
        return;
    }
    [presentingViewController presentViewController:willPresentViewController
                                           animated:YES
                                         completion:nil];
}

- (void)presentViewController:(UIViewController *)presentedViewController
           fromViewController:(UIViewController *)presentingViewController
        presentationAnimation:(DimmedPresentationAnimation)animation
                     duration:(CGFloat)duration
{
    self.duration = duration;
    
    [self presentViewController:presentedViewController
             fromViewController:presentingViewController
          presentationAnimation:animation];
}

#pragma mark - UIViewController transition delegate

- (id <UIViewControllerAnimatedTransitioning> )animationControllerForPresentedController:(UIViewController *)presented

                                                                    presentingController:(UIViewController *)presenting
                                                                        sourceController:(UIViewController *)source
{
    self.isPresenting = YES;
    
    return self;
}

- (id <UIViewControllerAnimatedTransitioning> )animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.isPresenting = NO;
    
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning protocol

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning> )transitionContext
{
    return DimmedPresentationControllerAnimationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning> )transitionContext
{
    UIViewController *firstVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *secondVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    UIView *firstView = firstVC.view;
    UIView *secondView = secondVC.view;
    
    BOOL isBottomToTopAnimation = self.animation == DimmedPresentationAnimationBottomToTop;
    
    if (self.isPresenting) {
        [containerView addSubview:secondView];
        secondView.frame = (CGRect) {
            containerView.frame.origin.x,
            isBottomToTopAnimation ? containerView.frame.origin.y + containerView.frame.size.height : containerView.frame.origin.y,
            containerView.frame.size
        };
        
        secondView.alpha = isBottomToTopAnimation ? 1.f : 0.f;
        
        [UIView animateWithDuration:DimmedPresentationControllerAnimationDuration
                         animations: ^{
                             if (isBottomToTopAnimation) {
                                 secondView.frame = containerView.frame;
                             }
                             else {
                                 secondView.alpha = 1.f;
                             }
                         } completion: ^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                         }];
    }
    else {
        [UIView animateWithDuration:DimmedPresentationControllerAnimationDuration
                         animations: ^{
                             if (isBottomToTopAnimation) {
                                 firstView.frame = (CGRect) {
                                     containerView.frame.origin.x,
                                     containerView.frame.origin.y + containerView.frame.size.height,
                                     containerView.frame.size
                                 };
                             }
                             else {
                                 firstView.alpha = 0.f;
                             }
                         } completion: ^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                         }];
    }
}

@end
