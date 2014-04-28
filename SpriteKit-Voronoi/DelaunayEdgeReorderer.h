//
//  DelaunayEdgeReorderer.h
//  Delaunay
//
//  Created by Sam Green on 4/14/14.
//  Copyright Sam Green. All rights reserved.
//

@import Foundation;


@interface DelaunayEdgeReorderer : NSObject {
    
}

@property (nonatomic, strong) NSMutableArray *edges; 
@property (nonatomic, strong) NSMutableArray *edgeOrientations;

- (id) initWithEdges:(NSArray *) originalEdges criterion:(Class) klass;
- (NSMutableArray *) reorderEdges:(NSArray *) originalEdges criterion:(Class) criterion;


@end
