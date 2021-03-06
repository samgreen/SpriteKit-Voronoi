//
//  DelaunaySite.m
//  Delaunay
//
//  Created by Sam Green on 4/13/14.
//  Copyright Sam Green. All rights reserved.
//

#import "DelaunaySite.h"
#import "NSArray+Delaunay.h"
#import "DelaunayEdge.h"
#import "NSMutableArray+Delaunay.h"
#import "DelaunayPolygon.h"
#import "DelaunayOrientation.h"
#import "DelaunayEdgeReorderer.h"
#import "DelaunayVertex.h"
#import "Delaunay.h"
#import "DelaunayVoronoi.h"

@interface DelaunaySite ()

@property (nonatomic, strong) NSMutableArray *edges;
@property (nonatomic, strong) NSMutableArray *edgeOrientations;
@property (nonatomic, strong) NSMutableArray *region;

@end

@implementation DelaunaySite

+ (instancetype) siteWithPoint:(CGPoint) point index:(NSInteger) index weight:(float) weight {
    DelaunaySite *result = [[DelaunaySite alloc] init];
    result.coordinates = point;
    result.index = index;
    result.weight = weight;
    result.edges = [NSMutableArray array];
    result.region = nil;
    return result;
}

- (NSComparisonResult) compare:(DelaunaySite *) other {
    return [DelaunayVoronoi compareByYThenXWithSite: self point: other.coordinates];
}

- (NSString *) description {
    return [NSString stringWithFormat: @"S%d (%f, %f)", _index, _coordinates.x, _coordinates.y];
}

- (BOOL) isReal {
    return YES;
}

- (CGFloat) x {
    return _coordinates.x;
}

- (CGFloat) y {
    return _coordinates.y;
}

- (void) move:(CGPoint) point {
    [self clear];
    self.coordinates = point;
}

- (void) clear {
    self.edges = nil;
    self.edgeOrientations = nil;
    self.region = nil;
}

- (void) addEdge:(DelaunayEdge *) edge {
    [self.edges addObject: edge];
}

- (DelaunayEdge *) nearestEdge {
    [self.edges sortUsingSelector:@selector(compare:)];
    return [self.edges objectAtIndex: 0];
}

- (NSArray *) neighborSites {
    if (self.edges && [self.edges count] > 0) {
        if (!self.edgeOrientations) {
            [self reorderEdges];
        }
        NSMutableArray *result = [NSMutableArray array];
        for (DelaunayEdge *edge in self.edges) {
            [result addObject: [self neighborSite: edge]];
        }
        return result;
    } else {
        return [NSArray array];
    }
}

- (DelaunaySite *) neighborSite:(DelaunayEdge *) edge {
    if ([edge leftSite] == self) {
        return [edge rightSite];
    }
    if ([edge rightSite] == self) {
        return [edge leftSite];
    }
    return nil;
}

- (NSMutableArray *) region {
    NSMutableArray *unfilteredVertices = [NSMutableArray array];
    for (DelaunayEdge *edge in self.edges) {
        if (![edge.leftVertex isReal] || ![edge.rightVertex isReal]) {
            // it's on the edge, return an empty region
            return [NSMutableArray array];
        }
        [unfilteredVertices addPoint: edge.leftVertex.coordinates];
        [unfilteredVertices addPoint: edge.rightVertex.coordinates];
        [unfilteredVertices sortUsingComparator:(NSComparator)^(id obj1, id obj2) {
            CGPoint p1 = [obj1 CGPointValue];
            CGPoint p2 = [obj2 CGPointValue];
            float angle1 = atan2f(p1.x - _coordinates.x, p1.y - _coordinates.y); // note risk of div/0, should be handled ok
            float angle2 = atan2f(p2.x - _coordinates.x, p2.y - _coordinates.y);
            if (angle1 < angle2) {
                // We want the sites to go counterclockwise
                // clockwise = larger values of angle
                return NSOrderedDescending;
            } else if (angle1 > angle2) {
                return NSOrderedAscending;
            } else {
                return NSOrderedSame;
            }
        }];
    }
    NSMutableArray *filteredVertices = [NSMutableArray arrayWithObject: [unfilteredVertices objectAtIndex: 0]];
    // Remove duplicate points, or points close to dups
    for (int i=1; i< [unfilteredVertices count]; i++) {
        CGPoint p1 = [[unfilteredVertices objectAtIndex: i-1] CGPointValue];
        CGPoint p2 = [[unfilteredVertices objectAtIndex: i] CGPointValue];
        if (DISTANCE(p1,p2) > FLT_EPSILON) {
            [filteredVertices addPoint: p2];
        }
    }
    return filteredVertices;
}

