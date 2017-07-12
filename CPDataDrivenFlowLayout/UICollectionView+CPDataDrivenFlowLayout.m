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
@property (nonatomic, strong) id interceptor;

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
    
    return [[self class] voidSignature];//prevent crash when signature is nil
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if ([invocation methodSignature] == [[self class] voidSignature]) {
        return;
    }
    if ([_interceptor respondsToSelector:invocation.selector]) {
    
        [invocation invokeWithTarget:_interceptor];
    } else if ([_target respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:_target];
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



@implementation UICollectionView (CPDataDrivenFlowLayout)

#define __DescriptionForAssert [NSString stringWithFormat:@"invoke %@ before must be set cp_delegateProxy/cp_dataSourceProxy interceptor",NSStringFromSelector(_cmd)]
#define CPDataDrivenFlowLayoutEnabledAssert() NSAssert([self cp_delegateProxy].interceptor && [self cp_dataSourceProxy].interceptor, __DescriptionForAssert)

#pragma mark - Associated Object

- (NSArray<CPCollectionViewSectionInfo *> *)cp_sectionInfos {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCp_sectionInfos:(NSArray<CPCollectionViewSectionInfo *> * _Nonnull)cp_sectionInfos {
    objc_setAssociatedObject(self, @selector(cp_sectionInfos), cp_sectionInfos, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Delegate and DataSource Proxy

- (_CPCollectionViewFlowLayoutProxy *)cp_delegateProxy {
    _CPCollectionViewFlowLayoutProxy *proxy = objc_getAssociatedObject(self, _cmd);
    if (!proxy) {
        proxy = [[_CPCollectionViewFlowLayoutProxy alloc] initWithTarget:nil interceptor:nil];
        [self setCp_delegateProxy:proxy];
    }
    
    return proxy;
}

- (void)setCp_delegateProxy:(_CPCollectionViewFlowLayoutProxy *)cp_delegateProxy {
    objc_setAssociatedObject(self, @selector(cp_delegateProxy), cp_delegateProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (_CPCollectionViewFlowLayoutProxy *)cp_dataSourceProxy {
    _CPCollectionViewFlowLayoutProxy *proxy = objc_getAssociatedObject(self, _cmd);
    if (!proxy) {
        proxy = [[_CPCollectionViewFlowLayoutProxy alloc] initWithTarget:nil interceptor:nil];
        [self setCp_dataSourceProxy:proxy];
    }
    
    return proxy;
}

- (void)setCp_dataSourceProxy:(_CPCollectionViewFlowLayoutProxy *)cp_dataSourceProxy {
    objc_setAssociatedObject(self, @selector(cp_dataSourceProxy), cp_dataSourceProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - 

- (void)cp_enableDataDrivenFlowLayout {
    [self cp_setDefaultInterceptorForCurrentDelegateAndDataSource];
}

- (void)cp_setDefaultInterceptorForCurrentDelegateAndDataSource {
    [self cp_setDelegate:self.delegate interceptor:[CPCollectionViewDelegateFlowLayoutInterceptor new]];
    [self cp_setDataSource:self.dataSource interceptor:[CPCollectionViewDataSourceInterceptor new]];
}

#pragma mark - Set Delegate & DataSource

- (void)cp_setDelegate:(id<UICollectionViewDelegate>)delegate interceptor:(id<UICollectionViewDelegateFlowLayout>)interceptor {
    NSParameterAssert(interceptor);
    
    if (delegate != [self cp_delegateProxy]) {
        [self cp_delegateProxy].target = delegate;
        [self cp_delegateProxy].interceptor = interceptor;
        [self setDelegate:(id <UICollectionViewDelegate>)[self cp_delegateProxy]];
    }
}

- (void)cp_setDataSource:(id<UICollectionViewDataSource>)dataSource interceptor:(id<UICollectionViewDelegateFlowLayout>)interceptor {
    NSParameterAssert(interceptor);
    
    if (dataSource != [self cp_dataSourceProxy]) {
        [self cp_dataSourceProxy].target = dataSource;
        [self cp_dataSourceProxy].interceptor = interceptor;
        [self setDataSource:(id <UICollectionViewDataSource>)[self cp_dataSourceProxy]];
    }
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
