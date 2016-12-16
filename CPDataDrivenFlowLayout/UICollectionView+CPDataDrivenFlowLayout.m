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

#import "UICollectionView+CPDataDrivenFlowLayout.h"
#import <objc/runtime.h>
#import "UICollectionView+CPTemplateLayoutCell.h"

@interface _CPCollectionViewFlowLayoutProxy : NSProxy

@property (nonatomic, weak) id target;
@property (nonatomic, weak) id interceptor;

- (instancetype)initWithTarget:(id)target interceptor:(id)interceptor;

@end

@implementation _CPCollectionViewFlowLayoutProxy

- (instancetype)initWithTarget:(id)target interceptor:(id)interceptor
{
    if (!self) {
        return nil;
    }
    _target = target;
    _interceptor = interceptor;
    
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [_interceptor respondsToSelector:aSelector] || [_target respondsToSelector:aSelector];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [_interceptor conformsToProtocol:aProtocol] || [_target conformsToProtocol:aProtocol];
}

#pragma mark - Forward

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    NSMethodSignature *signature = [(id)_interceptor methodSignatureForSelector:sel];
    if (signature) {
        return signature;
    }
    
    signature = [(id)_target methodSignatureForSelector:sel];
    if (signature) {
        return signature;
    }
    
    signature = [super methodSignatureForSelector:sel];
    if (signature) {
        return signature;
    }
    
    return [[self class] voidSignature];//prevent crash when signature is nil
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    id target;
    if ([_interceptor respondsToSelector:invocation.selector]) {
        target = _interceptor;
    } else if ([_target respondsToSelector:invocation.selector]) {
        target = _target;
    }
    
    if (target) {
        [invocation invokeWithTarget:target];
    } else {
        NSMethodSignature *signature = [invocation methodSignature];
        if (signature != [[self class] voidSignature]) {
            [super forwardInvocation:invocation];//forward when signature is not voidSignature
        }
    }
}

+ (NSMethodSignature *)voidSignature {
    static NSMethodSignature *signature = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        signature = [NSMethodSignature signatureWithObjCTypes:@encode(void)];
    });
    return signature;
}

@end

static NSString *_CPPlaceholderSupplementaryView = @"_CPPlaceholderSupplementaryView";

@implementation UICollectionView (CPDataDrivenFlowLayout)

#define __DescriptionForAssert [NSString stringWithFormat:@"invoke %@ before must be set cp_dataDrivenFlowLayoutEnabled value to YES",NSStringFromSelector(_cmd)]
#define CPDataDrivenFlowLayoutEnabledAssert() NSAssert(self.cp_dataDrivenFlowLayoutEnabled, __DescriptionForAssert)

#pragma mark - Method Exchange

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        Method originalDelegateSetter = class_getInstanceMethod(class, @selector(setDelegate:));
        Method myDelegateSetter = class_getInstanceMethod(class, @selector(cp_setDelegate:));
        if (originalDelegateSetter && myDelegateSetter) {
            method_exchangeImplementations(originalDelegateSetter, myDelegateSetter);
        }
        
        Method originalDataSourceSetter = class_getInstanceMethod(class, @selector(setDataSource:));
        Method myDataSourceSetter = class_getInstanceMethod(class, @selector(cp_setDataSource:));
        if (originalDataSourceSetter && myDataSourceSetter) {
            method_exchangeImplementations(originalDataSourceSetter, myDataSourceSetter);
        }
        
        Method originalDealloc = class_getInstanceMethod(class, NSSelectorFromString(@"dealloc"));
        Method myDealloc = class_getInstanceMethod(class, @selector(cp_dealloc));
        if (originalDealloc && myDealloc) {
            method_exchangeImplementations(originalDealloc, myDealloc);
        }
    });
}

#pragma mark - Associated Object

