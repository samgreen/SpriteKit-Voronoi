//
//  DelaunaySiteList.m
//  Delaunay
//
//  Created by Sam Green on 4/13/14.
//  Copyright Sam Green. All rights reserved.
//

#import "DelaunaySiteList.h"
#import "DelaunaySite.h"

@interface DelaunaySiteList ()

@property (nonatomic) NSMutableArray *sites;
@property (nonatomic) NSInteger currentIndex;

@end

@implementation DelaunaySiteList

+ (instancetype) list {
    DelaunaySiteList *siteList = [[DelaunaySiteList alloc] init];
    return siteList;
}

- (id) init {
    if ((self = [super init])) {
        _sites = [[NSMutableArray alloc] init];
        _currentIndex = 0;
    }
    return self;
}

- (NSString *) description {
    return [NSString stringWithFormat: @"SiteList (self.currentIndex: %ld sorted: %d self.sites: %@", (long)self.currentIndex, self.sorted, self.sites];
}

- (CGRect) bounds {
    if (!self.sorted) {
        // Set the self.sites' indexes first
        NSInteger newIndex = 0;
        for (DelaunaySite *site in self.sites) {
            site.index = newIndex;
            newIndex++;
        }
        [self.sites sortUsingSelector:@selector(compare:)];
        _sorted = YES;
    }
    CGFloat xmin, xmax, ymin, ymax;
    if ([self.sites count] == 0) {
        return CGRectZero;
    }
    xmin = CGFLOAT_MAX;
    xmax = CGFLOAT_MIN;
    for (DelaunaySite *site in self.sites) {
        if (site.x < xmin) {
            xmin = site.x;
        }
        if (site.x > xmax) {
            xmax = site.x;
        }
    }
    // we assume the self.sites have been sorted on y
    ymin = [(DelaunaySite *)[self.sites objectAtIndex: 0] y];
    ymax = [(DelaunaySite *)[self.sites objectAtIndex: [self.sites count] -1] y];
    return CGRectMake(xmin, ymin, xmax - xmin, ymax - ymin);
}

- (void) addSite:(DelaunaySite *) site {
    [self.sites addObject: site];
}

- (NSInteger) count {
    return [self.sites count];
}

- (DelaunaySite *) next {
    NSAssert(self.sorted, @"sites have not been sorted");
    if (self.currentIndex < [self.sites count]) {
        DelaunaySite *site = [self.sites objectAtIndex: self.currentIndex++];
        return site;
    }
    return nil;
}

- (NSArray *) regions:(CGRect) plotBounds {
    NSMutableArray *result = [NSMutableArray array];
    for (DelaunaySite *site in self.sites) {
        [result addObject: [site region]];
    }
    return result;
}




@end
