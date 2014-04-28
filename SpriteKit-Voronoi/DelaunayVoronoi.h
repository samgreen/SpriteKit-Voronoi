//
//  DelaunayVoronoi.h
//  Delaunay
//
//  Created by Sam Green on 4/13/14.
//  Copyright Sam Green. All rights reserved.
//

@import Foundation;

@class DelaunaySiteList, DelaunaySite, DelaunayHalfEdge;

@interface DelaunayVoronoi : NSObject {
   DelaunaySite *bottomMostSite;
}

@property (nonatomic, strong) DelaunaySiteList *siteList;
@property (nonatomic, strong) NSMutableDictionary *sitesIndexedByLocation;
@property (nonatomic, strong) NSMutableArray *triangles;
@property (nonatomic, strong) NSMutableArray *edges;

@property (nonatomic) CGRect plotBounds;

+ (instancetype)voronoi:(NSArray *)sites plotBounds:(CGRect) plotBounds;
+ (NSComparisonResult)compareByYThenXWithSite:(DelaunaySite *)s1 point:(CGPoint)s2;

- (void)addSites:(NSArray *)points;
- (void)addSite:(NSValue *)pointValue index:(NSUInteger)index;

- (void)fortunesAlgorithm;

- (DelaunaySite *)leftRegion:(DelaunayHalfEdge *)halfEdge;
- (DelaunaySite *)rightRegion:(DelaunayHalfEdge *)halfEdge;

- (NSArray *)regionForPoint:(CGPoint) p;
- (NSArray *)regions;


@end