- (BOOL)cp_dataDrivenFlowLayoutEnabled {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setCp_dataDrivenFlowLayoutEnabled:(BOOL)cp_dataDrivenFlowLayoutEnabled {
    objc_setAssociatedObject(self, @selector(cp_dataDrivenFlowLayoutEnabled), @(cp_dataDrivenFlowLayoutEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    //更新delegate
    id originalDelegate = self.delegate;
    if ([originalDelegate class] == [_CPCollectionViewFlowLayoutProxy class]) {
        originalDelegate = [self cp_originalDelegate];//当前delegate为proxy时，使用原始delegate
    }
    [self setDelegate:originalDelegate];//此处函数调用会跳转至cp_setDelegate, 因为setDelegate被交换
    
    //更新dataSource
    id originalDataSource = self.dataSource;
    if ([originalDataSource class] == [_CPCollectionViewFlowLayoutProxy class]) {
        originalDataSource = [self cp_originalDataSource];//当前dataSource为proxy时，使用原始dataSource
    }
    [self setDataSource:originalDataSource];//此处函数调用会跳转至cp_setDataSource, 因为setDataSource被交换
}

- (NSArray<CPCollectionViewSectionInfo *> *)cp_sectionInfos {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCp_sectionInfos:(NSArray<CPCollectionViewSectionInfo *> * _Nonnull)cp_sectionInfos {
    objc_setAssociatedObject(self, @selector(cp_sectionInfos), cp_sectionInfos, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Delegate and DataSource Proxy

- (_CPCollectionViewFlowLayoutProxy *)cp_delegateProxy {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCp_delegateProxy:(_CPCollectionViewFlowLayoutProxy *)cp_delegateProxy {
    objc_setAssociatedObject(self, @selector(cp_delegateProxy), cp_delegateProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (_CPCollectionViewFlowLayoutProxy *)cp_dataSourceProxy {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCp_dataSourceProxy:(_CPCollectionViewFlowLayoutProxy *)cp_dataSourceProxy {
    objc_setAssociatedObject(self, @selector(cp_dataSourceProxy), cp_dataSourceProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Original Delegate and DataSource

- (id)cp_originalDelegate {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCp_originalDelegate:(id)cp_originalDelegate {
    objc_setAssociatedObject(self, @selector(cp_originalDelegate), cp_originalDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id)cp_originalDataSource {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCp_originalDataSource:(id)cp_originalDataSource {
    objc_setAssociatedObject(self, @selector(cp_originalDataSource), cp_originalDataSource, OBJC_ASSOCIATION_ASSIGN);
}

#pragma mark - Method Exchange Implementations

- (void)cp_dealloc {
    [self setCp_delegateProxy:nil];
    [self setCp_dataSourceProxy:nil];
    objc_setAssociatedObject(self, @selector(cp_dataDrivenFlowLayoutEnabled), @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self cp_dealloc];
}

- (void)cp_setDelegate:(id<UICollectionViewDelegate>)delegate {
    [self setCp_originalDelegate:delegate];//为关闭dataDrivenFlowLayout时还原代理，在此处存储原始delegate的弱引用
    
    if (self.cp_dataDrivenFlowLayoutEnabled) {
        id delegateProxy = [self createDelegateProxyWithOriginalDelegate:delegate];
        [self cp_setDelegate:delegateProxy];
    } else {
        [self cp_setDelegate:delegate];
    }
}

- (void)cp_setDataSource:(id<UICollectionViewDataSource>)dataSource {
    [self setCp_originalDataSource:dataSource];//为关闭dataDrivenFlowLayout时还原代理，在此处存储原始dataSource的弱引用
    
    if (self.cp_dataDrivenFlowLayoutEnabled) {
        id dataSourceProxy = [self createDataSourceProxyWithOriginalDataSource:dataSource];
        [self cp_setDataSource:dataSourceProxy];
    } else {
        [self cp_setDataSource:dataSource];
    }
}

#pragma mark - Create Proxy

- (id)createDelegateProxyWithOriginalDelegate:(id)originalDelegate {
    id delegateProxy = [[_CPCollectionViewFlowLayoutProxy alloc] initWithTarget:originalDelegate interceptor:self];
    [self setCp_delegateProxy:delegateProxy];
    return delegateProxy;
}

- (id)createDataSourceProxyWithOriginalDataSource:(id)originalDataSource {
    id dataSourceProxy = [[_CPCollectionViewFlowLayoutProxy alloc] initWithTarget:originalDataSource interceptor:self];
    [self setCp_dataSourceProxy:dataSourceProxy];
    return dataSourceProxy;
}

#pragma mark - Reloading

- (void)cp_reloadWithSectionInfos:(NSArray<CPCollectionViewSectionInfo *> *)sectionInfos {
    CPDataDrivenFlowLayoutEnabledAssert();
    
    [self cp_sectionInfosReload:sectionInfos];
    [self reloadData];
}

- (void)cp_reloadWithSectionInfo:(CPCollectionViewSectionInfo *)sectionInfo inSection:(NSInteger)inSection {
    CPDataDrivenFlowLayoutEnabledAssert();
    
    BOOL success = [self cp_sectionInfosUpdate:sectionInfo inSection:inSection];
    if (success) {
        [self reloadSections:[NSIndexSet indexSetWithIndex:inSection]];
    }
}

- (void)cp_reloadItemWithCellInfo:(CPCollectionViewCellInfo *)cellInfo atIndexPath:(NSIndexPath *)indexPath {
    CPDataDrivenFlowLayoutEnabledAssert();
    
    if (!indexPath || !cellInfo) {
        return;
    }
    
    CPCollectionViewSectionInfo *sectionInfo = [self cp_sectionInfoForSection:indexPath.section];
    if (sectionInfo) {
        [sectionInfo cp_updateCellInfo:cellInfo atIndex:indexPath.item];
        
        //if cell is visible, reload immediately
        NSArray *visibleIndexPaths = [self indexPathsForVisibleItems];
        [visibleIndexPaths enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj compare:indexPath] == NSOrderedSame) {
                *stop = YES;
                [self reloadItemsAtIndexPaths:@[indexPath]];
            }
        }];
    }
}

- (void)cp_reloadItemAtIndexPath:(NSIndexPath *)indexPath {
    CPDataDrivenFlowLayoutEnabledAssert();
    
    CPCollectionViewCellInfo *cellInfo = [self cp_cellInfoForItemAtIndexPath:indexPath];
    if (cellInfo) {
        [self cp_reloadItemWithCellInfo:cellInfo atIndexPath:indexPath];
    }
}

#pragma mark - Inserting

- (void)cp_insertSectionInfo:(CPCollectionViewSectionInfo *)sectionInfo inSection:(NSInteger)inSection {
    CPDataDrivenFlowLayoutEnabledAssert();
    
    BOOL success = [self cp_sectionInfoInsert:sectionInfo inSection:inSection];
    if (success) {
        [self insertSections:[NSIndexSet indexSetWithIndex:inSection]];
    }
}

- (void)cp_insertCellInfos:(NSArray<CPCollectionViewCellInfo *> *)cellInfos atIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    CPDataDrivenFlowLayoutEnabledAssert();
    
    NSAssert(cellInfos, @"cellInfos must not be nil");
    NSAssert(indexPaths, @"indexPaths must not be nil");
    NSAssert(cellInfos.count == indexPaths.count, @"cellInfos count must equals to indexPaths count");
    
    __weak typeof(self) weakSelf = self;
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        CPCollectionViewCellInfo *cellInfo = [cellInfos objectAtIndex:idx];
        CPCollectionViewSectionInfo *sectionInfo = [weakSelf cp_sectionInfoForSection:indexPath.section];
        if (cellInfo && sectionInfo) {
            [sectionInfo cp_insertCellInfos:@[cellInfo] atIndexSet:[NSIndexSet indexSetWithIndex:indexPath.item]];
        }
    }];
    
    [self cp_registerCellWithCellInfos:cellInfos];
    [self insertItemsAtIndexPaths:indexPaths];
}

#pragma mark - Appending

- (void)cp_appendSectionInfos:(NSArray<CPCollectionViewSectionInfo *> *)sectionInfos {
    CPDataDrivenFlowLayoutEnabledAssert();
    
    NSInteger start = [self cp_sectionInfos].count;
    NSInteger count = sectionInfos.count;
    BOOL success = [self cp_sectionInfosAppend:sectionInfos];
    if (success) {
        [self insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(start, count)]];
    }
}

- (void)cp_appendCellInfos:(NSArray<CPCollectionViewCellInfo *> *)cellInfos inSection:(NSInteger)inSection {
    CPDataDrivenFlowLayoutEnabledAssert();
    NSAssert(cellInfos, @"cellInfos must not be nil");
    
    CPCollectionViewSectionInfo *sectionInfo = [self cp_sectionInfoForSection:inSection];
    if (sectionInfo && cellInfos && cellInfos.count > 0) {
        NSInteger start = sectionInfo.numberOfItems;
        NSInteger count = cellInfos.count;
        [sectionInfo cp_appendCellInfos:cellInfos];
        [self cp_registerCellWithCellInfos:cellInfos];
        
        NSMutableArray *indexPaths = [NSMutableArray new];
        for (NSInteger i = start; i < start+count; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:inSection]];
        }
        [self insertItemsAtIndexPaths:[indexPaths copy]];
    }
}

#pragma mark - Deleting

- (void)cp_deleteItemAtIndexPath:(NSIndexPath *)indexPath {
    CPDataDrivenFlowLayoutEnabledAssert();
    
    CPCollectionViewSectionInfo *sectionInfo = [self cp_sectionInfoForSection:indexPath.section];
    if (sectionInfo) {
        [sectionInfo cp_deleteCellInfosAtIndexSet:[NSIndexSet indexSetWithIndex:indexPath.item]];
        if (sectionInfo.numberOfItems == 0) {
            NSMutableArray *mSectionInfos = [[self cp_sectionInfos] mutableCopy];
            [mSectionInfos removeObject:sectionInfo];
            [self setCp_sectionInfos:[mSectionInfos copy]];
            [self deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
        } else {
            [self deleteItemsAtIndexPaths:@[indexPath]];
        }
    }
}

- (void)cp_deleteItemsInSection:(NSInteger)section atIndexSet:(NSIndexSet *)indexSet {
    CPDataDrivenFlowLayoutEnabledAssert();
}

#pragma mark - Reload / Insert / Update / Append / Delete Data

- (BOOL)cp_sectionInfosReload:(NSArray<CPCollectionViewSectionInfo *> *)sectionInfos {
    if (sectionInfos) {
        [self setCp_sectionInfos:[sectionInfos copy]];
        [self cp_registerCellWithSectionInfos:sectionInfos];
        [self cp_registerHeaderAndFooterWithSectionInfos:sectionInfos];
        
        return YES;
    }
    
    return NO;
}

- (BOOL)cp_sectionInfoInsert:(CPCollectionViewSectionInfo *)sectionInfo inSection:(NSInteger)inSection {
    if (sectionInfo) {
        NSMutableArray *mSectionInfos = [[self cp_sectionInfos] mutableCopy];
        if (inSection < mSectionInfos.count) {
            mSectionInfos[inSection] = sectionInfo;
        } else {
            [mSectionInfos addObject:sectionInfo];
        }
        [self setCp_sectionInfos:[mSectionInfos copy]];
        [self cp_registerCellWithSectionInfos:@[sectionInfo]];
        [self cp_registerHeaderAndFooterWithSectionInfos:@[sectionInfo]];
        
        return YES;
    }
    
    return NO;
}

- (BOOL)cp_sectionInfosUpdate:(CPCollectionViewSectionInfo *)sectionInfo inSection:(NSInteger)inSection {
    if (sectionInfo && inSection < [self cp_sectionInfos].count) {
        NSMutableArray *mSectionInfos = [[self cp_sectionInfos] mutableCopy];
        mSectionInfos[inSection] = sectionInfo;
        [self setCp_sectionInfos:[mSectionInfos copy]];
        [self cp_registerCellWithSectionInfos:@[sectionInfo]];
        [self cp_registerHeaderAndFooterWithSectionInfos:@[sectionInfo]];
        
        return YES;
    }
    
    return NO;
}

- (BOOL)cp_sectionInfosAppend:(NSArray<CPCollectionViewSectionInfo *> *)sectionInfos {
    if (sectionInfos) {
        NSMutableArray *mSectionInfos = [[self cp_sectionInfos] mutableCopy];
        [mSectionInfos addObjectsFromArray:sectionInfos];
        [self setCp_sectionInfos:[mSectionInfos copy]];
        [self cp_registerCellWithSectionInfos:sectionInfos];
        [self cp_registerHeaderAndFooterWithSectionInfos:sectionInfos];
        
        return YES;
    }
    
    return NO;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CPCollectionViewSectionInfo *sectionInfo = [self cp_sectionInfoForSection:section];
    if (sectionInfo) {
        return sectionInfo.sectionInset;
    } else if ([collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
        return [(UICollectionViewFlowLayout *)collectionViewLayout sectionInset];
    }
    
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    CPCollectionViewSectionInfo *sectionInfo = [self cp_sectionInfoForSection:section];
    if (sectionInfo) {
        return sectionInfo.minimumLineSpacing;
    } else if ([collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
        return [(UICollectionViewFlowLayout *)collectionViewLayout minimumLineSpacing];
    }
    
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    CPCollectionViewSectionInfo *sectionInfo = [self cp_sectionInfoForSection:section];
    if (sectionInfo) {
        return sectionInfo.minimumInteritemSpacing;
    } else if ([collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
        return [(UICollectionViewFlowLayout *)collectionViewLayout minimumInteritemSpacing];
    }
    
    return 0;
}

//size for cell
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPCollectionViewCellInfo *cellInfo = [self cp_cellInfoForItemAtIndexPath:indexPath];
    if (cellInfo.sizeForCellCallback) {
        //根据preferredLayout计算cell size的计算器
        CPCollectionViewPreferredLayoutBlock sizeByPreferredLayoutCalculator = ^(CPPreferredLayoutDimension dimension, CGFloat preferredLayoutValue) {
            CGSize size = CGSizeZero;
            
            if (cellInfo.cellReuseIdentifier) {
                size = [collectionView cp_sizeForCellWithIdentifier:cellInfo.cellReuseIdentifier preferredLayoutDimension:dimension preferredLayoutValue:preferredLayoutValue configuration:^(__kindof UICollectionViewCell * _Nonnull cell) {
                    if (cellInfo.cellDidReuseCallback) {
                        cellInfo.cellDidReuseCallback(collectionView, cell, indexPath, cellInfo.data);
                    }
                }];
            }
            
            return size;
        };
        
        return cellInfo.sizeForCellCallback(collectionView, collectionViewLayout, sizeByPreferredLayoutCalculator);
    }
    
    return CGSizeZero;
}

//size for header
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CPCollectionViewSectionInfo *sectionInfo = [self cp_sectionInfoForSection:section];
    if (sectionInfo.sizeForHeaderCallback) {
        //根据preferredLayout计算cell size的计算器
        CPCollectionViewPreferredLayoutBlock sizeByPreferredLayoutCalculator = ^(CPPreferredLayoutDimension dimension, CGFloat preferredLayoutValue) {
            CGSize size = CGSizeZero;
            
            if (sectionInfo.headerReuseIdentifier) {
                size = [collectionView cp_sizeForSupplementaryViewOfKind:UICollectionElementKindSectionHeader identifier:sectionInfo.headerReuseIdentifier preferredLayoutDimension:dimension preferredLayoutValue:preferredLayoutValue configuration:^(__kindof UICollectionReusableView * _Nonnull supplementaryView) {
                    if (sectionInfo.headerDidReuseCallback) {
                        sectionInfo.headerDidReuseCallback(collectionView, supplementaryView, section);
                    }
                }];
            }
            
            return size;
        };
        
        return sectionInfo.sizeForHeaderCallback(collectionView, collectionViewLayout, sizeByPreferredLayoutCalculator);
    }
    
    return CGSizeZero;
}

//size for footer
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    CPCollectionViewSectionInfo *sectionInfo = [self cp_sectionInfoForSection:section];
    if (sectionInfo.sizeForFooterCallback) {
        //根据preferredLayout计算cell size的计算器
        CPCollectionViewPreferredLayoutBlock sizeByPreferredLayoutCalculator = ^(CPPreferredLayoutDimension dimension, CGFloat preferredLayoutValue) {
            CGSize size = CGSizeZero;
            
            if (sectionInfo.footerReuseIdentifier) {
                size = [collectionView cp_sizeForSupplementaryViewOfKind:UICollectionElementKindSectionFooter identifier:sectionInfo.footerReuseIdentifier preferredLayoutDimension:dimension preferredLayoutValue:preferredLayoutValue configuration:^(__kindof UICollectionReusableView * _Nonnull supplementaryView) {
                    if (sectionInfo.footerDidReuseCallback) {
                        sectionInfo.footerDidReuseCallback(collectionView, supplementaryView, section);
                    }
                }];
            }
            
            return size;
        };
        
        return sectionInfo.sizeForFooterCallback(collectionView, collectionViewLayout, sizeByPreferredLayoutCalculator);
    }
    
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CPCollectionViewCellInfo *cellInfo = [self cp_cellInfoForItemAtIndexPath:indexPath];
    if (cellInfo && cellInfo.cellDidSelectCallback) {
        cellInfo.cellDidSelectCallback(collectionView, [collectionView cellForItemAtIndexPath:indexPath], indexPath, cellInfo.data);
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if ([self cp_sectionInfos].count > 0) {
        return [self cp_sectionInfos].count;
    }
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    CPCollectionViewSectionInfo *sectionInfo = [self cp_sectionInfoForSection:section];
    if (sectionInfo) {
        return sectionInfo.numberOfItems;
    }
    
    return 0;
}

//cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPCollectionViewCellInfo *cellInfo = [self cp_cellInfoForItemAtIndexPath:indexPath];
    if (cellInfo) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellInfo.cellReuseIdentifier forIndexPath:indexPath];
        if (cellInfo.cellDidReuseCallback) {
            cellInfo.cellDidReuseCallback(collectionView, cell, indexPath, cellInfo.data);
        }
        
        return cell;
    }
    
    return nil;
}

//header or footer
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    CPCollectionViewSectionInfo *sectionInfo = [self cp_sectionInfoForSection:indexPath.section];
    if (sectionInfo) {
        if (sectionInfo.headerReuseIdentifier && [kind isEqualToString:UICollectionElementKindSectionHeader]) {
            //header
            UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                  withReuseIdentifier:sectionInfo.headerReuseIdentifier
                                                                                         forIndexPath:indexPath];
            if (sectionInfo.headerDidReuseCallback) {
                sectionInfo.headerDidReuseCallback(collectionView, header, indexPath.section);
            }
            return header;
            
        } else if (sectionInfo.footerReuseIdentifier && [kind isEqualToString:UICollectionElementKindSectionFooter]) {
            //header
            UICollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                  withReuseIdentifier:sectionInfo.footerReuseIdentifier
                                                                                         forIndexPath:indexPath];
            if (sectionInfo.footerDidReuseCallback) {
                sectionInfo.footerDidReuseCallback(collectionView, footer, indexPath.section);
            }
            return footer;
        }
    }
    
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:_CPPlaceholderSupplementaryView forIndexPath:indexPath];
}

#pragma mark - Getter

- (nullable CPCollectionViewCellInfo *)cp_cellInfoForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPDataDrivenFlowLayoutEnabledAssert();
    
    CPCollectionViewSectionInfo *sectionInfo = [self cp_sectionInfoForSection:indexPath.section];
    if (sectionInfo && indexPath.item < sectionInfo.numberOfItems) {
        return [sectionInfo.cellInfos objectAtIndex:indexPath.item];
    }
    
    return nil;
}

