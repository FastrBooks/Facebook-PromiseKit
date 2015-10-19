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

+ (PMKPromise *)fetchUserDataUsingSystemAccountFromController:(UIViewController *)controller
{
    if ([FBSDKAccessToken currentAccessToken]) {
        return [FBSDKGraphRequest startForMe];
    } else {
        NSArray *readPermissions = @[@"public_profile", @"email"];
        PMKPromise *promise = [FBSDKLoginManager openActiveSessionWithReadPermissions:readPermissions
                                                                        withBehaviour:FBSDKLoginBehaviorSystemAccount
                               fromController:controller];
        return promise.then(^(FBSDKAccessToken *token) {
            if (token) {
                return [FBSDKGraphRequest startForMe];
            } else {
                NSError *error = [NSError errorWithDomain:FBSDKLoginErrorDomain
                                                     code:KSCustomFacebookErrorTypeNoToken
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
                                      fromController:(UIViewController *)controller
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
        manager.loginBehavior = behaviour;
        [manager logInWithReadPermissions:readPermissions
                       fromViewController:controller
                                  handler:
         ^(FBSDKLoginManagerLoginResult *result, NSError *error) {
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
                              fromController:(UIViewController *)controller
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
        [manager logInWithReadPermissions:writePermissions
                       fromViewController:controller
                                  handler:
         ^(FBSDKLoginManagerLoginResult *result, NSError *error) {
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
                                         fromController:(UIViewController *)controller
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
        manager.defaultAudience  = defaultAudience;
        [manager logInWithPublishPermissions:publishPermissions
                          fromViewController:controller
                                     handler:
         ^(FBSDKLoginManagerLoginResult *result, NSError *error) {
             [FBSDKLoginManager handleLoginResult:result andError:error].then(^(FBSDKAccessToken *token){
                 fulfill(token);
             }).catch(^(NSError *error){
                 reject(error);
             });
         }];
    }];
}

+ (PMKPromise *)requestPublishPermissionIfNeededFromController:(UIViewController *)controller
{
    NSString *publishAction = @"publish_actions";
    if ([FBSDKAccessToken currentAccessToken]) {
        return [FBSDKLoginManager hasPublishPermission].then(^(NSNumber *hasPermission){
            if ([hasPermission boolValue]) {
                return [PMKPromise promiseWithValue:nil];
            } else {
                return [FBSDKLoginManager requestNewPublishPermissions:@[publishAction]
                                                       defaultAudience:FBSDKDefaultAudienceFriends
                                                        fromController:controller];
            }
        });
    } else {
        return [FBSDKLoginManager openActiveSessionWithPublishPermissions:@[publishAction]
                                                          defaultAudience:FBSDKDefaultAudienceFriends
                                                             allowLoginUI:YES
                                                           fromController:controller];
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
                                                 code:KSCustomFacebookErrorTypeCancelled
                                             userInfo:nil];
            return [PMKPromise promiseWithValue:error];
        }
        if (!result.token) {
            NSError *error = [NSError errorWithDomain:FBSDKLoginErrorDomain
                                                 code:KSCustomFacebookErrorTypeNoToken
                                             userInfo:nil];
            return [PMKPromise promiseWithValue:error];
        }
        if (result.token) {
            return [PMKPromise promiseWithValue:result.token];
        }
        NSError *error = [NSError errorWithDomain:FBSDKLoginErrorDomain
                                             code:KSCustomFacebookErrorTypeUnknown
                                         userInfo:nil];
        return [PMKPromise promiseWithValue:error];
    }
}

@end
