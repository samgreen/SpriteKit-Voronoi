//
//  DelaunayEdge.h
//  Delaunay
//
//  Created by Sam Green on 4/13/14.
//  Copyright Sam Green. All rights reserved.
//

@import Foundation;

#import "DelaunayOrientation.h"

@class DelaunaySite, DelaunayVertex, DelaunayLineSegment;

@interface DelaunayEdge : NSObject

@property (nonatomic, strong) DelaunaySite *leftSite;
@property (nonatomic, strong) DelaunaySite *rightSite;
@property (nonatomic, strong) DelaunayVertex *leftVertex;
@property (nonatomic, strong) DelaunayVertex *rightVertex;

@property (nonatomic) CGPoint leftClippedPoint;
@property (nonatomic) CGPoint rightClippedPoint;

// the equation of the edge: ax + by = c
@property (nonatomic) CGFloat a;
@property (nonatomic) CGFloat b;
@property (nonatomic) CGFloat c;

@property (nonatomic) BOOL visible;

+ (instancetype)deletedEdge;
+ (instancetype)edgeBisectingSite:(DelaunaySite *)site1 and:(DelaunaySite *) site2;

- (DelaunayLineSegment *)delaunayLine;
- (CGPoint)clippedPoint:(DelaunayOrientation)orientation;

- (DelaunayVertex *)vertexWithOrientation:(DelaunayOrientation)orientation;
- (void)setVertex:(DelaunayVertex *)vertex withOrientation:(DelaunayOrientation)orientation;

- (void)setSite:(DelaunaySite *)site withOrientation:(DelaunayOrientation)orientation;
- (DelaunaySite *)siteWithOrientation:(DelaunayOrientation)orientation;

- (void)clipToBounds:(CGRect)bounds;
- (BOOL)isPartOfConvexHull;
- (CGFloat)sitesDistance;

- (NSComparisonResult)compareSitesLonger:(DelaunayEdge *)other;
- (NSComparisonResult)compareSitesShorter:(DelaunayEdge *)other;

@end