- (nullable CPCollectionViewSectionInfo *)cp_sectionInfoForSection:(NSInteger)section {
    CPDataDrivenFlowLayoutEnabledAssert();
    
    if (section < [self cp_sectionInfos].count) {
        return [[self cp_sectionInfos] objectAtIndex:section];
    }
    
    return nil;
}

- (nullable NSIndexPath *)cp_indexPathForCellInfo:(CPCollectionViewCellInfo *)cellInfo {
    __block NSIndexPath *indexPath;
    [[self cp_sectionInfos] enumerateObjectsUsingBlock:^(CPCollectionViewSectionInfo * _Nonnull section, NSUInteger sectionIndex, BOOL * _Nonnull stop1) {
       [section.cellInfos enumerateObjectsUsingBlock:^(CPCollectionViewCellInfo * _Nonnull cell, NSUInteger itemIndex, BOOL * _Nonnull stop2) {
           if (cell == cellInfo) {
               indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
               *stop1 = YES;
               *stop2 = YES;
           }
       }];
    }];
    
    return indexPath;
}

- (NSInteger)cp_sectionForSectionInfo:(CPCollectionViewSectionInfo *)sectionInfo {
    __block NSInteger section = -1;
    [[self cp_sectionInfos] enumerateObjectsUsingBlock:^(CPCollectionViewSectionInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj == sectionInfo) {
            section = idx;
            *stop = YES;
        }
    }];
    
    return section;
}

