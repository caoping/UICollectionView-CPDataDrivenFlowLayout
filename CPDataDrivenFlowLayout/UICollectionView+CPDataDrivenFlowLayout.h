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
#import "CPCollectionViewDelegateFlowLayoutInterceptor.h"
#import "CPCollectionViewDataSourceInterceptor.h"

static NSString * _Nonnull _CPPlaceholderSupplementaryView = @"_CPPlaceholderSupplementaryView";

NS_ASSUME_NONNULL_BEGIN

@interface UICollectionView (CPDataDrivenFlowLayout)

/**
 所有sectionInfo数组
 */
@property (nonatomic, readonly) NSArray<CPCollectionViewSectionInfo *> *cp_sectionInfos;


#pragma mark - Enable DataDrivenFlowLayout


/**
 开启DataDrivenFlowLayout (调用此接口，或者手动设置cp_setDelegate/cp_setDataSource用于开启DataDrivenFlowLayout)
 */
- (void)cp_enableDataDrivenFlowLayout;

/**
 设置delegate与delegate拦截者

 @param delegate 代理
 @param interceptor 拦截者(只支持UICollectionViewDelegateFlowLayout协议)
 */
- (void)cp_setDelegate:(id<UICollectionViewDelegate>)delegate interceptor:(id<UICollectionViewDelegateFlowLayout>)interceptor;

/**
 设置dataSource与dataSource拦截者

 @param dataSource 数据源代理
 @param interceptor 拦截者
 */
- (void)cp_setDataSource:(id<UICollectionViewDataSource>)dataSource interceptor:(id<UICollectionViewDataSource>)interceptor;


#pragma mark - Reloading


/**
 根据sectionInfos刷新

 @param sectionInfos sectionInfo数组
 */
- (void)cp_reloadWithSectionInfos:(NSArray<CPCollectionViewSectionInfo *> *)sectionInfos;

/**
 根据某一个sectionInfo刷新对应的section

 @param sectionInfo sectionInfo对象
 @param inSection section索引
 */
- (void)cp_reloadWithSectionInfo:(CPCollectionViewSectionInfo *)sectionInfo inSection:(NSInteger)inSection;

/**
 根据某一个cellInfo刷新对应的cell

 @param cellInfo cellInfo对象
 @param indexPath cell索引
 */
- (void)cp_reloadItemWithCellInfo:(CPCollectionViewCellInfo *)cellInfo atIndexPath:(NSIndexPath *)indexPath;

/**
 根据某一个cell索引刷新对应的cell

 @param indexPath cell索引
 */
- (void)cp_reloadItemAtIndexPath:(NSIndexPath *)indexPath;


#pragma mark - Inserting


/**
 根据某一个sectionInfo插入至对应的section

 @param sectionInfo sectionInfo对象
 @param inSection section索引
 */
- (void)cp_insertSectionInfo:(CPCollectionViewSectionInfo *)sectionInfo inSection:(NSInteger)inSection;


/**
 根据一组cellInfo插入至对应的索引中

 @param cellInfos cellInfo数组
 @param indexPaths 索引数组
 */
- (void)cp_insertCellInfos:(NSArray<CPCollectionViewCellInfo *> *)cellInfos atIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;


#pragma mark - Appending


/**
 将sectionInfos数组追加至末尾

 @param sectionInfos sectionInfo数组
 */
- (void)cp_appendSectionInfos:(NSArray<CPCollectionViewSectionInfo *> *)sectionInfos;


/**
 将一组cellInfo追加至对应的section末尾

 @param cellInfos cellInfo数组
 @param inSection section索引
 */
- (void)cp_appendCellInfos:(NSArray<CPCollectionViewCellInfo *> *)cellInfos inSection:(NSInteger)inSection;


#pragma mark - Deleting


/**
 根据indexPath删除对应item

 @param indexPath 索引
 */
- (void)cp_deleteItemAtIndexPath:(NSIndexPath *)indexPath;


/**
 根据index集合删除对应section中的items

 @param section section索引
 @param indexSet 需要删除的index集合
 */
- (void)cp_deleteItemsInSection:(NSInteger)section atIndexSet:(NSIndexSet *)indexSet;


#pragma mark - Get Cell And Section Info


/**
 根据indexPath获取cellInfo对象

 @param indexPath 索引
 @return cellInfo对象
 */
- (nullable CPCollectionViewCellInfo *)cp_cellInfoForItemAtIndexPath:(NSIndexPath *)indexPath;


/**
 根据section获取sectionInfo

 @param section 索引
 @return sectionInfo对象
 */
- (nullable CPCollectionViewSectionInfo *)cp_sectionInfoForSection:(NSInteger)section;


#pragma mark - Get Index By Cell or Section Info


/**
 根据cellInfo对象返回对应的indexPath

 @param cellInfo cellInfo对象
 @return indexPath
 */
- (nullable NSIndexPath *)cp_indexPathForCellInfo:(CPCollectionViewCellInfo *)cellInfo;//return nil if not found


/**
 根据sectionInfo对象返回对应的section

 @param sectionInfo sectionInfo对象
 @return section
 */
- (NSInteger)cp_sectionForSectionInfo:(CPCollectionViewSectionInfo *)sectionInfo;//return -1 if not found

@end

NS_ASSUME_NONNULL_END
