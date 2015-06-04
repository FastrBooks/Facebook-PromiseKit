//
//  FBSession+PromiseKit.h
//  Facebook-PromiseKit
//
//  Created by Kirils Sivokozs on 30/01/2015.
//  Copyright (c) 2015 Kirils Sivokozs. All rights reserved.
//

#import "FBSDKLoginManager.h"
#import <PromiseKit/Promise.h>

@interface FBSDKLoginManager (PromiseKit)

+ (void)restoreSession;
+ (void)closeActiveSession;
+ (PMKPromise *)fetchUserDataUsingSystemAccount:(BOOL)usingAccount;
+ (PMKPromise *)openActiveSessionWithReadPermissions:(NSArray *)readPermissions
                                        allowLoginUI:(BOOL)allowLoginUI;
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