#pragma mark - Register Header and Footer

- (void)cp_registerHeaderAndFooterWithSectionInfos:(NSArray<CPCollectionViewSectionInfo *> *)sectionInfos {
    __weak typeof(self) weakSelf = self;
    [sectionInfos enumerateObjectsUsingBlock:^(CPCollectionViewSectionInfo * _Nonnull sectionInfo, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf cp_registerHeaderAndFooterWithSectionInfo:sectionInfo];
    }];
    [self cp_registerPlaceholderSupplementaryView];
}

- (void)cp_registerHeaderAndFooterWithSectionInfo:(CPCollectionViewSectionInfo *)sectionInfo {
    if (sectionInfo.headerReuseIdentifier) {
        if (sectionInfo.nibForHeader) {
            [self cp_registerSupplementaryViewWithNib:sectionInfo.nibForHeader kind:UICollectionElementKindSectionHeader reuseIdentifier:sectionInfo.headerReuseIdentifier];
        } else if (sectionInfo.headerClass) {
            [self cp_registerSupplementaryViewWithClass:sectionInfo.headerClass kind:UICollectionElementKindSectionHeader reuseIdentifier:sectionInfo.headerReuseIdentifier];
        }
    }
    
    if (sectionInfo.footerReuseIdentifier) {
        if (sectionInfo.nibForFooter) {
            [self cp_registerSupplementaryViewWithNib:sectionInfo.nibForFooter kind:UICollectionElementKindSectionFooter reuseIdentifier:sectionInfo.footerReuseIdentifier];
        } else if (sectionInfo.footerClass) {
            [self cp_registerSupplementaryViewWithClass:sectionInfo.footerClass kind:UICollectionElementKindSectionFooter reuseIdentifier:sectionInfo.footerReuseIdentifier];
        }
    }
}

