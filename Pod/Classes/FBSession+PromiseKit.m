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

+ (PMKPromise *)fetchUserData
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        if (FBSession.activeSession.state == FBSessionStateOpen
            || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
            [FBRequestConnection startForMe].then(^(id result) {
                fulfill(result);
            }).catch(^(NSError *error) {
                reject(error);
            });
        } else {
            [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"] allowLoginUI:YES].then(^(NSNumber *result) {
                if ([result integerValue] == FBSessionStateOpen) {
                    [FBRequestConnection startForMe].then(^(id result) {
                        fulfill(result);
                    }).catch(^(NSError *error) {
                        reject(error);
                    });
                } else {
                    NSError *error = [NSError errorWithDomain:FacebookSDKDomain
                                                         code:FBErrorInvalid
                                                     userInfo:nil];
                    reject(error);
                }
            }).catch(^(NSError *error) {
                reject(error);
            });
        }
    }];
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
