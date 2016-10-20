// The MIT License (MIT)
//
// Copyright (c) 2016 caoping <caoping.dev@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "CPCollectionViewSectionInfo.h"

@implementation CPCollectionViewSectionInfo

#pragma mark - Designated Initializer

- (instancetype)initWithCellInfos:(NSArray<CPCollectionViewCellInfo *> *)cellInfos {
    self = [super init];
    if (self) {
        NSParameterAssert(cellInfos);
        _cellInfos = [cellInfos copy];
    }
    
    return self;
}

- (instancetype)init {
    self = [self initWithCellInfos:@[]];
    
    return self;
}

#pragma mark - Convenience Initializers With Header

- (instancetype)initWithCellInfos:(NSArray<CPCollectionViewCellInfo *> *)cellInfos
                      headerClass:(Class)headerClass
           headerDidReuseCallback:(CPCollectionViewHeaderOrFooterBlock)headerDidReuseCallback
            sizeForHeaderCallback:(nullable CPCollectionViewSizeForHeaderOrFooterBlock)sizeForHeaderCallback {
    NSParameterAssert(headerClass);
    NSParameterAssert(headerDidReuseCallback);
    
    CPCollectionViewSectionInfo *sectionInfo = [self initWithCellInfos:cellInfos];
    sectionInfo.headerClass = headerClass;
    sectionInfo.headerReuseIdentifier = headerClass?[NSStringFromClass(headerClass) stringByAppendingString:@"_HeaderReuseIdentifier"]:nil;
    sectionInfo.headerDidReuseCallback = [headerDidReuseCallback copy];
    sectionInfo.sizeForHeaderCallback = [sizeForHeaderCallback copy];
    
    return sectionInfo;
}

- (instancetype)initWithCellInfos:(NSArray<CPCollectionViewCellInfo *> *)cellInfos
                     nibForHeader:(UINib *)nibForHeader
            headerReuseIdentifier:(NSString *)headerReuseIdentifier
           headerDidReuseCallback:(CPCollectionViewHeaderOrFooterBlock)headerDidReuseCallback
            sizeForHeaderCallback:(nullable CPCollectionViewSizeForHeaderOrFooterBlock)sizeForHeaderCallback {
    NSParameterAssert(nibForHeader);
    NSParameterAssert(headerReuseIdentifier);
    NSParameterAssert(headerDidReuseCallback);
    
    CPCollectionViewSectionInfo *sectionInfo = [self initWithCellInfos:cellInfos];
    sectionInfo.nibForHeader = nibForHeader;
    sectionInfo.headerReuseIdentifier = headerReuseIdentifier;
    sectionInfo.headerDidReuseCallback = [headerDidReuseCallback copy];
    sectionInfo.sizeForHeaderCallback = [sizeForHeaderCallback copy];
    
    return sectionInfo;
}

#pragma mark - Convenience Initializers With Footer

- (instancetype)initWithCellInfos:(NSArray<CPCollectionViewCellInfo *> *)cellInfos
                      footerClass:(Class)footerClass
           footerDidReuseCallback:(CPCollectionViewHeaderOrFooterBlock)footerDidReuseCallback
            sizeForFooterCallback:(nullable CPCollectionViewSizeForHeaderOrFooterBlock)sizeForFooterCallback {
    NSParameterAssert(footerClass);
    NSParameterAssert(footerDidReuseCallback);
    
    CPCollectionViewSectionInfo *sectionInfo = [self initWithCellInfos:cellInfos];
    sectionInfo.footerClass = footerClass;
    sectionInfo.footerReuseIdentifier = footerClass?[NSStringFromClass(footerClass) stringByAppendingString:@"_FooterReuseIdentifier"]:nil;
    sectionInfo.footerDidReuseCallback = [footerDidReuseCallback copy];
    sectionInfo.sizeForFooterCallback = [sizeForFooterCallback copy];
    
    return sectionInfo;
}

- (instancetype)initWithCellInfos:(NSArray<CPCollectionViewCellInfo *> *)cellInfos
                     nibForFooter:(UINib *)nibForFooter
            footerReuseIdentifier:(NSString *)footerReuseIdentifier
           footerDidReuseCallback:(CPCollectionViewHeaderOrFooterBlock)footerDidReuseCallback
            sizeForFooterCallback:(nullable CPCollectionViewSizeForHeaderOrFooterBlock)sizeForFooterCallback {
    NSParameterAssert(nibForFooter);
    NSParameterAssert(footerReuseIdentifier);
    NSParameterAssert(footerDidReuseCallback);
    
    CPCollectionViewSectionInfo *sectionInfo = [self initWithCellInfos:cellInfos];
    sectionInfo.nibForFooter = nibForFooter;
    sectionInfo.footerReuseIdentifier = footerReuseIdentifier;
    sectionInfo.footerDidReuseCallback = [footerDidReuseCallback copy];
    sectionInfo.sizeForFooterCallback = [sizeForFooterCallback copy];
    
    return sectionInfo;
}

#pragma mark - Getter

- (NSInteger)numberOfItems {
    if (self.cellInfos) {
        return self.cellInfos.count;
    }
    
    return 0;
}

#pragma mark - Appending And Inserting

- (void)cp_appendCellInfos:(NSArray<CPCollectionViewCellInfo *> *)cellInfos {
    NSMutableArray *infos = [_cellInfos mutableCopy];
    [infos addObjectsFromArray:cellInfos];
    _cellInfos = [infos copy];
}

- (void)cp_insertCellInfos:(NSArray<CPCollectionViewCellInfo *> *)cellInfos atIndexSet:(NSIndexSet *)indexSet {
    NSAssert(cellInfos.count==indexSet.count, @"cellInfos count must equals to indexSet count");
    
    NSMutableArray *infos = [_cellInfos mutableCopy];
    __block NSUInteger index = 0;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [infos insertObject:cellInfos[index] atIndex:idx];
        index++;
    }];
    
    _cellInfos = [infos copy];
}

#pragma mark - Update

- (BOOL)cp_updateCellInfo:(CPCollectionViewCellInfo *)cellInfo atIndex:(NSUInteger)index {
    NSAssert(index<[_cellInfos count], @"index out of cellInfos bounds");
    
    if (index < _cellInfos.count) {
        NSMutableArray *infos = [_cellInfos mutableCopy];
        infos[index] = cellInfo;
        _cellInfos = [infos copy];
        
        return YES;
    }
    
    return NO;
}

#pragma mark - Deleting

- (void)cp_deleteCellInfosAtIndexSet:(NSIndexSet *)indexSet {
    NSMutableArray *objectsForDelete = [NSMutableArray new];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [objectsForDelete addObject:[self.cellInfos objectAtIndex:idx]];
    }];
    
    NSMutableArray *cellInfos = [_cellInfos mutableCopy];
    [cellInfos removeObjectsInArray:objectsForDelete];
    _cellInfos = [cellInfos copy];
}

- (void)cp_deleteCellInfo:(CPCollectionViewCellInfo *)cellInfo {
    NSMutableArray *cellInfos = [_cellInfos mutableCopy];
    [cellInfos removeObject:cellInfo];
    _cellInfos = [cellInfos copy];
}

@end
