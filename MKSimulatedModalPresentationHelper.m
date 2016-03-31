//
//  MKSimulatedModalPresentationHelper.m
//

#import "MKSimulatedModalPresentationHelper.h"

#import "UIViewController+MKSimulatedModalPresentationHelper.h"

#import "UIView+AutoLayout.h"

@interface MKSimulatedModalPresentationHelper()

@property (nonatomic) BOOL shouldBeDisplayed;

@property (nonatomic, strong) UIColor* internalBackgroundControlColor;
@property (nonatomic) CGPoint internalAnimation_Displayed_Center;

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
}

-(void)initSubviewsIfNecessary
{
    // TODO : add blur view
    // backgroundBlurView
    if( [self backgroundControl] == nil )
    {
        UIControl* backgroundControl = [UIControl autoLayoutView];
        [self setBackgroundControl:backgroundControl];
        [self addSubview:backgroundControl];
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

#pragma mark -

-(void)backgroundControlTriggered
{
    NSLog(@"backgroundControlTriggered : ENTER");
    if( [self containedController] != nil )
    {
        [[self containedController] dismissFromSimulatedModalPresentationHelper];
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
        [[self backgroundControl] setUserInteractionEnabled:YES];
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
        [self layoutIfNeeded];
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
                 [strongSelf layoutIfNeeded];
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
        [self layoutIfNeeded];
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
        [self layoutIfNeeded];
        __weak __typeof(self) weakSelf = self;
        [UIView
         animateWithDuration:[self animation_Show_Duration]
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
                 [strongSelf layoutIfNeeded];
             }
         }
         completion:completion
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
        [self layoutIfNeeded];
        dispatch_async(dispatch_get_main_queue(), ^{
            if( completion != nil )
            {
                completion(YES);
            }
        });
    }
}

@end