- (void)cp_registerSupplementaryViewWithNib:(UINib *)nib kind:(NSString *)kind reuseIdentifier:(NSString *)reuseIdentifier {
    NSDictionary *supplementaryViewNibDict = [self valueForKey:@"_supplementaryViewNibDict"];
    if ([supplementaryViewNibDict valueForKey:reuseIdentifier]) {
        //prevent repeat register cell
        return;
    }
    [self registerNib:nib forSupplementaryViewOfKind:kind withReuseIdentifier:reuseIdentifier];
}

- (void)cp_registerSupplementaryViewWithClass:(Class)viewClass kind:(NSString *)kind reuseIdentifier:(NSString *)reuseIdentifier {
    NSDictionary *supplementaryViewClassDict = [self valueForKey:@"_supplementaryViewClassDict"];
    if ([supplementaryViewClassDict valueForKey:reuseIdentifier]) {
        //prevent repeat register cell
        return;
    }
    [self registerClass:viewClass forSupplementaryViewOfKind:kind withReuseIdentifier:reuseIdentifier];
}

- (void)cp_registerPlaceholderSupplementaryView {
    NSDictionary *supplementaryViewClassDict = [self valueForKey:@"_supplementaryViewClassDict"];
    if ([supplementaryViewClassDict valueForKey:_CPPlaceholderSupplementaryView]) {
        //prevent repeat register cell
        return;
    }
    [self registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:_CPPlaceholderSupplementaryView];
    [self registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:_CPPlaceholderSupplementaryView];
}

