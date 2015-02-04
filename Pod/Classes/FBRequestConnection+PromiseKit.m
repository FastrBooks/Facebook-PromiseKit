//
//  FBRequestConnection+PromiseKit.m
//  Facebook-PromiseKit
//
//  Created by Kirils Sivokozs on 30/01/2015.
//  Copyright (c) 2015 Kirils Sivokozs. All rights reserved.
//

#import "FBRequestConnection+PromiseKit.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation FBRequestConnection (PromiseKit)

+ (PMKPromise *)requestMyCurrentPermissions
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        [FBRequestConnection startWithGraphPath:@"/me/permissions"
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
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
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                fulfill(result);
            } else {
                reject(error);
            }
        }];
    }];
}

@end
