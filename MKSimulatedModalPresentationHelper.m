//
//  MKSimulatedModalPresentationHelper.m
//

#import "MKSimulatedModalPresentationHelper.h"

#import "UIViewController+MKSimulatedModalPresentationHelper.h"

#import "UIView+AutoLayout.h"

@interface MKSimulatedModalPresentationHelper()

@property (nonatomic) BOOL shouldBeDisplayed;

@property (nonatomic) BOOL internalDismissFromBackgroundControlAllowed;

@property (nonatomic) BOOL internalUseBlurEffect;
@property (nonatomic) UIBlurEffectStyle internalBlurEffectStyle;
@property (nonatomic) CGPoint internalAnimation_Displayed_Center;
@property (nonatomic, strong) UIColor* internalBackgroundControlColor;

#pragma mark - Constraints

@property (nonatomic, weak) NSLayoutConstraint* containedControllerParentView_Constraint_CenterX;
@property (nonatomic, weak) NSLayoutConstraint* containedControllerParentView_Constraint_CenterY;
@property (nonatomic, weak) NSLayoutConstraint* containedControllerParentView_Constraint_Width;
@property (nonatomic, weak) NSLayoutConstraint* containedControllerParentView_Constraint_Height;

#pragma mark - Subviews

@property (nonatomic, weak) UIView* backgroundBlurView;

@property (nonatomic, weak) UIControl* backgroundControl;

@property (nonatomic, weak) UIView* containedControllerParentView;

@property (nonatomic, weak) UIViewController* containedController;

#if TARGET_OS_TV
@property (nonatomic, weak) UITapGestureRecognizer* menuTapGestureRecognizer;
#endif

@end

@implementation MKSimulatedModalPresentationHelper

#pragma mark - Fake Properties

-(void)setAnimation_Displayed_Center:(CGPoint)newDisplayCenter
{
    [self setInternalAnimation_Displayed_Center:newDisplayCenter];
    if( [self containedControllerParentView_Constraint_CenterX] != nil )
    {
        [[self containedControllerParentView_Constraint_CenterX] setConstant:[self animation_Displayed_Center].x];
    }
    if( [self containedControllerParentView_Constraint_CenterY] != nil )
    {
        [[self containedControllerParentView_Constraint_CenterY] setConstant:[self animation_Displayed_Center].y];
    }
}
-(CGPoint)animation_Displayed_Center
{
    return [self internalAnimation_Displayed_Center];
}

-(void)setUseBlurEffect:(BOOL)shouldUseBlurEffect
{
    [self setInternalUseBlurEffect:shouldUseBlurEffect];
    [self initSubviewsIfNecessary];
    if( [self backgroundBlurView] != nil )
    {
        [[self backgroundBlurView] setHidden:(![self useBlurEffect])&&[self shouldBeDisplayed]];
    }
}
-(BOOL)useBlurEffect
{
    return [self internalUseBlurEffect];
}
-(void)setBlurEffectStyle:(UIBlurEffectStyle)newBlurEffectStyle
{
    UIBlurEffectStyle oldBlurEffectStyle = [self blurEffectStyle];
    [self setInternalBlurEffectStyle:newBlurEffectStyle];
    if( oldBlurEffectStyle != [self blurEffectStyle] )
    {
        if( [self backgroundBlurView] != nil )
        {
            if( [[self backgroundBlurView] superview] != nil )
            {
                [[self backgroundBlurView] removeFromSuperview];
            }
            [self setBackgroundBlurView:nil];
        }
        // NOTE : we force the blur effect view to be recreated
        [self initSubviewsIfNecessary];
    }
}
-(UIBlurEffectStyle)blurEffectStyle
{
    return [self internalBlurEffectStyle];
}