- (NSMutableArray *) region:(CGRect) clippingBounds {
    if (self.edges && [self.edges count] > 0) {
        if (!_edgeOrientations) {
            [self reorderEdges];
            self.region = [self clipToBounds: clippingBounds];
            DelaunayPolygon *polygon = [DelaunayPolygon polygonWithVertices: self.region];
            if ([polygon winding] == DelaunayWindingClockwise) {
                self.region = [_region reverse];
            }
        }
        return _region;
    } else {
        return [NSMutableArray array];
    }
}

- (void) reorderEdges {
    DelaunayEdgeReorderer *reorderer = [[DelaunayEdgeReorderer alloc] initWithEdges: self.edges criterion: [DelaunayVertex class]];
    self.edges = [reorderer edges];
    self.edgeOrientations = [reorderer edgeOrientations];
}

- (NSMutableArray *) clipToBounds:(CGRect) bounds {
    NSMutableArray *points = [NSMutableArray array];
    //NSMutableSet *uniquePoints = [NSMutableSet set];
    NSInteger i = 0;
    while (i < [_edges count] && ![self.edges[i] visible]) {
        i++;
    }
    if (i == [_edges count]) return points;
    
    DelaunayEdge *edge = self.edges[i];
    DelaunayOrientation orientation = [_edgeOrientations[i] unsignedIntegerValue];
    
    [points addPoint:[edge clippedPoint:orientation]];
    [points addPoint:[edge clippedPoint:OppositeOrientation(orientation)]];
    
    /*
     NSValue *firstPoint = [NSValue valueWithCGPoint: [edge clippedPoint: orientation]];
     if (![uniquePoints containsObject: firstPoint]) {
     [points addObject: firstPoint];
     [uniquePoints addObject: firstPoint];
     }
     NSValue *secondPoint = [NSValue valueWithCGPoint: [edge clippedPoint: [orientation opposite]]];
     if (![uniquePoints containsObject: secondPoint]) {
     [points addObject: secondPoint];
     [uniquePoints addObject: secondPoint];
     }
     */
    
    for (int j = i + 1; j < [_edges count]; j++) {
        DelaunayEdge *edge = self.edges[j];
        if (!edge.visible) continue;

        [self connect: points atIndex: j bounds: bounds closingUp: NO];
    }
    // close up the polygon by adding another corner point of the bounds if needed:
    [self connect:points atIndex:i bounds:bounds closingUp:YES];
    
    return points;
}

- (NSInteger) boundsCheck:(CGPoint)point bounds:(CGRect) bounds {
    // TODO not sure what to do about checking these floats for equality.
    // Need to review the algorithm to see if it makes a difference
    NSInteger result = BoundsMaskNone;
    if (point.x == bounds.origin.x) result |= BoundsMaskLeft;
    if (point.x == bounds.origin.x + bounds.size.width) result |= BoundsMaskRight;
    if (point.y == bounds.origin.y) result |= BoundsMaskTop;
    if (point.y == bounds.origin.y + bounds.size.height) result |= BoundsMaskBottom;
    return result;
}

- (BOOL)closeEnough:(CGPoint)p0 to:(CGPoint)p1 {
    return DISTANCE(p0, p1) < FLT_EPSILON;
}

