//
//  DelaunayCoordinate.h
//  Delaunay
//
//  Created by Sam Green on 4/14/14.
//  Copyright Sam Green. All rights reserved.
//

@import Foundation;

@protocol DelaunayCoordinate <NSObject>

@property (nonatomic) CGPoint coordinates;

- (BOOL) isReal;

@end