-(void)setBackgroundControlColor:(UIColor*_Nonnull)newBackgroundControlColor
{
    if( newBackgroundControlColor != nil )
    {
        [self setInternalBackgroundControlColor:newBackgroundControlColor];
        if( [self backgroundControl] != nil )
        {
            [[self backgroundControl] setBackgroundColor:[self backgroundControlColor]];
        }
    }
}
-(UIColor*_Nonnull)backgroundControlColor
{
    return [self internalBackgroundControlColor];
}

#pragma mark - Init methods

-(instancetype)init
{
    self = [super init];
    if( self )
    {
        [self commonInit];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if( self )
    {
        [self commonInit];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self commonInit];
}

-(void)commonInit
{
    [self setAnimation_Hidden_Alpha:0.0];
    [self setAnimation_Hidden_Center:CGPointMake(0, 0)];
    
    // [self setAnimation_Displayed_Alpha:1.0];
    [self setAnimation_Displayed_Center:CGPointMake(0, 0)];
    
    [self setAnimation_Hide_Duration:0.3];
    [self setAnimation_Show_Duration:0.3];
    
    [self setBackgroundControlColor:[UIColor clearColor]];
    
    [self setDismissFromBackgroundControlAllowed:YES];
    [self setDismissFromMenuTapAllowed:YES];
}

-(void)initSubviewsIfNecessary
{
#if TARGET_OS_TV
    // menuTapGestureRecognizer for tvOS
    if( [self menuTapGestureRecognizer] == nil )
    {
        // Add a tap gesture recognizer to handle MENU presses.
        UITapGestureRecognizer *menuTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMenuTap:)];
        [self setMenuTapGestureRecognizer:menuTapGestureRecognizer];
        [menuTapGestureRecognizer setAllowedPressTypes:@[@(UIPressTypeMenu)]];
        [self addGestureRecognizer:menuTapGestureRecognizer];
    }
#endif
    // backgroundBlurView
    if( [self backgroundBlurView] == nil )
    {
        // If the system is at least iOS 8.0
        if( [[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending )
        {
            if( !UIAccessibilityIsReduceTransparencyEnabled() )
            {
                UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:[self blurEffectStyle]];
                UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
                [blurEffectView setTranslatesAutoresizingMaskIntoConstraints:NO];
                [self addSubview:blurEffectView];
                [blurEffectView pinToSuperviewEdges:(JRTViewPinAllEdges) inset:0];
                [self setBackgroundBlurView:blurEffectView];
                [blurEffectView setHidden:(![self useBlurEffect])&&[self shouldBeDisplayed]];
            }
        }
    }
    if( [self backgroundBlurView] != nil )
    {
        [self bringSubviewToFront:[self backgroundBlurView]];
    }
    // backgroundControl
    if( [self backgroundControl] == nil )
    {
        UIControl* backgroundControl = [UIControl autoLayoutView];
        [self setBackgroundControl:backgroundControl];
        [self addSubview:backgroundControl];
        [backgroundControl setUserInteractionEnabled:[self isDismissFromBackgroundControlAllowed]];
        [backgroundControl pinToSuperviewEdges:(JRTViewPinAllEdges) inset:0];
#if !TARGET_OS_TV
        [backgroundControl addTarget:self action:@selector(backgroundControlTriggered) forControlEvents:(UIControlEventTouchUpInside)];
#else
        [backgroundControl addTarget:self action:@selector(backgroundControlTriggered) forControlEvents:(UIControlEventPrimaryActionTriggered)];
#endif
        [backgroundControl setBackgroundColor:[self backgroundControlColor]];
    }
    if( [self backgroundControl] != nil )
    {
        [self bringSubviewToFront:[self backgroundControl]];
    }
    if( [self containedControllerParentView] == nil )
    {
        UIView* containedControllerParentView = [UIView autoLayoutView];
        [self setContainedControllerParentView:containedControllerParentView];
        [self addSubview:containedControllerParentView];
        [self setContainedControllerParentView_Constraint_CenterX:[containedControllerParentView centerInContainerOnAxis:(NSLayoutAttributeCenterX)]];
        [self setContainedControllerParentView_Constraint_CenterY:[containedControllerParentView centerInContainerOnAxis:(NSLayoutAttributeCenterY)]];
    }
    if( [self containedControllerParentView] != nil )
    {
        [self bringSubviewToFront:[self containedControllerParentView]];
    }
}

