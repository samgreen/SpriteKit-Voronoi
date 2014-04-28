//
//  DelaunayPolygon.m
//  Delaunay
//
//  Created by Sam Green on 4/13/14.
//  Copyright Sam Green. All rights reserved.
//

#import "DelaunayPolygon.h"
#import "NSArray+Delaunay.h"

@interface DelaunayPolygon ()

@property (nonatomic, strong) NSMutableArray *vertices;

@end

@implementation DelaunayPolygon

+ (instancetype)polygonWithVertices:(NSMutableArray *)vertices {
    return [[DelaunayPolygon alloc] initWithVertices:vertices];
}

- (instancetype)initWithVertices:(NSArray *)vertices {
    self = [super init];
    if (self) {
        self.vertices = [vertices mutableCopy];
    }
    return self;
}

- (DelaunayWinding)winding {
    CGFloat signedDoubleArea = [self signedDoubleArea];
    if (signedDoubleArea < 0) {
        return DelaunayWindingClockwise;
    } else if (signedDoubleArea > 0) {
        return DelaunayWindingCounterClockwise;
    }
    return DelaunayWindingNone;
}

- (CGFloat)area {
    return ABS([self signedDoubleArea] * 0.5);
}

- (CGFloat)signedDoubleArea {
    CGPoint point = CGPointZero, next = CGPointZero;
    CGFloat result = 0.0;
    
    for (NSUInteger index = 0, nextIndex = 0; index < [_vertices count]; index++, nextIndex = nextIndex + 1 % [_vertices count]) {
        point = [_vertices[index] CGPointValue];
        next = [_vertices[nextIndex] CGPointValue];
        result += point.x * next.y - next.x * point.y;
    }
    
    return result;
}


@end
