//
//  FBSession+PromiseKit.h
//  Facebook-PromiseKit
//
//  Created by Kirils Sivokozs on 30/01/2015.
//  Copyright (c) 2015 Kirils Sivokozs. All rights reserved.
//

#import "FBSDKLoginManager.h"
#import <PromiseKit/Promise.h>

typedef NS_ENUM(NSInteger, CustomFacebookErrorType) {
    CustomFacebookErrorTypeNoToken = -1,
    CustomFacebookErrorTypeCancelled,
    CustomFacebookErrorTypeUnknown
};

@interface FBSDKLoginManager (PromiseKit)

+ (void)closeActiveSession;
+ (PMKPromise *)fetchUserDataUsingSystemAccount;
+ (PMKPromise *)openActiveSessionWithReadPermissions:(NSArray *)readPermissions
                                       withBehaviour:(FBSDKLoginBehavior)behaviour;
+ (PMKPromise *)requestNewPublishPermissions:(NSArray *)writePermissions
                             defaultAudience:(FBSDKDefaultAudience)defaultAudience;
+ (PMKPromise *)openActiveSessionWithPublishPermissions:(NSArray *)publishPermissions
                                        defaultAudience:(FBSDKDefaultAudience)defaultAudience
                                           allowLoginUI:(BOOL)allowLoginUI;

+ (PMKPromise *)requestPublishPermissionIfNeeded;
+ (PMKPromise *)hasPublishPermission;
@end