#pragma mark - Dismiss methods

#if TARGET_OS_TV
- (void)handleMenuTap:(UITapGestureRecognizer *)sender
{
    NSLog(@"handleMenuTap ENTER : %@",sender);
    if(
       [self containedController] != nil
       && [self isDismissFromMenuTapAllowed]
       )
    {
        [[self containedController] dismissFromSimulatedModalPresentationHelper];
    }
}
#endif

-(void)backgroundControlTriggered
{
    // NSLog(@"backgroundControlTriggered : ENTER");
    if(
       [self containedController] != nil
       && [self isDismissFromBackgroundControlAllowed]
       )
    {
        [[self containedController] dismissFromSimulatedModalPresentationHelper];
    }
}

-(BOOL)isDismissFromBackgroundControlAllowed
{
    return [self internalDismissFromBackgroundControlAllowed];
}
-(void)setDismissFromBackgroundControlAllowed:(BOOL)dismissFromBackgroundControlAllowed
{
    [self setInternalDismissFromBackgroundControlAllowed:dismissFromBackgroundControlAllowed];
    if(
       [self backgroundControl] != nil
       && [self shouldBeDisplayed] // NOTE : Change user interaction enability if the control should be shown
       )
    {
        [[self backgroundControl] setUserInteractionEnabled:[self isDismissFromBackgroundControlAllowed]];
    }
}

#pragma mark - Contained controller

-(UIViewController* _Nullable)removeContainedControllerIfNecessary
{
    UIViewController* oldContainedController = [self containedController];
    if( [self containedController] != nil )
    {
        BOOL shouldRemoveControllerFromParentViewController = ( [[self containedController] parentViewController] != nil );
        if( shouldRemoveControllerFromParentViewController )
        {
            [[self containedController] willMoveToParentViewController:nil];
        }
        if(
           [[self containedController] view] != nil
           && [[[self containedController] view] superview] != nil
           )
        {
            [[[self containedController] view] removeFromSuperview];
        }
        if( shouldRemoveControllerFromParentViewController )
        {
            [[self containedController] removeFromParentViewController];
        }
        [self setContainedController:nil];
    }
    return oldContainedController;
}

-(void)setControllerFullView:(UIViewController* _Nonnull)controller
{
    [self removeContainedControllerIfNecessary];
    [self initSubviewsIfNecessary];
    if( [self containedControllerParentView] != nil )
    {
        // We remove old constraints if necessary
        if( [self containedControllerParentView_Constraint_Width] != nil )
        {
            [self removeConstraint:[self containedControllerParentView_Constraint_Width]];
            [self setContainedControllerParentView_Constraint_Width:nil];
        }
        if( [self containedControllerParentView_Constraint_Height] != nil )
        {
            [self removeConstraint:[self containedControllerParentView_Constraint_Height]];
            [self setContainedControllerParentView_Constraint_Height:nil];
        }
        // Width Constraint
        {
            NSLayoutConstraint* widthConstraint =
            [NSLayoutConstraint
             constraintWithItem:self
             attribute:(NSLayoutAttributeWidth)
             relatedBy:(NSLayoutRelationEqual)
             toItem:[self containedControllerParentView]
             attribute:(NSLayoutAttributeWidth)
             multiplier:1.0
             constant:0
             ];
            [self addConstraint:widthConstraint];
            [self setContainedControllerParentView_Constraint_Width:widthConstraint];
        }
        // Height Constraint
        {
            NSLayoutConstraint* heightConstraint =
            [NSLayoutConstraint
             constraintWithItem:self
             attribute:(NSLayoutAttributeHeight)
             relatedBy:(NSLayoutRelationEqual)
             toItem:[self containedControllerParentView]
             attribute:(NSLayoutAttributeHeight)
             multiplier:1.0
             constant:0
             ];
            [self addConstraint:heightConstraint];
            [self setContainedControllerParentView_Constraint_Height:heightConstraint];
        }
        if(
           controller != nil
           && [controller view]
           )
        {
            //NSLog(@"controller : %@",[controller description]);
            [self setContainedController:controller];
            [[controller view] setTranslatesAutoresizingMaskIntoConstraints:NO];
            [[self containedControllerParentView] addSubview:[controller view]];
            [[controller view] pinToSuperviewEdges:(JRTViewPinAllEdges) inset:0];
        }
    }
}

