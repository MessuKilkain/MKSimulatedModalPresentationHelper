//
//  UIViewController+MKSimulatedModalPresentationHelper.m
//

#import "UIViewController+MKSimulatedModalPresentationHelper.h"

#import "UIView+AutoLayout.h"

@implementation UIViewController(MKSimulatedModalPresentationHelper)

/// Returns NO is the dismiss has not been done, YES is the MKSimulatedModalPresentationHelper has handled the dismiss correctly
-(BOOL)dismissFromSimulatedModalPresentationHelper
{
    MKSimulatedModalPresentationHelper* mkView = nil;
    if( [self view] != nil )
    {
        if( [[self view] isKindOfClass:[MKSimulatedModalPresentationHelper class]] )
        {
            mkView = (MKSimulatedModalPresentationHelper*)[self view];
        }
        if(
           mkView == nil
           && [[self view] superview] != nil
           )
        {
            if( [[[self view] superview] isKindOfClass:[MKSimulatedModalPresentationHelper class]] )
            {
                mkView = (MKSimulatedModalPresentationHelper*)[[self view] superview];
            }
            if(
               mkView == nil
               && [[[self view] superview] superview] != nil
               )
            {
                if( [[[[self view] superview] superview] isKindOfClass:[MKSimulatedModalPresentationHelper class]] )
                {
                    // NOTE : it should be there
                    mkView = (MKSimulatedModalPresentationHelper*)[[[self view] superview] superview];
                }
            }
        }
    }
    if( mkView == nil )
    {
        return NO;
    }
    else if( [mkView containedController] != self )
    {
        return NO;
    }
    else
    {
        [mkView playAnimationHideWithCompletionBlock:^(BOOL finished) {
            if( finished )
            {
                [mkView removeContainedControllerIfNecessary];
                if( [mkView superview] != nil )
                {
                    [mkView removeFromSuperview];
                }
            }
        }];
        return YES;
    }
}

#pragma mark - Full view

-(MKSimulatedModalPresentationHelper*_Nullable)showController:(UIViewController*_Nonnull)controller
{
    return [self showController:controller inSubview:[self view] withHelper:nil usingSize:NO modalSize:CGSizeZero];
}

-(MKSimulatedModalPresentationHelper*_Nullable)showController:(UIViewController*_Nonnull)controller withHelper:(MKSimulatedModalPresentationHelper*_Nullable)helper
{
    return [self showController:controller inSubview:[self view] withHelper:helper usingSize:NO modalSize:CGSizeZero];
}

-(MKSimulatedModalPresentationHelper*_Nullable)showController:(UIViewController*_Nonnull)controller inSubview:(UIView*_Nonnull)subview
{
    return [self showController:controller inSubview:subview withHelper:nil usingSize:NO modalSize:CGSizeZero];
}

-(MKSimulatedModalPresentationHelper*_Nullable)showController:(UIViewController*_Nonnull)controller inSubview:(UIView*_Nonnull)subview withHelper:(MKSimulatedModalPresentationHelper*_Nullable)helper
{
    return [self showController:controller inSubview:subview withHelper:helper usingSize:NO modalSize:CGSizeZero];
}

#pragma mark - Specific size

-(MKSimulatedModalPresentationHelper*_Nullable)showController:(UIViewController*_Nonnull)controller modalSize:(CGSize)size
{
    return [self showController:controller inSubview:[self view] withHelper:nil usingSize:YES modalSize:size];
}

-(MKSimulatedModalPresentationHelper*_Nullable)showController:(UIViewController*_Nonnull)controller withHelper:(MKSimulatedModalPresentationHelper*_Nullable)helper modalSize:(CGSize)size
{
    return [self showController:controller inSubview:[self view] withHelper:helper usingSize:YES modalSize:size];
}

-(MKSimulatedModalPresentationHelper*_Nullable)showController:(UIViewController*_Nonnull)controller inSubview:(UIView*_Nonnull)subview modalSize:(CGSize)size
{
    return [self showController:controller inSubview:subview withHelper:nil usingSize:YES modalSize:size];
}

-(MKSimulatedModalPresentationHelper*_Nullable)showController:(UIViewController*_Nonnull)controller inSubview:(UIView*_Nonnull)subview withHelper:(MKSimulatedModalPresentationHelper*_Nullable)helper modalSize:(CGSize)size
{
    return [self showController:controller inSubview:subview withHelper:helper usingSize:YES modalSize:size];
}

#pragma mark - Common

-(MKSimulatedModalPresentationHelper*_Nullable)showController:(UIViewController*)controller inSubview:(UIView*)subview withHelper:(MKSimulatedModalPresentationHelper*_Nullable)helper usingSize:(BOOL)usingSize modalSize:(CGSize)size
{
    if(
       controller != nil
       && subview != nil
       && [subview isDescendantOfView:[self view]]
       )
    {
        MKSimulatedModalPresentationHelper* mkView = helper;
        if( mkView == nil )
        {
            mkView = [[MKSimulatedModalPresentationHelper alloc] init];
        }
        [mkView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [subview addSubview:mkView];
        [mkView pinToSuperviewEdges:(JRTViewPinAllEdges) inset:0];
        [[self view] layoutIfNeeded];
        
        [self addChildViewController:controller];
        if( usingSize )
        {
            [mkView setController:controller withPreferredSize:size];
        }
        else
        {
            [mkView setControllerFullView:controller];
        }
        [controller didMoveToParentViewController:self];
        
        [mkView playAnimationShowWithCompletionBlock:nil];
        [subview setNeedsFocusUpdate];
        return mkView;
    }
    else
    {
        return nil;
    }
}

@end
