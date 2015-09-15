//
//  FBRequestConnection+PromiseKit.m
//  Facebook-PromiseKit
//
//  Created by Kirils Sivokozs on 30/01/2015.
//  Copyright (c) 2015 Kirils Sivokozs. All rights reserved.
//

#import "FBSDKGraphRequest+PromiseKit.h"

@implementation FBSDKGraphRequest (PromiseKit)

+ (PMKPromise *)requestMyCurrentPermissions
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        NSDictionary *params = @{@"fields" : @"permission, status"};
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"/me/permissions"
                                                                       parameters:params];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (!error){
                fulfill(result);
            } else {
                reject(error);
            }
        }];
    }];
}

+ (PMKPromise *)startForMe
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        NSDictionary *params = @{@"fields" : @"id, name, email, first_name, last_name"};
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                       parameters:params];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (!error){
                fulfill(result);
            } else {
                reject(error);
            }
        }];
    }];
}

@end