-(void)setController:(UIViewController* _Nonnull)controller withPreferredSize:(CGSize)size
{
    [self removeContainedControllerIfNecessary];
    [self initSubviewsIfNecessary];
    if( [self containedControllerParentView] != nil )
    {
        // We remove old constraints if necessary
        if( [self containedControllerParentView_Constraint_Width] != nil )
        {
            [self removeConstraint:[self containedControllerParentView_Constraint_Width]];
            [self setContainedControllerParentView_Constraint_Width:nil];
        }
        if( [self containedControllerParentView_Constraint_Height] != nil )
        {
            [self removeConstraint:[self containedControllerParentView_Constraint_Height]];
            [self setContainedControllerParentView_Constraint_Height:nil];
        }
        // Width Constraint
        {
            NSLayoutConstraint* widthConstraint =
            [NSLayoutConstraint
             constraintWithItem:[self containedControllerParentView]
             attribute:(NSLayoutAttributeWidth)
             relatedBy:(NSLayoutRelationEqual)
             toItem:nil
             attribute:(NSLayoutAttributeNotAnAttribute)
             multiplier:1.0
             constant:size.width
             ];
            [widthConstraint setPriority:(UILayoutPriorityRequired-1)];
            [self addConstraint:widthConstraint];
            [self setContainedControllerParentView_Constraint_Width:widthConstraint];
        }
        // Height Constraint
        {
            NSLayoutConstraint* heightConstraint =
            [NSLayoutConstraint
             constraintWithItem:[self containedControllerParentView]
             attribute:(NSLayoutAttributeHeight)
             relatedBy:(NSLayoutRelationEqual)
             toItem:nil
             attribute:(NSLayoutAttributeNotAnAttribute)
             multiplier:1.0
             constant:size.height
             ];
            [heightConstraint setPriority:(UILayoutPriorityRequired-1)];
            [self addConstraint:heightConstraint];
            [self setContainedControllerParentView_Constraint_Height:heightConstraint];
        }
        if(
           controller != nil
           && [controller view]
           )
        {
            [self setContainedController:controller];
            [[controller view] setTranslatesAutoresizingMaskIntoConstraints:NO];
            [[self containedControllerParentView] addSubview:[controller view]];
            [[controller view] pinToSuperviewEdges:(JRTViewPinAllEdges) inset:0];
        }
    }
}

#pragma mark - Animations

