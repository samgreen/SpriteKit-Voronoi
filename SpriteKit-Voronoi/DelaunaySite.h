//
//  DelaunaySite.h
//  Delaunay
//
//  Created by Sam Green on 4/13/14.
//  Copyright Sam Green. All rights reserved.
//

@import Foundation;

#import "DelaunayCoordinate.h"

@class DelaunayEdge;

typedef NS_ENUM(NSUInteger, BoundsMask) {
   BoundsMaskNone   = 0,
   BoundsMaskTop    = 1,
   BoundsMaskBottom = 2,
   BoundsMaskLeft   = 4,
   BoundsMaskRight  = 8
};

@interface DelaunaySite : NSObject <DelaunayCoordinate>

@property (nonatomic) CGPoint coordinates;
@property (nonatomic, readonly) CGFloat x;
@property (nonatomic, readonly) CGFloat y;

@property (nonatomic) NSUInteger index;
@property (nonatomic) float weight;

+ (instancetype) siteWithPoint:(CGPoint) point index:(NSInteger) index weight:(float) weight;


- (void) move:(CGPoint) point;
- (void) clear;
- (void) addEdge:(DelaunayEdge *) edge;
- (NSMutableArray *) region;
- (DelaunayEdge *) nearestEdge;
- (NSArray *) neighborSites;
- (NSMutableArray *) region:(CGRect) clippingBounds;
- (DelaunaySite *) neighborSite:(DelaunayEdge *) edge;
- (void) reorderEdges;
- (NSMutableArray *) clipToBounds:(CGRect) bounds;
- (NSInteger) boundsCheck:(CGPoint)point bounds:(CGRect) bounds;
- (void) connect:(NSMutableArray *) points atIndex:(NSInteger) j bounds:(CGRect) bounds closingUp:(BOOL) closingUp;
- (BOOL) closeEnough:(CGPoint) p0 to:(CGPoint) p1;

@end