#pragma mark - Register Cell

- (void)cp_registerCellWithSectionInfos:(NSArray<CPCollectionViewSectionInfo *> *)sectionInfos {
    __weak typeof(self) weakSelf = self;
    [sectionInfos enumerateObjectsUsingBlock:^(CPCollectionViewSectionInfo * _Nonnull sectionInfo, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf cp_registerCellWithCellInfos:sectionInfo.cellInfos];
    }];
}

- (void)cp_registerCellWithCellInfos:(NSArray<CPCollectionViewCellInfo *> *)cellInfos {
    __weak typeof(self) weakSelf = self;
    [cellInfos enumerateObjectsUsingBlock:^(CPCollectionViewCellInfo * _Nonnull cellInfo, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf cp_registerCellWithCellInfo:cellInfo];
    }];
}

- (void)cp_registerCellWithCellInfo:(CPCollectionViewCellInfo * _Nonnull)cellInfo {
    NSDictionary *cellNibDict = [self valueForKey:@"_cellNibDict"];
    NSDictionary *cellClassDict = [self valueForKey:@"_cellClassDict"];
    if ([cellNibDict objectForKey:cellInfo.cellReuseIdentifier] ||
        [cellClassDict objectForKey:cellInfo.cellReuseIdentifier]) {
        //prevent repeat register cell
        return;
    }
    if (cellInfo.nibForCell) {
        [self registerNib:cellInfo.nibForCell forCellWithReuseIdentifier:cellInfo.cellReuseIdentifier];
    } else if (cellInfo.cellClass) {
        [self registerClass:cellInfo.cellClass forCellWithReuseIdentifier:cellInfo.cellReuseIdentifier];
    }
}

@end
