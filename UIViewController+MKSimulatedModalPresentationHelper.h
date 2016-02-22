//
//  UIViewController+MKSimulatedModalPresentationHelper.h
//


#ifndef __MKSimulatedModalPresentationHelper__UIViewController_MKSimulatedModalPresentationHelper_h
#define __MKSimulatedModalPresentationHelper__UIViewController_MKSimulatedModalPresentationHelper_h

#import <UIKit/UIKit.h>

#import "MKSimulatedModalPresentationHelper.h"

@interface UIViewController(MKSimulatedModalPresentationHelper)

-(BOOL)dismissFromSimulatedModalPresentationHelper;

#pragma mark - Full view

-(MKSimulatedModalPresentationHelper*_Nullable)showController:(UIViewController*_Nonnull)controller;

-(MKSimulatedModalPresentationHelper*_Nullable)showController:(UIViewController*_Nonnull)controller withHelper:(MKSimulatedModalPresentationHelper*_Nullable)helper;

-(MKSimulatedModalPresentationHelper*_Nullable)showController:(UIViewController*_Nonnull)controller inSubview:(UIView*_Nonnull)subview;

-(MKSimulatedModalPresentationHelper*_Nullable)showController:(UIViewController*_Nonnull)controller inSubview:(UIView*_Nonnull)subview withHelper:(MKSimulatedModalPresentationHelper*_Nullable)helper;

#pragma mark - Specific size

-(MKSimulatedModalPresentationHelper*_Nullable)showController:(UIViewController*_Nonnull)controller modalSize:(CGSize)size;

-(MKSimulatedModalPresentationHelper*_Nullable)showController:(UIViewController*_Nonnull)controller withHelper:(MKSimulatedModalPresentationHelper*_Nullable)helper modalSize:(CGSize)size;

-(MKSimulatedModalPresentationHelper*_Nullable)showController:(UIViewController*_Nonnull)controller inSubview:(UIView*_Nonnull)subview modalSize:(CGSize)size;

-(MKSimulatedModalPresentationHelper*_Nullable)showController:(UIViewController*_Nonnull)controller inSubview:(UIView*_Nonnull)subview withHelper:(MKSimulatedModalPresentationHelper*_Nullable)helper modalSize:(CGSize)size;

@end

#endif
