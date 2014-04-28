//
//  DelaunayVertex.h
//  Delaunay
//
//  Created by Sam Green on 4/14/14.
//  Copyright Sam Green. All rights reserved.
//

@import Foundation;
#import "DelaunayCoordinate.h"

@class DelaunayHalfEdge;

@interface DelaunayVertex : NSObject <DelaunayCoordinate>

@property (nonatomic) CGPoint coordinates;
@property (nonatomic, readonly) CGFloat x;
@property (nonatomic, readonly) CGFloat y;

@property (nonatomic) NSInteger index;

+ (instancetype)vertexWithX:(CGFloat)x y:(CGFloat)y;
+ (instancetype)vertexAtInfinity;
+ (instancetype)intersect:(DelaunayHalfEdge *)halfedge0 with:(DelaunayHalfEdge *)halfedge1;


@end
