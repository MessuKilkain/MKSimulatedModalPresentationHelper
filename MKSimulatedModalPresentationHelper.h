//
//  MKSimulatedModalPresentationHelper.h
//


#ifndef __MKSimulatedModalPresentationHelper__MKSimulatedModalPresentationHelper_h
#define __MKSimulatedModalPresentationHelper__MKSimulatedModalPresentationHelper_h

#import <UIKit/UIKit.h>

@class MKSimulatedModalPresentationHelper;

@protocol MKSimulatedModalPresentationHelperDelegate <NSObject>

@optional

-(void)mkSimulatedModalPresentationHelperDidHide:(MKSimulatedModalPresentationHelper*_Nonnull)mkSimulatedModalPresentationHelper;

@end

@interface MKSimulatedModalPresentationHelper : UIView

#pragma mark - Delegate

@property (nonatomic, weak) NSObject<MKSimulatedModalPresentationHelperDelegate>* __nullable mkSimulatedModalPresentationHelperDelegate;

#pragma mark - Animation Properties

@property (nonatomic) CGFloat animation_Hidden_Alpha;
@property (nonatomic) CGPoint animation_Hidden_Center;
// @property (nonatomic) CGFloat animation_Displayed_Alpha; // No case where this is not 1.0
-(void)setAnimation_Displayed_Center:(CGPoint)newDisplayCenter;
-(CGPoint)animation_Displayed_Center;

@property (nonatomic) NSTimeInterval animation_Hide_Duration;
@property (nonatomic) NSTimeInterval animation_Show_Duration;

-(void)setUseBlurEffect:(BOOL)shouldUseBlurEffect;
-(BOOL)useBlurEffect;
-(void)setBlurEffectStyle:(UIBlurEffectStyle)newBlurEffectStyle;
-(UIBlurEffectStyle)blurEffectStyle;
-(void)setBackgroundControlColor:(UIColor*_Nonnull)newBackgroundControlColor;
-(UIColor*_Nonnull)backgroundControlColor;

@property (nonatomic,getter=isDismissFromBackgroundControlAllowed) BOOL dismissFromBackgroundControlAllowed;
@property (nonatomic,getter=isDismissFromMenuTapAllowed) BOOL dismissFromMenuTapAllowed;

#pragma mark - Contained controller

-(UIViewController* _Nullable)containedController;
-(UIViewController* _Nullable)removeContainedControllerIfNecessary;
-(void)setControllerFullView:( UIViewController* _Nonnull )controller;
-(void)setController:(UIViewController* _Nonnull )controller withPreferredSize:(CGSize)size;

#pragma mark - Animations

-(void)playAnimationShowWithCompletionBlock:(void (^ __nullable)(BOOL finished))completion;
-(void)playAnimationHideWithCompletionBlock:(void (^ __nullable)(BOOL finished))completion;

@end

#endif
