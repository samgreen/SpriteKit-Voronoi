//
//  DelaunaySiteList.h
//  Delaunay
//
//  Created by Sam Green on 4/13/14.
//  Copyright Sam Green. All rights reserved.
//

@import Foundation;

@class DelaunaySite;

@interface DelaunaySiteList : NSObject

@property (readonly) BOOL sorted;

+ (instancetype) list;

- (void) addSite:(DelaunaySite *) site;
- (NSInteger) count;
- (DelaunaySite *) next;

- (NSArray *) regions:(CGRect) plotBounds;
- (CGRect) bounds;

@end