-(void)playAnimationShowWithCompletionBlock:(void (^ __nullable)(BOOL finished))completion
{
    [self setShouldBeDisplayed:YES];
    if( [self backgroundControl] != nil )
    {
        [[self backgroundControl] setUserInteractionEnabled:[self isDismissFromBackgroundControlAllowed]];
    }
    if( [self containedControllerParentView] != nil )
    {
        [[self containedControllerParentView] setUserInteractionEnabled:YES];
    }
    if( [self animation_Show_Duration] > 0 )
    {
        if( [self containedControllerParentView_Constraint_CenterX] != nil )
        {
            [[self containedControllerParentView_Constraint_CenterX] setConstant:[self animation_Hidden_Center].x];
        }
        if( [self containedControllerParentView_Constraint_CenterY] != nil )
        {
            [[self containedControllerParentView_Constraint_CenterY] setConstant:[self animation_Hidden_Center].y];
        }
        if( [self backgroundControl] != nil )
        {
            [[self backgroundControl] setAlpha:0.0];
            [[self backgroundControl] setEnabled:YES];
        }
        if( [self containedControllerParentView] != nil )
        {
            [[self containedControllerParentView] setAlpha:0.0];
        }
        if( nil != [self superview] )
        {
            [[self superview] layoutIfNeeded];
        }
        __weak __typeof(self) weakSelf = self;
        [UIView
         animateWithDuration:[self animation_Show_Duration]
         animations:^{
             if( weakSelf != nil )
             {
                 __strong __typeof(weakSelf) strongSelf = weakSelf;
                 if( [strongSelf containedControllerParentView_Constraint_CenterX] != nil )
                 {
                     [[strongSelf containedControllerParentView_Constraint_CenterX] setConstant:[strongSelf animation_Displayed_Center].x];
                 }
                 if( [strongSelf containedControllerParentView_Constraint_CenterY] != nil )
                 {
                     [[strongSelf containedControllerParentView_Constraint_CenterY] setConstant:[strongSelf animation_Displayed_Center].y];
                 }
                 if( [strongSelf backgroundBlurView] != nil )
                 {
                     [[strongSelf backgroundBlurView] setHidden:NO];
                 }
                 if( [strongSelf backgroundControl] != nil )
                 {
                     [[strongSelf backgroundControl] setAlpha:1.0];
                 }
                 if( [strongSelf containedControllerParentView] != nil )
                 {
                     [[strongSelf containedControllerParentView] setAlpha:1.0];
                 }
                 if( [strongSelf backgroundBlurView] != nil )
                 {
                     [[strongSelf backgroundBlurView] setHidden:![strongSelf useBlurEffect]];
                 }
                 if( nil != [strongSelf superview] )
                 {
                     [[strongSelf superview] layoutIfNeeded];
                 }
             }
         }
         completion:completion
         ];
    }
    else
    {
        if( [self containedControllerParentView_Constraint_CenterX] != nil )
        {
            [[self containedControllerParentView_Constraint_CenterX] setConstant:[self animation_Displayed_Center].x];
        }
        if( [self containedControllerParentView_Constraint_CenterY] != nil )
        {
            [[self containedControllerParentView_Constraint_CenterY] setConstant:[self animation_Displayed_Center].y];
        }
        if( [self backgroundBlurView] != nil )
        {
            [[self backgroundBlurView] setHidden:NO];
        }
        if( [self backgroundControl] != nil )
        {
            [[self backgroundControl] setAlpha:1.0];
            [[self backgroundControl] setEnabled:YES];
        }
        if( [self containedControllerParentView] != nil )
        {
            [[self containedControllerParentView] setAlpha:1.0];
        }
        if( [self backgroundBlurView] != nil )
        {
            [[self backgroundBlurView] setHidden:![self useBlurEffect]];
        }
        if( nil != [self superview] )
        {
            [[self superview] layoutIfNeeded];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if( completion != nil )
            {
                completion(YES);
            }
        });
    }
}
-(void)playAnimationHideWithCompletionBlock:(void (^ __nullable)(BOOL finished))completion
{
    [self setShouldBeDisplayed:NO];
    if( [self backgroundControl] != nil )
    {
        [[self backgroundControl] setUserInteractionEnabled:NO];
    }
    if( [self containedControllerParentView] != nil )
    {
        [[self containedControllerParentView] setUserInteractionEnabled:NO];
    }
    if( [self animation_Hide_Duration] > 0 )
    {
        if( [self backgroundControl] != nil )
        {
            [[self backgroundControl] setEnabled:NO];
        }
        if( nil != [self superview] )
        {
            [[self superview] layoutIfNeeded];
        }
        __weak __typeof(self) weakSelf = self;
        [UIView
         animateWithDuration:[self animation_Hide_Duration]
         animations:^{
             if( weakSelf != nil )
             {
                 __strong __typeof(weakSelf) strongSelf = weakSelf;
                 if( [strongSelf containedControllerParentView_Constraint_CenterX] != nil )
                 {
                     [[strongSelf containedControllerParentView_Constraint_CenterX] setConstant:[strongSelf animation_Hidden_Center].x];
                 }
                 if( [strongSelf containedControllerParentView_Constraint_CenterY] != nil )
                 {
                     [[strongSelf containedControllerParentView_Constraint_CenterY] setConstant:[strongSelf animation_Hidden_Center].y];
                 }
                 if( [strongSelf backgroundBlurView] != nil )
                 {
                     [[strongSelf backgroundBlurView] setHidden:YES];
                 }
                 if( [strongSelf backgroundControl] != nil )
                 {
                     [[strongSelf backgroundControl] setAlpha:0.0];
                 }
                 if( [strongSelf containedControllerParentView] != nil )
                 {
                     [[strongSelf containedControllerParentView] setAlpha:[strongSelf animation_Hidden_Alpha]];
                 }
                 if( [strongSelf backgroundBlurView] != nil )
                 {
                     [[strongSelf backgroundBlurView] setHidden:YES];
                 }
                 if( nil != [strongSelf superview] )
                 {
                     [[strongSelf superview] layoutIfNeeded];
                 }
             }
         }
         completion:^(BOOL finished) {
             if( weakSelf != nil )
             {
                 __strong __typeof(weakSelf) strongSelf = weakSelf;
                 if(
                    [strongSelf mkSimulatedModalPresentationHelperDelegate] != nil
                    && [[strongSelf mkSimulatedModalPresentationHelperDelegate] respondsToSelector:@selector(mkSimulatedModalPresentationHelperDidHide:)]
                    )
                 {
                     [[strongSelf mkSimulatedModalPresentationHelperDelegate] mkSimulatedModalPresentationHelperDidHide:strongSelf];
                 }
             }
             if( completion != nil )
             {
                 completion(finished);
             }
         }
         ];
    }
    else
    {
        if( [self containedControllerParentView_Constraint_CenterX] != nil )
        {
            [[self containedControllerParentView_Constraint_CenterX] setConstant:[self animation_Hidden_Center].x];
        }
        if( [self containedControllerParentView_Constraint_CenterY] != nil )
        {
            [[self containedControllerParentView_Constraint_CenterY] setConstant:[self animation_Hidden_Center].y];
        }
        if( [self backgroundBlurView] != nil )
        {
            [[self backgroundBlurView] setHidden:YES];
        }
        if( [self backgroundControl] != nil )
        {
            [[self backgroundControl] setAlpha:0.0];
            [[self backgroundControl] setEnabled:NO];
        }
        if( [self containedControllerParentView] != nil )
        {
            [[self containedControllerParentView] setAlpha:[self animation_Hidden_Alpha]];
        }
        if( [self backgroundBlurView] != nil )
        {
            [[self backgroundBlurView] setHidden:YES];
        }
        if( nil != [self superview] )
        {
            [[self superview] layoutIfNeeded];
        }
        __weak __typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if( weakSelf != nil )
            {
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                if(
                   [strongSelf mkSimulatedModalPresentationHelperDelegate] != nil
                   && [[strongSelf mkSimulatedModalPresentationHelperDelegate] respondsToSelector:@selector(mkSimulatedModalPresentationHelperDidHide:)]
                   )
                {
                    [[strongSelf mkSimulatedModalPresentationHelperDelegate] mkSimulatedModalPresentationHelperDidHide:strongSelf];
                }
            }
            if( completion != nil )
            {
                completion(YES);
            }
        });
    }
}

@end
