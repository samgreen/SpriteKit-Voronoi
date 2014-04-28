//
//  DelaunayEdgeReorderer.m
//  Delaunay
//
//  Created by Sam Green on 4/14/14.
//  Copyright Sam Green. All rights reserved.
//

#import "DelaunayEdgeReorderer.h"
#import "DelaunayEdge.h"
#import "DelaunayOrientation.h"
#import "DelaunayCoordinate.h"
#import "DelaunayVertex.h"
#import "DelaunaySite.h"

@implementation DelaunayEdgeReorderer

- (id)initWithEdges:(NSArray *)originalEdges criterion:(Class)klass {
    self = [super init];
    if (self) {
        self.edges = [NSMutableArray array];
        self.edgeOrientations = [NSMutableArray array];
        
        if ([originalEdges count] > 0) {
            self.edges = [self reorderEdges:originalEdges criterion:klass];
        }
    }
    return self;
    
}

- (NSMutableArray *) reorderEdges:(NSArray *) originalEdges criterion:(Class) criterion {
    NSMutableArray *newEdges = [NSMutableArray array];
    NSMutableArray *doneItems = [NSMutableArray array];
    
    NSInteger n = [originalEdges count];
    for (NSUInteger k = 0; k < n; k++) {
        [doneItems addObject:@(NO)];
    }
    
    id<DelaunayCoordinate> firstPoint;
    id<DelaunayCoordinate> lastPoint;
    
    NSInteger nDone = 1;
    while (nDone < n) {
        for (NSUInteger i = 0; i < n; ++i) {
            if ([doneItems[i] boolValue]) continue;

            DelaunayEdge *edge = originalEdges[i];
            
            id<DelaunayCoordinate> leftPoint;
            id<DelaunayCoordinate> rightPoint;
            if (i == 0) {
                if (criterion == [DelaunayVertex class]) {
                    firstPoint = edge.leftVertex;
                    lastPoint = edge.rightVertex;
                } else {
                    firstPoint = edge.leftSite;
                    lastPoint = edge.rightSite;
                }
                
                if (![firstPoint isReal] || ![lastPoint isReal]) {
                    return [NSMutableArray array];
                }
                
            } else {
                if (criterion == [DelaunayVertex class]) {
                    leftPoint = edge.leftVertex;
                    rightPoint = edge.rightVertex;
                } else { // Site
                    leftPoint = edge.leftSite;
                    rightPoint = edge.rightSite;
                }
            }
            
            if (![leftPoint isReal] || ![rightPoint isReal]) {
                return [@[] mutableCopy];
            }
            if (i == 0) continue;
            
            if (leftPoint == lastPoint) {
                lastPoint = rightPoint;
                
                [_edgeOrientations addObject:@(DelaunayOrientationLeft)];
                [newEdges addObject: edge];
                
                doneItems[i] = @(YES);
            } else if (rightPoint == firstPoint) {
                firstPoint = leftPoint;
                
                [_edgeOrientations insertObject:@(DelaunayOrientationRight) atIndex: 0];
                [newEdges insertObject: edge atIndex: 0];
                
                doneItems[i] = @(YES);
            } else if (leftPoint == firstPoint) {
                firstPoint = rightPoint;
                
                [_edgeOrientations insertObject:@(DelaunayOrientationRight) atIndex: 0];
                [newEdges insertObject: edge atIndex: 0];
                
                doneItems[i] = @(YES);
            } else if (rightPoint == lastPoint) {
                lastPoint = leftPoint;
                
                [_edgeOrientations addObject:@(DelaunayOrientationRight)];
                [newEdges addObject: edge];
                
                doneItems[i] = @(YES);
            }
            
            if ([doneItems[i] boolValue]) nDone++;
        }
    }
    
    return newEdges;
}

@end

