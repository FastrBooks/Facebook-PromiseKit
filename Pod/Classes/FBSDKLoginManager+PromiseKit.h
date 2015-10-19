//
//  FBSession+PromiseKit.h
//  Facebook-PromiseKit
//
//  Created by Kirils Sivokozs on 30/01/2015.
//  Copyright (c) 2015 Kirils Sivokozs. All rights reserved.
//

#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import <PromiseKit/Promise.h>

typedef NS_ENUM(NSInteger, KSCustomFacebookErrorType) {
    KSCustomFacebookErrorTypeNoToken = -1,
    KSCustomFacebookErrorTypeCancelled,
    KSCustomFacebookErrorTypeUnknown
};

@interface FBSDKLoginManager (PromiseKit)

+ (void)closeActiveSession;
+ (PMKPromise *)fetchUserDataUsingSystemAccountFromController:(UIViewController *)controller;
+ (PMKPromise *)requestPublishPermissionIfNeededFromController:(UIViewController *)controller;

+ (PMKPromise *)openActiveSessionWithReadPermissions:(NSArray *)readPermissions
                                       withBehaviour:(FBSDKLoginBehavior)behaviour
                                      fromController:(UIViewController *)controller;
+ (PMKPromise *)requestNewPublishPermissions:(NSArray *)writePermissions
                             defaultAudience:(FBSDKDefaultAudience)defaultAudience
                              fromController:(UIViewController *)controller;
+ (PMKPromise *)openActiveSessionWithPublishPermissions:(NSArray *)publishPermissions
                                        defaultAudience:(FBSDKDefaultAudience)defaultAudience
                                           allowLoginUI:(BOOL)allowLoginUI
                                         fromController:(UIViewController *)controller;

+ (PMKPromise *)hasPublishPermission;
@end
