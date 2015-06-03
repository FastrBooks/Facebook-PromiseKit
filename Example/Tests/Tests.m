//
//  Facebook-PromiseKitTests.m
//  Facebook-PromiseKitTests
//
//  Created by Kirils Sivokozs on 01/30/2015.
//  Copyright (c) 2014 Kirils Sivokozs. All rights reserved.
//

SpecBegin(InitialSpecs)

describe(@"these will pass", ^{
    
    it(@"can do maths", ^{
        expect(1).beLessThan(23);
    });
    
    it(@"can read", ^{
        expect(@"team").toNot.contain(@"I");
    });
    
    it(@"will wait and succeed", ^{
        waitUntil(^(DoneCallback done) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                done();
            });
        });
    });
});

SpecEnd
