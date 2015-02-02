//
//  FBSession+PromiseKit.m
//  Facebook-PromiseKit
//
//  Created by Kirils Sivokozs on 30/01/2015.
//  Copyright (c) 2015 Kirils Sivokozs. All rights reserved.
//

#import "FBSession+PromiseKit.h"

@implementation FBSession (PromiseKit)

+ (void)closeActiveSession
{
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        [FBSession.activeSession closeAndClearTokenInformation];
    }
}

+ (PMKPromise *)openActiveSessionWithReadPermissions:(NSArray *)readPermissions allowLoginUI:(BOOL)allowLoginUI
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        [FBSession openActiveSessionWithReadPermissions:readPermissions allowLoginUI:allowLoginUI completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (error) {
                reject(error);
            } else {
                fulfill(@[session , @(status)]);
            }
        }];
    }];
}


+ (PMKPromise *)requestNewReadPermissions:(NSArray *)readPermissions
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        if ([readPermissions count] > 0){
            [FBSession.activeSession
             requestNewReadPermissions:readPermissions
             completionHandler:^(FBSession *session, NSError *error) {
                 if (!error) {
                     fulfill(nil);
                 } else {
                     reject(error);
                 }
             }];
        } else {
            fulfill(nil);
        }
    }];
}

@end
