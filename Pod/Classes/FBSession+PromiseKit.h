//
//  FBSession+PromiseKit.h
//  Facebook-PromiseKit
//
//  Created by Kirils Sivokozs on 30/01/2015.
//  Copyright (c) 2015 Kirils Sivokozs. All rights reserved.
//

#import "FBSession.h"
#import <PromiseKit/Promise.h>

@interface FBSession (PromiseKit)

+ (void)restoreSession;
+ (void)closeActiveSession;
+ (PMKPromise *)fetchUserDataUsingSystemAccount:(BOOL)usingAccount;
+ (PMKPromise *)requestNewReadPermissions:(NSArray *)readPermissions;
+ (PMKPromise *)openActiveSessionWithReadPermissions:(NSArray *)readPermissions
                                        allowLoginUI:(BOOL)allowLoginUI;
+ (PMKPromise *)openActiveSessionWithReadPermissions:(NSArray *)readPermissions
                                       withBehaviour:(FBSessionLoginBehavior)behaviour;
+ (PMKPromise *)requestNewPublishPermissions:(NSArray *)writePermissions
                             defaultAudience:(FBSessionDefaultAudience)defaultAudience;
+ (PMKPromise *)openActiveSessionWithPublishPermissions:(NSArray *)publishPermissions
                                        defaultAudience:(FBSessionDefaultAudience)defaultAudience
                                           allowLoginUI:(BOOL)allowLoginUI;
+ (PMKPromise *)requestPublishPermissionIfNeeded;

@end
