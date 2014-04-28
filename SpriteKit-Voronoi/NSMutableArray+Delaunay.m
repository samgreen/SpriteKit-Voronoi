//
//  Delaunay.m
//  Delaunay
//
//  Created by Sam Green on 4/13/14.
//  Copyright Sam Green. All rights reserved.
//

#import "Delaunay.h"


@implementation NSMutableArray (Delaunay)


- (void) addPoint:(CGPoint) point {
   [self addObject: [NSValue valueWithCGPoint: point]];
}

@end
