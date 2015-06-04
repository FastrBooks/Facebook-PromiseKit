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

+ (void)closeActiveSession
{
    if ([FBSDKAccessToken currentAccessToken]) {
        FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
        [manager logOut];
    }
}

+ (PMKPromise *)fetchUserDataUsingSystemAccount
{
    if ([FBSDKAccessToken currentAccessToken]) {
        return [FBSDKGraphRequest startForMe];
    } else {
        NSArray *readPermissions = @[@"public_profile", @"email"];
        PMKPromise *promise = [FBSDKLoginManager openActiveSessionWithReadPermissions:readPermissions
                                                                        withBehaviour:FBSDKLoginBehaviorSystemAccount];
        return promise.then(^(FBSDKAccessToken *token) {
            if (token) {
                return [FBSDKGraphRequest startForMe];
            } else {
                NSError *error = [NSError errorWithDomain:FBSDKLoginErrorDomain
                                                     code:CustomFacebookErrorTypeNoToken
                                                 userInfo:nil];
                return [PMKPromise promiseWithValue:error];
            }
        }).catch(^(NSError *error){
            return [PMKPromise promiseWithValue:error];
        });
    }
}

+ (PMKPromise *)openActiveSessionWithReadPermissions:(NSArray *)readPermissions
                                       withBehaviour:(FBSDKLoginBehavior)behaviour
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
        manager.loginBehavior = behaviour;
        [manager logInWithReadPermissions:readPermissions handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            [FBSDKLoginManager handleLoginResult:result andError:error].then(^(FBSDKAccessToken *token){
                fulfill(token);
            }).catch(^(NSError *error){
                reject(error);
            });
        }];
    }];
}

+ (PMKPromise *)requestNewPublishPermissions:(NSArray *)writePermissions
                             defaultAudience:(FBSDKDefaultAudience)defaultAudience
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
        [manager logInWithPublishPermissions:writePermissions handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            [FBSDKLoginManager handleLoginResult:result andError:error].then(^(FBSDKAccessToken *token){
                fulfill(token);
            }).catch(^(NSError *error){
                reject(error);
            });
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
            [FBSDKLoginManager handleLoginResult:result andError:error].then(^(FBSDKAccessToken *token){
                fulfill(token);
            }).catch(^(NSError *error){
                reject(error);
            });
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

+ (PMKPromise *)handleLoginResult:(FBSDKLoginManagerLoginResult *)result andError:(NSError *)error
{
    if (error) {
        return [PMKPromise promiseWithValue:error];
    } else {
        if (result.isCancelled) {
            NSError *error = [NSError errorWithDomain:FBSDKLoginErrorDomain
                                                 code:CustomFacebookErrorTypeCancelled
                                             userInfo:nil];
            return [PMKPromise promiseWithValue:error];
        }
        if (!result.token) {
            NSError *error = [NSError errorWithDomain:FBSDKLoginErrorDomain
                                                 code:CustomFacebookErrorTypeNoToken
                                             userInfo:nil];
            return [PMKPromise promiseWithValue:error];
        }
        if (result.token) {
            return [PMKPromise promiseWithValue:result.token];
        }
        NSError *error = [NSError errorWithDomain:FBSDKLoginErrorDomain
                                             code:CustomFacebookErrorTypeUnknown
                                         userInfo:nil];
        return [PMKPromise promiseWithValue:error];
    }
}

@end