- (void) connect:(NSMutableArray *) points atIndex:(NSInteger) j bounds:(CGRect) bounds closingUp:(BOOL) closingUp {
    CGPoint rightPoint = [[points lastObject] CGPointValue];
    DelaunayEdge *newEdge = [_edges objectAtIndex: j];
    DelaunayOrientation newOrientation = [self.edgeOrientations[j] unsignedIntegerValue];
    CGPoint newPoint = [newEdge clippedPoint:newOrientation];
    if (![self closeEnough: rightPoint to: newPoint]) {
        // The points do not coincide, so they must have been clipped at the bounds;
        // see if they are on the same border of the bounds:
        if (rightPoint.x != newPoint.x && rightPoint.y != newPoint.y)
        {
            // They are on different borders of the bounds;
            // insert one or two corners of bounds as needed to hook them up:
            // (NOTE this will not be correct if the region should take up more than
            // half of the bounds rect, for then we will have gone the wrong way
            // around the bounds and included the smaller part rather than the larger)
            NSInteger rightCheck = [self boundsCheck: rightPoint bounds: bounds];
            NSInteger newCheck = [self boundsCheck: newPoint bounds: bounds];
            float px, py;
            if (rightCheck & BoundsMaskRight) {
                px = bounds.origin.x + bounds.size.width;
                if (newCheck & BoundsMaskBottom) {
                    py = bounds.origin.y + bounds.size.height;
                    [points addPoint: CGPointMake(px, py)];
                } else if (newCheck & BoundsMaskTop) {
                    py = bounds.origin.y;
                    [points addPoint: CGPointMake(px, py)];
                } else if (newCheck & BoundsMaskLeft) {
                    if (rightPoint.y - bounds.origin.y + newPoint.y - bounds.origin.y < bounds.size.height) {
                        py = bounds.origin.y;
                    } else {
                        py = bounds.origin.y + bounds.size.height;
                    }
                    [points addPoint: CGPointMake(px, py)];
                    [points addPoint: CGPointMake(bounds.origin.x, py)];
                }
            } else if (rightCheck & BoundsMaskLeft) {
                px = bounds.origin.x;
                if (newCheck & BoundsMaskBottom)
                {
                    py = bounds.origin.y + bounds.size.height;
                    [points addPoint: CGPointMake(px, py)];
                } else if (newCheck & BoundsMaskTop) {
                    py = bounds.origin.y;
                    [points addPoint: CGPointMake(px, py)];
                } else if (newCheck & BoundsMaskRight) {
                    if (rightPoint.y - bounds.origin.y + newPoint.y - bounds.origin.y < bounds.size.height) {
                        py = bounds.origin.y;
                    } else {
                        py = bounds.origin.y + bounds.size.height;
                    }
                    [points addPoint: CGPointMake(px, py)];
                    [points addPoint: CGPointMake(bounds.origin.x + bounds.size.width, py)];
                }
            } else if (rightCheck & BoundsMaskTop) {
                py = bounds.origin.y;
                if (newCheck & BoundsMaskRight) {
                    px = bounds.origin.x + bounds.size.width;
                    [points addPoint: CGPointMake(px, py)];
                } else if (newCheck & BoundsMaskLeft) {
                    px = bounds.origin.x;
                    [points addPoint: CGPointMake(px, py)];
                } else if (newCheck & BoundsMaskBottom) {
                    if (rightPoint.x - bounds.origin.x + newPoint.x - bounds.origin.x < bounds.size.width) {
                        px = bounds.origin.x;
                    } else {
                        px = bounds.origin.x + bounds.size.width;
                    }
                    [points addPoint: CGPointMake(px, py)];
                    [points addPoint: CGPointMake(px, bounds.origin.y + bounds.size.height)];
                }
            } else if (rightCheck & BoundsMaskBottom) {
                py = bounds.origin.y + bounds.size.height;
                if (newCheck & BoundsMaskRight) {
                    px = bounds.origin.x + bounds.size.width;
                    [points addPoint: CGPointMake(px, py)];
                } else if (newCheck & BoundsMaskLeft) {
                    px = bounds.origin.x;
                    [points addPoint: CGPointMake(px, py)];
                } else if (newCheck & BoundsMaskTop) {
                    if (rightPoint.x - bounds.origin.x + newPoint.x - bounds.origin.x < bounds.size.width) {
                        px = bounds.origin.x;
                    } else {
                        px = bounds.origin.x + bounds.size.width;
                    }
                    [points addPoint: CGPointMake(px, py)];
                    [points addPoint: CGPointMake(px, bounds.origin.y)];
                }
            }
        }
        if (closingUp)
        {
            // newEdge's ends have already been added
            return;
        }
        [points addPoint: newPoint];
    }
    CGPoint newRightPoint = [newEdge clippedPoint:OppositeOrientation(newOrientation)];
    if (![self closeEnough: [[points objectAtIndex:0] CGPointValue] to:newRightPoint])
    {
        [points addPoint: newRightPoint];
    }
}

@end
