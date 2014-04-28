//
//  DelaunayVoronoi.m
//  Delaunay
//
//  Created by Sam Green on 4/13/14.
//  Copyright Sam Green. All rights reserved.
//

#import "DelaunayVoronoi.h"
#import "Delaunay.h"
#import "DelaunaySiteList.h"
#import "DelaunaySite.h"
#import "DelaunayVertex.h"
#import "DelaunayOrientation.h"
#import "DelaunayHalfEdge.h"
#import "DelaunayHalfEdgePriorityQueue.h"
#import "DelaunayEdgeList.h"
#import "DelaunayEdge.h"

@implementation DelaunayVoronoi

+ (instancetype)voronoi:(NSArray *)sites plotBounds:(CGRect)plotBounds {
    return [[DelaunayVoronoi alloc] initWithPoints:sites andBounds:plotBounds];
}

- (instancetype)initWithPoints:(NSArray *)points andBounds:(CGRect)bounds {
    self = [super init];
    if (self) {
        self.plotBounds = bounds;
        
        self.sitesIndexedByLocation = [@{} mutableCopy];
        self.triangles = [@[] mutableCopy];
        self.edges = [@[] mutableCopy];
        
        self.siteList = [DelaunaySiteList list];
        
        [self addSites:points];
        [self fortunesAlgorithm];
    }
    return self;
}

+ (NSComparisonResult) compareByYThenXWithSite:(DelaunaySite *) s1 point:(CGPoint)s2 {
    if (s1.y < s2.y) return NSOrderedAscending;
    if (s1.x < s2.x) return NSOrderedAscending;
    
    if (s1.y > s2.y) return NSOrderedDescending;
    if (s1.x > s2.x) return NSOrderedDescending;
    
    return NSOrderedSame;
}

- (NSArray *)regions {
    return [_siteList regions:_plotBounds];
}

- (void)addSites:(NSArray *) points {
    NSInteger index = 0;
    for (NSValue *pointValue in points) {
        [self addSite: pointValue index: index];
        index++;
    }
}

- (NSArray *)regionForPoint:(CGPoint)p {
    NSValue *pValue = [NSValue valueWithCGPoint:p];
    DelaunaySite *site = self.sitesIndexedByLocation[pValue];
    
    NSLog(@"Site for point (%f,%f) is %@", p.x, p.y, site);
    
    if (site) {
        return [site region:self.plotBounds];
    }
    return @[];
}

- (void)addSite:(NSValue *)pointValue index:(NSUInteger)index {
    CGFloat weight = ((CGFloat)random()) / RANDOM_MAX;
    DelaunaySite *site = [DelaunaySite siteWithPoint:[pointValue CGPointValue] index: index weight:weight];
    
    [self.siteList addSite:site];
    self.sitesIndexedByLocation[pointValue] = site;
}

