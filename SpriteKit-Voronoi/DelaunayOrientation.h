//
//  DelaunayOrientation.h
//  Delaunay
//
//  Created by Sam Green on 4/13/14.
//  Copyright Sam Green. All rights reserved.
//

@import Foundation;

typedef NS_ENUM(NSUInteger, DelaunayOrientation) {
    DelaunayOrientationLeft,
    DelaunayOrientationRight,
    DelaunayOrientationUnknown
};

static inline BOOL OrientationIsLeft(DelaunayOrientation orientation) {
    return orientation == DelaunayOrientationLeft;
}

static inline BOOL OrientationIsRight(DelaunayOrientation orientation) {
    return orientation == DelaunayOrientationRight;
}

static inline DelaunayOrientation OppositeOrientation(DelaunayOrientation orientation) {
    if (OrientationIsLeft(orientation)) return DelaunayOrientationRight;
    return DelaunayOrientationLeft;
}

static inline NSString *OrientationDescription(DelaunayOrientation orientation) {
    if (OrientationIsLeft(orientation)) return @"Left";
    if (OrientationIsRight(orientation)) return @"Right";
    return @"Unknown";
}
