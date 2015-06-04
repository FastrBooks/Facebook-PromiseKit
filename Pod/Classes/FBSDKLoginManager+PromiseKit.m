//
//  FBSession+PromiseKit.m
//  Facebook-PromiseKit
//
//  Created by Kirils Sivokozs on 30/01/2015.
//  Copyright (c) 2015 Kirils Sivokozs. All rights reserved.
//

#import "FBSDKGraphRequest+PromiseKit.h"
#import "FBSDKLoginManager+PromiseKit.h"

#import "FBSDKAccessToken.h"
#import "FBSDKLoginManagerLoginResult.h"
#import "FBSDKLoginConstants.h"

@implementation FBSDKLoginManager (PromiseKit)

+ (void)restoreSession
{
    if (![FBSDKAccessToken currentAccessToken]) {
        [FBSDKLoginManager openActiveSessionWithReadPermissions:@[@"public_profile", @"email"] allowLoginUI:NO];
    }
}

+ (void)closeActiveSession
{
    if ([FBSDKAccessToken currentAccessToken]) {
        FBSDKLoginManager *logMeOut = [[FBSDKLoginManager alloc] init];
        [logMeOut logOut];
    }
}

+ (PMKPromise *)fetchUserDataUsingSystemAccount:(BOOL)usingAccount
{
    if ([FBSDKAccessToken currentAccessToken]) {
        return [FBSDKGraphRequest startForMe];
    } else {
        NSArray *readPermissions = @[@"public_profile", @"email"];
        PMKPromise *promise = usingAccount ?
        [FBSDKLoginManager openActiveSessionWithReadPermissions:readPermissions
                                          withBehaviour:FBSDKLoginBehaviorSystemAccount] :
        [FBSDKLoginManager openActiveSessionWithReadPermissions:readPermissions allowLoginUI:YES];
        
        return promise.then(^(FBSDKAccessToken *token) {
            if (token) {
                return [FBSDKGraphRequest startForMe];
            } else {
                NSError *error = [NSError errorWithDomain:FBSDKLoginErrorDomain
                                                     code:0
                                                 userInfo:nil];
                return [PMKPromise promiseWithValue:error];
            }
        });
    }
}

+ (PMKPromise *)openActiveSessionWithReadPermissions:(NSArray *)readPermissions allowLoginUI:(BOOL)allowLoginUI
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logInWithReadPermissions:readPermissions handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error) {
                reject(error);
            } else {
                fulfill(result.token);
            }
        }];
    }];
}

+ (PMKPromise *)openActiveSessionWithReadPermissions:(NSArray *)readPermissions
                                       withBehaviour:(FBSDKLoginBehavior)behaviour
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
        manager.loginBehavior = behaviour;
        [manager logInWithReadPermissions:readPermissions handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (!error) {
                fulfill(result.token);
            } else {
                reject(error);
            }
        }];
    }];
}

+ (PMKPromise *)requestNewPublishPermissions:(NSArray *)writePermissions
                             defaultAudience:(FBSDKDefaultAudience)defaultAudience
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
        [manager logInWithPublishPermissions:writePermissions handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (!error) {
                fulfill(nil);
            } else {
                reject(error);
            }
        }];
    }];
}

+ (PMKPromise *)openActiveSessionWithPublishPermissions:(NSArray *)publishPermissions
                                defaultAudience:(FBSDKDefaultAudience)defaultAudience
                                   allowLoginUI:(BOOL)allowLoginUI
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
        manager.defaultAudience  = defaultAudience;
        [manager logInWithPublishPermissions:publishPermissions handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (!error) {
                fulfill(nil);
            } else {
                reject(error);
            }
        }];
    }];
}

+ (PMKPromise *)requestPublishPermissionIfNeeded
{
    NSString *publishAction = @"publish_actions";
    if ([FBSDKAccessToken currentAccessToken]) {
        return [FBSDKLoginManager hasPublishPermission].then(^(NSNumber *hasPermission){
            if ([hasPermission boolValue]) {
                return [PMKPromise promiseWithValue:nil];
            } else {
                return [FBSDKLoginManager requestNewPublishPermissions:@[publishAction]
                                                       defaultAudience:FBSDKDefaultAudienceFriends];
            }
        });
    } else {
        return [FBSDKLoginManager openActiveSessionWithPublishPermissions:@[publishAction]
                                                          defaultAudience:FBSDKDefaultAudienceFriends
                                                             allowLoginUI:YES];
    }
}

+ (PMKPromise *)hasPublishPermission
{
    return [FBSDKGraphRequest requestMyCurrentPermissions].then(^(NSDictionary *response){
        for (NSDictionary *permission in response[@"data"]) {
            if ([permission[@"permission"] isEqualToString:@"publish_actions"] &&
                [permission[@"status"] isEqualToString:@"declined"]) {
                return [PMKPromise promiseWithValue:@(NO)];
            }
        }
        return [PMKPromise promiseWithValue:@(YES)];
    });
}

@end
