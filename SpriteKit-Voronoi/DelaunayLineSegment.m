//
//  DelaunayLineSegment.m
//  Delaunay
//
//  Created by Sam Green on 4/14/14.
//  Copyright Sam Green. All rights reserved.
//

#import "DelaunayLineSegment.h"

#import "Delaunay.h"

@interface DelaunayLineSegment ()

@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;

@end

@implementation DelaunayLineSegment

+ (instancetype)segmentWithStart:(CGPoint)left andEnd:(CGPoint)right {
    NSValue *leftValue = [NSValue valueWithCGPoint:left];
    NSValue *rightValue = [NSValue valueWithCGPoint:right];
    return [[DelaunayLineSegment alloc] initWithPoints:@[leftValue, rightValue]];
}

- (instancetype)initWithPoints:(NSArray *)points {
    self = [super init];
    if (self) {
        _startPoint = [[points firstObject] CGPointValue];
        _endPoint = [[points lastObject] CGPointValue];
    }
    return self;
}

- (NSComparisonResult)compareLonger:(DelaunayLineSegment *)other {
    if ([self length] < [other length]) {
        return NSOrderedAscending;
    } else if ([self length] > [other length]) {
        return NSOrderedDescending;
    }
    
    return NSOrderedSame;
}

- (NSComparisonResult)compareShorter:(DelaunayLineSegment *)other {
    return [self compareLonger:other];
}

- (CGFloat)length {
    return DISTANCE(_startPoint, _endPoint);
}

@end
