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

#import <UIKit/UIKit.h>
#import "CPCollectionViewSectionInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface UICollectionView (CPDataDrivenFlowLayout) <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic) BOOL cp_dataDrivenFlowLayoutEnabled;
@property (nonatomic, readonly) NSArray<CPCollectionViewSectionInfo *> *cp_sectionInfos;

#pragma mark - Reloading

- (void)cp_reloadWithSectionInfos:(NSArray<CPCollectionViewSectionInfo *> *)sectionInfos;
- (void)cp_reloadWithSectionInfo:(CPCollectionViewSectionInfo *)sectionInfo inSection:(NSInteger)inSection;

- (void)cp_reloadItemWithCellInfo:(CPCollectionViewCellInfo *)cellInfo atIndexPath:(NSIndexPath *)indexPath;
- (void)cp_reloadItemAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Inserting

- (void)cp_insertSectionInfo:(CPCollectionViewSectionInfo *)sectionInfo inSection:(NSInteger)inSection;
- (void)cp_insertCellInfos:(NSArray<CPCollectionViewCellInfo *> *)cellInfos atIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

#pragma mark - Appending

- (void)cp_appendSectionInfos:(NSArray<CPCollectionViewSectionInfo *> *)sectionInfos;
- (void)cp_appendCellInfos:(NSArray<CPCollectionViewCellInfo *> *)cellInfos inSection:(NSInteger)inSection;

#pragma mark - Deleting

- (void)cp_deleteItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)cp_deleteItemsInSection:(NSInteger)section atIndexSet:(NSIndexSet *)indexSet;

#pragma mark - Get Cell And Section Info

- (nullable CPCollectionViewCellInfo *)cp_cellInfoForItemAtIndexPath:(NSIndexPath *)indexPath;
- (nullable CPCollectionViewSectionInfo *)cp_sectionInfoForSection:(NSInteger)section;

#pragma mark - Get Index By Cell or Section Info

- (nullable NSIndexPath *)cp_indexPathForCellInfo:(CPCollectionViewCellInfo *)cellInfo;//return nil if not found
- (NSInteger)cp_sectionForSectionInfo:(CPCollectionViewSectionInfo *)sectionInfo;//return -1 if not found

@end

NS_ASSUME_NONNULL_END
