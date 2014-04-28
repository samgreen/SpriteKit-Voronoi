//
//  DelaunayEdge.m
//  Delaunay
//
//  Created by Sam Green on 4/13/14.
//  Copyright Sam Green. All rights reserved.
//

#import "DelaunayEdge.h"
#import "DelaunaySite.h"
#import "DelaunayLineSegment.h"
#import "DelaunayVertex.h"
#import "DelaunayOrientation.h"
#import "Delaunay.h"

DelaunayEdge *deletedEdge;

@implementation DelaunayEdge

+ (instancetype)deletedEdge {
    static DelaunayEdge *gDeletedEdge = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gDeletedEdge = [[DelaunayEdge alloc] init];
    });
    return gDeletedEdge;
}

+ (instancetype)edgeBisectingSite:(DelaunaySite *)site0 and:(DelaunaySite *)site1 {
    float x0, y0, x1, y1;
    
    x0 = site0.x, y0 = site0.y;
    x1 = site1.x, y1 = site1.y;
    
    float dx, dy, absdx, absdy;
    dx = x1 - x0;
    dy = y1 - y0;
    
    absdx = fabsf(dx);
    absdy = fabsf(dx);
    
    float a, b, c;
    c = x0 * dx + y0 * dy + (powf(dx, 2) + powf(dy, 2)) * 0.5;
    // Is the x or y edge longer?
    if (absdx > absdy) {
        a = 1.0; b = dy/dx; c /= dx;
    } else {
        b = 1.0; a = dx/dy; c /= dy;
    }
    
    return [[DelaunayEdge alloc] initWithSites:@[site0, site1] a:a b:b c:c];
}

- (instancetype)initWithSites:(NSArray *)sites a:(CGFloat)a b:(CGFloat)b c:(CGFloat)c {
    self = [super init];
    if (self) {
        _leftSite = [sites firstObject];
        _rightVertex = [sites lastObject];
        
        [_leftSite addEdge:self];
        [_rightSite addEdge:self];
        
        _a = a;
        _b = b;
        _c = c;
    }
    return self;
}

- (CGPoint)clippedPoint:(DelaunayOrientation)orientation {
    if (OrientationIsLeft(orientation)) return self.leftClippedPoint;
    return self.rightClippedPoint;
}

- (DelaunayVertex *)vertexWithOrientation:(DelaunayOrientation)orientation {
    if (OrientationIsLeft(orientation)) return self.leftVertex;
    return self.rightVertex;
}

- (void)setVertex:(DelaunayVertex *)vertex withOrientation:(DelaunayOrientation)orientation {
    if (OrientationIsLeft(orientation)) {
        self.leftVertex = vertex;
    } else {
        self.rightVertex = vertex;
    }
    
    if (self.leftVertex && self.rightVertex) {
        NSLog(@"%@", self);
    }
}

- (DelaunaySite *)siteWithOrientation:(DelaunayOrientation)orientation {
    if (OrientationIsLeft(orientation)) return self.leftSite;
    return self.rightSite;
}

- (void)setSite:(DelaunaySite *)site withOrientation:(DelaunayOrientation)orientation {
    if (OrientationIsLeft(orientation)) {
        self.leftSite = site;
    } else {
        self.rightSite = site;
    }
}

- (DelaunayLineSegment *)delaunayLine {
    return [DelaunayLineSegment segmentWithStart:self.leftSite.coordinates andEnd:self.rightSite.coordinates];
}

- (BOOL)isPartOfConvexHull {
    return (_leftVertex == nil || _rightVertex == nil);
}

- (CGFloat)sitesDistance {
    return DISTANCE(_leftSite.coordinates, _rightSite.coordinates);
}

- (NSComparisonResult)compareSitesLonger:(DelaunayEdge *)other {
    if ([self sitesDistance] < [other sitesDistance]) {
        return NSOrderedAscending;
    } else if ([self sitesDistance] > [other sitesDistance]) {
        return NSOrderedDescending;
    }
    return NSOrderedSame;
}

- (NSComparisonResult) compareSitesShorter:(DelaunayEdge *) other {
    return [self compareSitesLonger: other];
}

