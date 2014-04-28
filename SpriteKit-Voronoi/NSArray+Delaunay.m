//
//  NSArray+Delaunay.m
//  Delaunay
//
//  Created by Sam Green on 4/13/14.
//  Copyright Sam Green. All rights reserved.
//

#import "NSArray+Delaunay.h"
#import "DelaunayEdge.h"

@implementation NSArray (Delaunay)

- (NSMutableArray *) reverse {
    NSMutableArray *reverse = [NSMutableArray array];
    for (id obj in self) {
        [reverse insertObject:obj atIndex:0];
    }
    return reverse;
}

- (CGPoint)pointAtIndex:(NSUInteger)index {
    return [self[index] CGPointValue];
}

@end
