//
//  DelaunayPolygon.h
//  Delaunay
//
//  Created by Sam Green on 4/13/14.
//  Copyright Sam Green. All rights reserved.
//

@import Foundation;

typedef NS_ENUM(NSUInteger, DelaunayWinding) {
    DelaunayWindingNone = 0,
    DelaunayWindingClockwise = 1,
    DelaunayWindingCounterClockwise = 2,
};

@interface DelaunayPolygon : NSObject

@property (nonatomic, readonly) DelaunayWinding winding;

@property (nonatomic, readonly) CGFloat area;
@property (nonatomic, readonly) CGFloat signedDoubleArea;

+ (instancetype)polygonWithVertices:(NSMutableArray *)vertices;

@end
