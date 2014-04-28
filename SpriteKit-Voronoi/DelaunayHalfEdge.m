//
//  DelaunayHalfEdge.m
//  Delaunay
//
//  Created by Sam Green on 4/14/14.
//  Copyright Sam Green. All rights reserved.
//

#import "DelaunayHalfEdge.h"
#import "DelaunaySite.h"
#import "DelaunayVertex.h"
#import "DelaunayEdge.h"
#import "Delaunay.h"
#import "DelaunayOrientation.h"

@implementation DelaunayHalfEdge

+ (instancetype)dummy {
    return [[DelaunayHalfEdge alloc] init];
}

+ (instancetype)halfEdgeWithEdge:(DelaunayEdge *)edge orientation:(DelaunayOrientation) orientation {
    return [[DelaunayHalfEdge alloc] init];
}

- (instancetype)initWithEdge:(DelaunayEdge *)edge andOrientation:(DelaunayOrientation)orientation {
    self = [super init];
    if (self) {
        _edge = edge;
        _orientation = orientation;
    }
    return self;
}

- (BOOL)isRightOf:(CGPoint)p {
    DelaunaySite *topSite = _edge.rightSite;
    BOOL rightOfSite = (p.x > topSite.x);
    if (rightOfSite && OrientationIsLeft(_orientation)) {
        return YES;
    }
    
    if (!rightOfSite && OrientationIsRight(_orientation)) {
        return NO;
    }
    
    BOOL above;
    if (_edge.a == 1.0) {
        BOOL fast = NO;
        
        CGFloat dyp = p.y - topSite.y;
        CGFloat dxp = p.x - topSite.x;
        
        if ((!rightOfSite && _edge.b < 0.0) || (rightOfSite && _edge.b >= 0.0)) {
            above = dyp >= _edge.b * dxp;
            fast = above;
        } else {
            above = p.x + p.y * _edge.b > _edge.c;
            
            if (_edge.b < 0.0) {
                above = !above;
            }
            
            if (!above) {
                fast = YES;
            }
        }
        
        if (!fast) {
            CGFloat dxs = topSite.x - _edge.leftSite.x;
            above = _edge.b * (dxp * dxp - dyp * dyp) <
            dxs * dyp * (1.0 + 2.0 * dxp/dxs + _edge.b * _edge.b);
            
            if (_edge.b < 0.0) {
                above = !above;
            }
        }
    } else {
        /* edge.b == 1.0 */
        CGFloat yl = _edge.c - _edge.a * p.x;
        CGFloat t1 = p.y - yl;
        CGFloat t2 = p.x - topSite.x;
        CGFloat t3 = yl - topSite.y;
        above = t1 * t1 > t2 * t2 + t3 * t3;
    }
    
    return OrientationIsLeft(_orientation) ? above : !above;
}

- (NSString *) description {
    return [NSString stringWithFormat: @"HalfEdge (id: %p vertex: %d edge: %d - %d orientation: %@ leftNeighbor: %p rightNeighbor: %p nextInPriorityQueue: %p ystar: %f",
            self, self.vertex == nil ? -100 : self.vertex.index, self.edge.leftSite ? self.edge.leftSite.index : -1, self.edge.rightSite ? self.edge.rightSite.index : -1, OrientationDescription(self.orientation), self.edgeListLeftNeighbor, self.edgeListRightNeighbor, self.nextInPriorityQueue, self.ystar];
}

@end
