//
//  ThreadSafeTests.m
//  ThreadSafeTests
//
//  Created by CPU11808 on 2/7/17.
//  Copyright © 2017 CPU11808. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SafeMutableArray.h"

@interface ThreadSafeTests : XCTestCase

@property (nonatomic) SafeMutableArray *addObjectArray;
@property dispatch_queue_t addObjectConcurrentQueue;

@property (nonatomic) SafeMutableArray *insertObjectArray;
@property dispatch_queue_t insertObjectConcurrentQueue;

@property (nonatomic) SafeMutableArray *removeObjectArray;
@property dispatch_queue_t removeObjectConcurrentQueue;

@property (nonatomic) SafeMutableArray *removeLastObjectArray;
@property dispatch_queue_t removeLastObjectConcurrentQueue;

@end

@implementation ThreadSafeTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // Method: addObject
    _addObjectArray = [[SafeMutableArray alloc] init];
    _addObjectConcurrentQueue = dispatch_queue_create("com.vng.test.addObject", DISPATCH_QUEUE_CONCURRENT);
    
    // Method: insertObject
    _insertObjectArray = [[SafeMutableArray alloc] init];
    _insertObjectConcurrentQueue = dispatch_queue_create("com.vng.test.insertObject", DISPATCH_QUEUE_CONCURRENT);
    
    // Method: removeObject
    _removeObjectArray = [[SafeMutableArray alloc] initWithCapacity:1000000];
    for (int i = 0; i < 1000000; i++) {
        _removeObjectArray[i] = @"asdasdasdasdasdasdasdasdasdasdasdasdasdasdasasdasdasdasdasdasdasdasdasdasdas";
    }
    _removeObjectConcurrentQueue = dispatch_queue_create("com.vng.test.removeObject", DISPATCH_QUEUE_CONCURRENT);
    
    // Method: removeLastObject
    _removeLastObjectArray = [[SafeMutableArray alloc] initWithCapacity:100000];
    for (int i = 0; i < 100000; i++) {
        _removeLastObjectArray[i] = @"asdasdasdasdasdasdasdasdasdasdasdasdasdasdasasdasdasdasdasdasdasdasdasdasdas";
    }
    _removeLastObjectConcurrentQueue = dispatch_queue_create("com.vng.test.removeLastObject", DISPATCH_QUEUE_CONCURRENT);
    

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testAddObjectMethod {
    
    XCTestExpectation *thread1Expectation = [self expectationWithDescription:@"Thread1"];
    XCTestExpectation *thread2Expectation = [self expectationWithDescription:@"Thread2"];
    
    dispatch_async(_addObjectConcurrentQueue, ^{
            for (int i = 0; i < 100000; i++) {
                XCTAssertNoThrow([_addObjectArray addObject:@"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"]);
                //NSLog(@"%d", i);
            }
        [thread1Expectation fulfill];
    });
    
    dispatch_async(_addObjectConcurrentQueue, ^{
            for (int i = 0; i < 100000; i++) {
                XCTAssertNoThrow([_addObjectArray addObject:@"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"]);
                //NSLog(@"%d", i);
            }
        [thread2Expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void) testInsertObjectMethod {
    
    XCTestExpectation *thread1Expectation = [self expectationWithDescription:@"Thread1"];
    XCTestExpectation *thread2Expectation = [self expectationWithDescription:@"Thread2"];
    
    dispatch_async(_insertObjectConcurrentQueue, ^{
        for (int i = 0; i < 10000; i++) {
            XCTAssertNoThrow([_insertObjectArray
                              insertObject:@"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
                              atIndex:[_insertObjectArray count] / 2]);
            //NSLog(@"%d", i);
        }
        [thread1Expectation fulfill];
    });
    
    dispatch_async(_insertObjectConcurrentQueue, ^{
        for (int i = 0; i < 10000; i++) {
            XCTAssertNoThrow([_insertObjectArray
                              insertObject:@"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
                              atIndex:[_insertObjectArray count] / 2]);
            //NSLog(@"%d", i);
        }
        [thread2Expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void) testRemoveObjectMethod {
    
    XCTestExpectation *thread1Expectation = [self expectationWithDescription:@"Thread1"];
    XCTestExpectation *thread2Expectation = [self expectationWithDescription:@"Thread2"];
    
    dispatch_async(_removeObjectConcurrentQueue, ^{
        while ([_removeObjectArray count] > 0) {
            XCTAssertNoThrow([_removeObjectArray removeObject:[_removeObjectArray objectAtIndex:0]]);
        }
        [thread1Expectation fulfill];
    });
    
    dispatch_async(_removeObjectConcurrentQueue, ^{
        while ([_removeObjectArray count] > 0) {
            XCTAssertNoThrow([_removeObjectArray removeObject:[_removeObjectArray objectAtIndex:0]]);
        }
        [thread2Expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void) testRemoveLastObjectMethod {
    
    XCTestExpectation *thread1Expectation = [self expectationWithDescription:@"Thread1"];
    XCTestExpectation *thread2Expectation = [self expectationWithDescription:@"Thread2"];
    
    dispatch_async(_removeLastObjectConcurrentQueue, ^{
        while ([_removeLastObjectArray count] > 0) {
            XCTAssertNoThrow([_removeLastObjectArray removeLastObject]);
        }
        [thread1Expectation fulfill];
    });
    
    dispatch_async(_removeLastObjectConcurrentQueue, ^{
        while ([_removeLastObjectArray count] > 0) {
            XCTAssertNoThrow([_removeLastObjectArray removeLastObject]);
        }
        [thread2Expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:20.0 handler:nil];
}


@end
