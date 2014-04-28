//
//  DelaunayVertex.m
//  Delaunay
//
//  Created by Sam Green on 4/14/14.
//  Copyright Sam Green. All rights reserved.
//

#import "DelaunayVertex.h"
#import "DelaunayHalfEdge.h"
#import "DelaunayEdge.h"
#import "DelaunayVoronoi.h"
#import "DelaunaySite.h"
#import "DelaunayOrientation.h"

@interface DelaunayVertex ()

@end

@implementation DelaunayVertex

+ (instancetype)vertexWithX:(CGFloat)x y:(CGFloat)y {
    if (x == NAN || y == NAN) {
        return [self vertexAtInfinity];
    } else {
        return [[DelaunayVertex alloc] initWithX:x andY:y];
    }
}

- (instancetype)initWithX:(CGFloat)x andY:(CGFloat)y {
    self = [super init];
    if (self) {
        self.coordinates = CGPointMake(x, y);
        self.index = -1;
    }
    return self;
}

+ (instancetype)vertexAtInfinity {
    static DelaunayVertex *gInfinityVertex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gInfinityVertex = [self vertexWithX:NAN y:NAN];
        gInfinityVertex.index = -1;
    });
    return gInfinityVertex;
}

+ (instancetype)intersect:(DelaunayHalfEdge *)halfEdge0 with:(DelaunayHalfEdge *)halfEdge1 {
    DelaunayEdge *edge0 = halfEdge0.edge;
    DelaunayEdge *edge1 = halfEdge1.edge;
    
    if (edge0 == nil || edge1 == nil || edge0.rightSite == edge1.rightSite) {
        return nil;
    }
    
    CGFloat determinant = edge0.a * edge1.b - edge0.b * edge1.a;
    if (-1.0e-10 < determinant && determinant < 1.0e-10) {
        // the edges are parallel
        return nil;
    }
    
    CGFloat intersectionX = (edge0.c * edge1.b - edge1.c * edge0.b)/determinant;
    CGFloat intersectionY = (edge1.c * edge0.a - edge0.c * edge1.a)/determinant;
    
    DelaunayEdge *lowerEdge = edge1;
    DelaunayHalfEdge *lowerHalfEdge = halfEdge1;
    if ((edge0.rightSite.y < edge1.rightSite.y) ||
        (edge0.rightSite.y == edge1.rightSite.y && edge0.rightSite.x < edge1.rightSite.x))
    {
        lowerHalfEdge = halfEdge0;
        lowerEdge = edge0;
    }
    
    BOOL rightOfSite = intersectionX >= lowerEdge.rightSite.x;
    BOOL lowerOrientationLeft = OrientationIsLeft(lowerHalfEdge.orientation);
    if ((rightOfSite && lowerOrientationLeft) ||  (!rightOfSite && !lowerOrientationLeft)) {
        return nil;
    }
    
    return [DelaunayVertex vertexWithX:intersectionX y:intersectionY];
}

#pragma mark - Accessors
- (CGFloat)x {
    return self.coordinates.x;
}

- (CGFloat)y {
    return self.coordinates.y;
}

- (BOOL) isReal {
    return self.index >= 0;
}

- (NSString *) description {
    return [NSString stringWithFormat: @"V%d:(%f, %f)", self.index, _coordinates.x, _coordinates.y];
}

@end
