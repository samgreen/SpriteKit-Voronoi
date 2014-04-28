//
//  DelaunayHalfEdge.h
//  Delaunay
//
//  Created by Sam Green on 4/14/14.
//  Copyright Sam Green. All rights reserved.
//

@import Foundation;

#import "DelaunayOrientation.h"

@class DelaunayEdge, DelaunayVertex;

@interface DelaunayHalfEdge : NSObject

@property (nonatomic, strong) DelaunayHalfEdge *edgeListLeftNeighbor;
@property (nonatomic, strong) DelaunayHalfEdge *edgeListRightNeighbor;
@property (nonatomic, strong) DelaunayHalfEdge *nextInPriorityQueue;

@property (nonatomic, strong) DelaunayEdge *edge;
@property (nonatomic, strong) DelaunayVertex *vertex;

@property (nonatomic) DelaunayOrientation orientation;

// The vertex's y-coordinate in the transformed Voronoi space
@property (nonatomic) CGFloat ystar;

+ (instancetype)dummy;
+ (instancetype)halfEdgeWithEdge:(DelaunayEdge *)edge orientation:(DelaunayOrientation)orientation;

- (BOOL)isRightOf:(CGPoint)p;

@end
