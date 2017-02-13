//
//  SafeMutableArray.m
//  ThreadSafeComandLine
//
//  Created by CPU11808 on 2/9/17.
//  Copyright © 2017 CPU11808. All rights reserved.
//

#import "SafeMutableArray.h"

@implementation SafeMutableArray

dispatch_queue_t _concurrentQueue;
NSMutableArray *_backendArray;


- (instancetype) init {

    if (self = [super init]) {
        _backendArray = [@[] mutableCopy];
        
        _concurrentQueue = dispatch_queue_create("com.vng.SafeMutableArray", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    
    if (self = [super init]) {
        _backendArray = [[NSMutableArray alloc] initWithCapacity:numItems];
        
        _concurrentQueue = dispatch_queue_create("com.vng.SafeMutableArray", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (NSUInteger)count;
{
    __block NSInteger c;
    dispatch_sync(_concurrentQueue, ^{
        c = [_backendArray count];
    });
    return c;
}

- (id)objectAtIndex:(NSUInteger)index
{
    if (index >= [_backendArray count])
        return nil;
    
    __block id obj;
    dispatch_sync(_concurrentQueue, ^{
        obj = [_backendArray objectAtIndex:index];
    });
    return obj;
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    dispatch_barrier_async(_concurrentQueue, ^{
        if (index < [_backendArray count])
            [_backendArray insertObject:anObject atIndex:index];
        else
            [_backendArray insertObject:anObject atIndex:0];
    });
}

- (void)removeObject:(id)anObject
{
    dispatch_barrier_async(_concurrentQueue, ^{
        [_backendArray removeObject:anObject];
    });
    
}

- (void)addObject:(id)anObject
{
    dispatch_barrier_async(_concurrentQueue, ^{
        [_backendArray addObject:anObject];
    });
}

- (void)removeLastObject
{
    dispatch_barrier_async(_concurrentQueue, ^{
        [_backendArray removeLastObject];
    });
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    dispatch_barrier_async(_concurrentQueue, ^{
        if (index < [_backendArray count])
            [_backendArray replaceObjectAtIndex:index withObject:anObject];
        else
            [_backendArray replaceObjectAtIndex:0 withObject:anObject];
    });
}

@end