- (void) fortunesAlgorithm {
    DelaunaySite *newSite;
    DelaunaySite *bottomSite;
    DelaunaySite *topSite;
    DelaunaySite *tempSite;
    DelaunayVertex *v;
    DelaunayVertex *vertex;
    CGPoint newintstar;
    DelaunayOrientation orientation;
    DelaunayHalfEdge *lbnd;
    DelaunayHalfEdge *rbnd;
    DelaunayHalfEdge *llbnd;
    DelaunayHalfEdge *rrbnd;
    DelaunayHalfEdge *firstBisector;
    DelaunayHalfEdge *secondBisector;
    DelaunayHalfEdge *thirdBisector;
    DelaunayEdge *edge;
    
    newintstar.x = 0;
    newintstar.y = 0;
    
    NSInteger vertexIndex = 0;
    
    CGRect dataBounds = [self.siteList bounds];
    int sqrt_nsites = (int) sqrtf((float)[self.siteList count] + 4);
    DelaunayHalfEdgePriorityQueue *heap = [DelaunayHalfEdgePriorityQueue queueWithMinY: dataBounds.origin.y
                                                                                deltaY: dataBounds.size.height
                                                                          sqrtNumSites: sqrt_nsites];
    
    DelaunayEdgeList *edgeList = [DelaunayEdgeList edgeListWithMinX: dataBounds.origin.x
                                                             deltaX: dataBounds.size.width
                                                       sqrtNumSites: sqrt_nsites];
    
    NSMutableArray *halfEdgesForCurrentSite = [NSMutableArray array];
    
    bottomMostSite = [self.siteList next];
    NSLog(@"%@", bottomMostSite);
    newSite = [self.siteList next];
    
    NSInteger loopCount = 0;
    while (true) {
        loopCount++;
        //NSLog(@"heap = %@", heap);
        if (![heap empty]) {
            newintstar = [heap min];
        }
        
        BOOL newSiteIsLessThanNewInTStar = [DelaunayVoronoi compareByYThenXWithSite: newSite point: newintstar] == NSOrderedAscending;
        if ((newSite != nil) && ([heap empty] || newSiteIsLessThanNewInTStar))
        {
            NSLog(@"%@", newSite);
            lbnd = [edgeList edgeListLeftNeighbor: newSite.coordinates];	// the Halfedge just to the left of newSite
            rbnd = [lbnd edgeListRightNeighbor];		// the Halfedge just to the right
            bottomSite = [self rightRegion: lbnd];		// this is the same as leftRegion(rbnd)
            // this Site determines the region containing the new site
            
            // Step 9:
            edge = [DelaunayEdge edgeBisectingSite: bottomSite and: newSite];
            [self.edges addObject: edge];
            
            firstBisector = [DelaunayHalfEdge halfEdgeWithEdge: edge orientation: DelaunayOrientationLeft];
            [halfEdgesForCurrentSite addObject: firstBisector];
            
            // inserting two Halfedges into edgeList constitutes Step 10:
            // insert bisector to the right of lbnd:
            [edgeList toRightOf: lbnd insert:firstBisector];
            
            // first half of Step 11:
            if ((vertex = [DelaunayVertex intersect: lbnd with: firstBisector]) != nil)
            {
                [heap remove: lbnd];
                [heap insert: lbnd vertex: vertex offset: DISTANCE(newSite, vertex)];
            }
            
            lbnd = firstBisector;
            secondBisector = [DelaunayHalfEdge halfEdgeWithEdge: edge orientation:DelaunayOrientationRight];
            [halfEdgesForCurrentSite addObject: secondBisector];
            
            // second Halfedge for Step 10:
            // insert bisector to the right of lbnd:
            [edgeList toRightOf: lbnd insert: secondBisector];
            
            
            // second half of Step 11:
            if ((vertex = [DelaunayVertex intersect: secondBisector with: rbnd]) != nil)
            {
                [heap insert: secondBisector vertex: vertex offset: DISTANCE(newSite, vertex)];
            }
            
            newSite = [self.siteList next];
        } else if (![heap empty]) {
            /* intersection is smallest */
            lbnd = [heap extractMin];
            NSLog(@"Extracted min: %@", lbnd);
            
            llbnd = lbnd.edgeListLeftNeighbor;
            rbnd = lbnd.edgeListRightNeighbor;
            rrbnd = rbnd.edgeListRightNeighbor;
            bottomSite = [self leftRegion: lbnd];
            topSite = [self rightRegion: rbnd];
            // these three sites define a Delaunay triangle
            // (not actually using these for anything...)
            //_triangles.push(new Triangle(bottomSite, topSite, rightRegion(lbnd)));
            
            v = lbnd.vertex;
            v.index = vertexIndex++;
            NSLog(@"%@", v);
            
            [lbnd.edge setVertex: v withOrientation: lbnd.orientation];
            [rbnd.edge setVertex: v withOrientation: rbnd.orientation];
            
            [edgeList remove:lbnd];
            [heap remove:rbnd];
            [edgeList remove:rbnd];
            
            orientation = DelaunayOrientationLeft;
            
            if (bottomSite.y > topSite.y) {
                tempSite = bottomSite;
                bottomSite = topSite;
                topSite = tempSite;
                orientation = DelaunayOrientationRight;
            }
            edge = [DelaunayEdge edgeBisectingSite: bottomSite and: topSite];
            [_edges addObject: edge];
            thirdBisector = [DelaunayHalfEdge halfEdgeWithEdge: edge orientation: orientation];
            [halfEdgesForCurrentSite addObject: thirdBisector];
            [edgeList toRightOf: llbnd insert: thirdBisector];
            
            [edge setVertex:v withOrientation:OppositeOrientation(orientation)];
            if ((vertex = [DelaunayVertex intersect: llbnd with: thirdBisector]) != nil)
            {
                [heap remove: llbnd];
                [heap insert: llbnd vertex: vertex offset: DISTANCE(bottomSite, vertex)];
            }
            if ((vertex = [DelaunayVertex intersect: thirdBisector with: rrbnd]) != nil)
            {
                [heap insert: thirdBisector vertex: vertex offset: DISTANCE(bottomSite, vertex)];
            }
        }
        else
        {
            break;
        }
    }
    
    for( lbnd = edgeList.leftEnd.edgeListRightNeighbor ;
        lbnd != edgeList.rightEnd ;
        lbnd = lbnd.edgeListRightNeighbor) {
        NSLog(@"%@", lbnd.edge);
    }
}

- (DelaunaySite *) leftRegion:(DelaunayHalfEdge *)halfEdge {
    DelaunayEdge *edge = halfEdge.edge;
    if (edge == nil) {
        return bottomMostSite;
    }
    return [edge siteWithOrientation:halfEdge.orientation];
}

- (DelaunaySite *)rightRegion:(DelaunayHalfEdge *)halfEdge {
    DelaunayEdge *edge = halfEdge.edge;
    if (edge == nil) {
        return bottomMostSite;
    }
    return [edge siteWithOrientation:OppositeOrientation(halfEdge.orientation)];
}

- (NSString *) description {
    return [NSString stringWithFormat: @"Voronoi (\nplotBounds:(%f,%f,%f,%f) \nsiteList: %@ \nedges: %@)", _plotBounds.origin.x, _plotBounds.origin.y, _plotBounds.size.width, _plotBounds.size.height, _siteList, _edges];
}

@end
