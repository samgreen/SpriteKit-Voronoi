//
//  Delaunay.h
//  Delaunay
//
//  Created by Christopher Garrett on 4/14/14.
//  Copyright Sam Green. All rights reserved.
//

#define DISTANCE(p1, p2) (sqrtf(powf(p1.x - p2.x, 2) + powf(p1.y - p2.y, 2)))

// (2**31)-1, see man random
#define RANDOM_MAX (2147483647)
