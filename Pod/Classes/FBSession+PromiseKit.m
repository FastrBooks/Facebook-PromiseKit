//
//  FBSession+PromiseKit.m
//  Facebook-PromiseKit
//
//  Created by Kirils Sivokozs on 30/01/2015.
//  Copyright (c) 2015 Kirils Sivokozs. All rights reserved.
//

#import "FBRequestConnection+PromiseKit.h"
#import "FBSession+PromiseKit.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation FBSession (PromiseKit)

+ (void)restoreSession
{
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email"] allowLoginUI:NO];
    }
}

+ (void)closeActiveSession
{
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        [FBSession.activeSession closeAndClearTokenInformation];
    }
}

+ (PMKPromise *)fetchUserDataUsingSystemAccount:(BOOL)usingAccount
{
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        return [FBRequestConnection startForMe];
    } else {
        NSArray *readPermissions = @[@"public_profile", @"email"];
        PMKPromise *promise = usingAccount ?
        [FBSession openActiveSessionWithReadPermissions:readPermissions
                                          withBehaviour:FBSessionLoginBehaviorUseSystemAccountIfPresent] :
        [FBSession openActiveSessionWithReadPermissions:readPermissions allowLoginUI:YES];
        
        return promise.then(^(NSNumber *result) {
            if ([result integerValue] == FBSessionStateOpen) {
                return [FBRequestConnection startForMe];
            } else {
                NSError *error = [NSError errorWithDomain:FacebookSDKDomain
                                                     code:FBErrorInvalid
                                                 userInfo:nil];
                return [PMKPromise promiseWithValue:error];
            }
        });
    }
}

+ (PMKPromise *)openActiveSessionWithReadPermissions:(NSArray *)readPermissions allowLoginUI:(BOOL)allowLoginUI
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        [FBSession openActiveSessionWithReadPermissions:readPermissions allowLoginUI:allowLoginUI completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (error) {
                reject(error);
            } else {
                fulfill(@(status));
            }
        }];
    }];
}

+ (PMKPromise *)openActiveSessionWithReadPermissions:(NSArray *)readPermissions
                                       withBehaviour:(FBSessionLoginBehavior)behaviour
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        FBSession *facebookSession = [[FBSession alloc] initWithPermissions:readPermissions];
        [FBSession setActiveSession:facebookSession];
        [facebookSession openWithBehavior:behaviour
                        completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                            if (!error) {
                                fulfill(@(status));
                            } else {
                                reject(error);
                            }
                        }];
    }];
}


+ (PMKPromise *)requestNewReadPermissions:(NSArray *)readPermissions
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        [FBSession.activeSession requestNewReadPermissions:readPermissions
                                         completionHandler:^(FBSession *session, NSError *error) {
                                             if (!error) {
                                                 fulfill(nil);
                                             } else {
                                                 reject(error);
                                             }
                                         }];
    }];
}

+ (PMKPromise *)requestNewPublishPermissions:(NSArray *)writePermissions
                             defaultAudience:(FBSessionDefaultAudience)defaultAudience
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        [FBSession.activeSession requestNewPublishPermissions:writePermissions
                                              defaultAudience:defaultAudience
                                            completionHandler:^(FBSession *session, NSError *error) {
                                                if (!error && session.state == FBSessionStateOpen) {
                                                    fulfill(nil);
                                                } else {
                                                    reject(error);
                                                }
                                            }];
    }];
}

+ (PMKPromise *)openActiveSessionWithPublishPermissions:(NSArray *)publishPermissions
                                defaultAudience:(FBSessionDefaultAudience)defaultAudience
                                   allowLoginUI:(BOOL)allowLoginUI
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        [FBSession openActiveSessionWithPublishPermissions:publishPermissions
                                           defaultAudience:defaultAudience
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                             if (!error && status == FBSessionStateOpen) {
                                                 fulfill(nil);
                                             }else{
                                                 reject(error);
                                             }
                                         }];
    }];
}

+ (PMKPromise *)requestPublishPermissionIfNeeded
{
    NSString *publishAction = @"publish_actions";
    if ([[FBSession activeSession] isOpen]) {
        if ([[[FBSession activeSession] permissions] indexOfObject:publishAction] == NSNotFound) {
            return [FBSession requestNewPublishPermissions:@[publishAction]
                                           defaultAudience:FBSessionDefaultAudienceFriends];
        } else {
            return [PMKPromise promiseWithValue:nil];
        }
    } else {
        return [FBSession openActiveSessionWithPublishPermissions:@[publishAction]
                                                  defaultAudience:FBSessionDefaultAudienceFriends
                                                     allowLoginUI:YES];
    }
}

+ (BOOL)hasPublishPermission
{
    return [[FBSession activeSession] isOpen] &&
    [[[FBSession activeSession] permissions] indexOfObject:@"publish_actions"] != NSNotFound;
}

@end