// Set _clippedVertices to contain the two ends of the portion of the Voronoi edge that is visible
// within the bounds.  If no part of the Edge falls within the bounds, leave clippedVertices null.

- (void)clipToBounds:(CGRect)bounds {
    CGFloat xmin = bounds.origin.x;
    CGFloat ymin = bounds.origin.y;
    CGFloat xmax = bounds.origin.x + bounds.size.width;
    CGFloat ymax = bounds.origin.y + bounds.size.height;
    
    DelaunayVertex *vertex0;
    DelaunayVertex *vertex1;
    
    CGFloat x0, x1, y0, y1;
    
    
    if (_a == 1.0 && _b >= 0.0)
    {
        vertex0 = _rightVertex;
        vertex1 = _leftVertex;
    }
    else
    {
        vertex0 = _leftVertex;
        vertex1 = _rightVertex;
    }
    
    if (_a == 1.0)
    {
        y0 = ymin;
        if (vertex0 != nil && vertex0.y > ymin)
        {
            y0 = vertex0.y;
        }
        if (y0 > ymax)
        {
            return;
        }
        x0 = _c - _b * y0;
        
        y1 = ymax;
        if (vertex1 != nil && vertex1.y < ymax)
        {
            y1 = vertex1.y;
        }
        if (y1 < ymin)
        {
            return;
        }
        x1 = _c - _b * y1;
        
        if ((x0 > xmax && x1 > xmax) || (x0 < xmin && x1 < xmin))
        {
            return;
        }
        
        if (x0 > xmax)
        {
            x0 = xmax; y0 = (_c - x0)/_b;
        }
        else if (x0 < xmin)
        {
            x0 = xmin; y0 = (_c - x0)/_b;
        }
        
        if (x1 > xmax)
        {
            x1 = xmax; y1 = (_c - x1)/_b;
        }
        else if (x1 < xmin)
        {
            x1 = xmin; y1 = (_c - x1)/_b;
        }
    }
    else
    {
        x0 = xmin;
        if (vertex0 != nil && vertex0.x > xmin)
        {
            x0 = vertex0.x;
        }
        if (x0 > xmax)
        {
            return;
        }
        y0 = _c - _a * x0;
        
        x1 = xmax;
        if (vertex1 != nil && vertex1.x < xmax)
        {
            x1 = vertex1.x;
        }
        if (x1 < xmin)
        {
            return;
        }
        y1 = _c - _a * x1;
        
        if ((y0 > ymax && y1 > ymax) || (y0 < ymin && y1 < ymin))
        {
            return;
        }
        
        if (y0 > ymax)
        {
            y0 = ymax; x0 = (_c - y0)/_a;
        }
        else if (y0 < ymin)
        {
            y0 = ymin; x0 = (_c - y0)/_a;
        }
        
        if (y1 > ymax)
        {
            y1 = ymax; x1 = (_c - y1)/_a;
        }
        else if (y1 < ymin)
        {
            y1 = ymin; x1 = (_c - y1)/_a;
        }
    }
    
    if (vertex0 == _leftVertex)
    {
        _leftClippedPoint = CGPointMake(x0, y0);
        _rightClippedPoint = CGPointMake(x1, y1);
    }
    else
    {
        _rightClippedPoint = CGPointMake(x0, y0);
        _leftClippedPoint = CGPointMake(x1, y1);
        
    }
    _visible = YES;
}

- (NSString *) description {
    NSString *siteDesc = @"";
    NSString *vertexDesc = @"";
    siteDesc =   [NSString stringWithFormat: @"S: %d-%d", _leftSite == nil ? -1 : _leftSite.index, _rightSite == nil ? -1 : _rightSite.index];
    vertexDesc = [NSString stringWithFormat: @"V: %d-%d", _leftVertex == nil ? -1 : _leftVertex.index, _rightVertex == nil ? -1 : _rightVertex.index];
    return [NSString stringWithFormat: @"E (%@ %@ a,b,c: %f,%f,%f)", siteDesc, vertexDesc, _a, _b, _c];
}

@end

