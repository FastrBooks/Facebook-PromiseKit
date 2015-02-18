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
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"] allowLoginUI:NO];
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
        NSArray *readPermissions = @[@"public_profile"];
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
        FBSession *facebookSession = [[FBSession alloc] initWithPermissions:[NSArray arrayWithObjects:@"public_profile", @"email",nil]];
        [FBSession setActiveSession:facebookSession];
        [facebookSession openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent
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

@end
