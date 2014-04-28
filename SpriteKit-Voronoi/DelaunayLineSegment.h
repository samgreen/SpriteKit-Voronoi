//
//  DelaunayLineSegment.h
//  Delaunay
//
//  Created by Sam Green on 4/14/14.
//  Copyright Sam Green. All rights reserved.
//

@import Foundation;

@interface DelaunayLineSegment : NSObject

+ (instancetype)segmentWithStart:(CGPoint)left
                          andEnd:(CGPoint)right;

- (NSComparisonResult) compareLonger:(DelaunayLineSegment *) other;
- (NSComparisonResult) compareShorter:(DelaunayLineSegment *) other;
- (CGFloat) length;


@end
