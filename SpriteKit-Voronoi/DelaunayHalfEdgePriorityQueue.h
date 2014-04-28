//
//  DelaunayHalfEdgePriorityQueue.h
//  Delaunay
//
//  Created by Sam Green on 4/13/14.
//  Copyright Sam Green. All rights reserved.
//

@import Foundation;

@class DelaunayHalfEdge, DelaunayVertex;

@interface DelaunayHalfEdgePriorityQueue : NSObject {
   NSMutableArray *hash;
   NSInteger count;
   NSInteger minBucket;
   NSInteger hashSize;
   CGFloat minY;
   CGFloat maxY;
   CGFloat deltaY;
    
}

+ (instancetype) queueWithMinY:(CGFloat) minY deltaY:(CGFloat) deltaY sqrtNumSites:(NSInteger) sqrtNumSites;
- (id) initWithMinY:(CGFloat) _minY deltaY:(CGFloat) _deltaY sqrtNumSites:(CGFloat) _sqrtNumSites;

- (void) insert:(DelaunayHalfEdge *) halfEdge vertex:(DelaunayVertex *) v offset:(CGFloat) offset;
- (NSInteger) bucket:(DelaunayHalfEdge *) halfEdge;
- (void) remove:(DelaunayHalfEdge *) halfEdge;
- (BOOL) empty;
- (DelaunayHalfEdge *) extractMin;

- (CGPoint) min;

@end
