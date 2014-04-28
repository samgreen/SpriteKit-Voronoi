//
//  DelaunayEdgeList.h
//  Delaunay
//
//  Created by Sam Green on 4/13/14.
//  Copyright Sam Green. All rights reserved.
//

@import Foundation;

@class DelaunayHalfEdge;

@interface DelaunayEdgeList : NSObject {
   NSInteger hashSize;
   NSMutableArray *hash;
}

@property (nonatomic, readonly) CGFloat deltaX;
@property (nonatomic, readonly) CGFloat minX;

@property (nonatomic, strong) DelaunayHalfEdge *leftEnd;
@property (nonatomic, strong) DelaunayHalfEdge *rightEnd;

+ (instancetype) edgeListWithMinX:(CGFloat) _minX deltaX:(CGFloat) _deltaX sqrtNumSites:(NSInteger) _sqrtNumSites;

- (id) initWithMinX:(CGFloat) _minX deltaX:(CGFloat) _deltaX sqrtNumSites:(NSInteger) _sqrtNumSites;
- (DelaunayHalfEdge *) edgeListLeftNeighbor:(CGPoint) p;
- (void) toRightOf:(DelaunayHalfEdge *) lb insert:(DelaunayHalfEdge *) newHalfEdge;
- (void) remove:(DelaunayHalfEdge *) halfEdge;

@end
