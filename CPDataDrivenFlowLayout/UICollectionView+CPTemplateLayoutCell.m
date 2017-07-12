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

#import "UICollectionView+CPTemplateLayoutCell.h"
#import <objc/runtime.h>

@implementation UICollectionView (CPTemplateLayoutCell)

- (__kindof UICollectionReusableView *)cp_templateSupplementaryViewOfKind:(NSString *)kind reuseIdentifier:(NSString *)identifier {
    NSAssert(identifier.length > 0, @"Expect a valid identifier - %@", identifier);
    
    NSMutableDictionary<NSString *, __kindof UICollectionReusableView *> *templateSupplementaryViewsByIdentifiers = objc_getAssociatedObject(self, _cmd);
    if (!templateSupplementaryViewsByIdentifiers) {
        templateSupplementaryViewsByIdentifiers = [@{} mutableCopy];
        objc_setAssociatedObject(self, _cmd, templateSupplementaryViewsByIdentifiers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    NSString *key = [NSString stringWithFormat:@"%@/%@",kind,identifier];
    
    UICollectionReusableView *templateSupplementaryView = [templateSupplementaryViewsByIdentifiers valueForKey:key];
    
    if (!templateSupplementaryView) {
        NSDictionary *supplementaryViewNibDict = [self valueForKey:@"_supplementaryViewNibDict"];
        NSDictionary *supplementaryViewClassDict = [self valueForKey:@"_supplementaryViewClassDict"];
        
        if ([supplementaryViewNibDict valueForKey:key]) {
            //instance from nib
            UINib *supplementaryViewNib = [supplementaryViewNibDict valueForKey:key];
            templateSupplementaryView = [[supplementaryViewNib instantiateWithOwner:nil options:nil] firstObject];
        } else if ([supplementaryViewClassDict valueForKey:key]) {
            //instance from class
            Class cls = [supplementaryViewClassDict valueForKey:key];
            templateSupplementaryView = [cls new];
        } else {
            NSAssert(NO, @"Supplementary View must be registered to collection view for identifier - %@", identifier);
        }
        templateSupplementaryView.translatesAutoresizingMaskIntoConstraints = NO;
        templateSupplementaryViewsByIdentifiers[key] = templateSupplementaryView;
    }
    
    return templateSupplementaryView;
}

- (__kindof UICollectionViewCell *)cp_templateCellForReuseIdentifier:(NSString *)identifier {
    NSAssert(identifier.length > 0, @"Expect a valid identifier - %@", identifier);
    
    NSMutableDictionary<NSString *, __kindof UICollectionViewCell *> *templateCellsByIdentifiers = objc_getAssociatedObject(self, _cmd);
    if (!templateCellsByIdentifiers) {
        templateCellsByIdentifiers = [@{} mutableCopy];
        objc_setAssociatedObject(self, _cmd, templateCellsByIdentifiers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    UICollectionViewCell *templateCell = [templateCellsByIdentifiers valueForKey:identifier];
    
    if (!templateCell) {
        NSDictionary *cellNibDict = [self valueForKey:@"_cellNibDict"];
        NSDictionary *cellClassDict = [self valueForKey:@"_cellClassDict"];
        if ([cellNibDict valueForKey:identifier]) {
            //instance from nib
            UINib *cellNib = [cellNibDict valueForKey:identifier];
            templateCell = [[cellNib instantiateWithOwner:nil options:nil] firstObject];
        } else if ([cellClassDict valueForKey:identifier]) {
            //instance from class
            Class cls = [cellClassDict valueForKey:identifier];
            templateCell = [cls new];
        } else {
            NSAssert(NO, @"Cell must be registered to collection view for identifier - %@", identifier);
        }
        templateCell.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        templateCellsByIdentifiers[identifier] = templateCell;
    }
    
    return templateCell;
}

#pragma mark - Calculating CollectionView Cell Size

- (CGSize)cp_sizeForCellWithIdentifier:(NSString *)identifier
              preferredLayoutDimension:(CPPreferredLayoutDimension)preferredLayoutDimension
                  preferredLayoutValue:(CGFloat)preferredLayoutValue
                         configuration:(nullable void (^)(__kindof UICollectionViewCell *cell))configuration {
    if (!identifier || preferredLayoutValue <= 0) {
        return CGSizeZero;
    }
    
    UICollectionViewCell *templateLayoutCell = [self cp_templateCellForReuseIdentifier:identifier];
    
    return [self cp_sizeForReusableView:templateLayoutCell
               preferredLayoutDimension:preferredLayoutDimension
                   preferredLayoutValue:preferredLayoutValue
                          configuration:configuration];
}

- (CGSize)cp_sizeForCellWithIdentifier:(NSString *)identifier
              preferredLayoutDimension:(CPPreferredLayoutDimension)preferredLayoutDimension
                  preferredLayoutValue:(CGFloat)preferredLayoutValue
                      cacheByIndexPath:(NSIndexPath *)indexPath
                         configuration:(nullable void (^)(__kindof UICollectionViewCell *cell))configuration {
    if (!identifier || preferredLayoutValue <= 0) {
        return CGSizeZero;
    }
    
    return [self cp_sizeForCellWithIdentifier:identifier
                     preferredLayoutDimension:preferredLayoutDimension
                         preferredLayoutValue:preferredLayoutValue
                                configuration:configuration];
}

#pragma mark - Calculating Supplementary View Size

- (CGSize)cp_sizeForSupplementaryViewOfKind:(NSString *)kind
                                 identifier:(NSString *)identifier
                   preferredLayoutDimension:(CPPreferredLayoutDimension)preferredLayoutDimension
                       preferredLayoutValue:(CGFloat)preferredLayoutValue
                              configuration:(nullable void (^)(__kindof UICollectionReusableView *supplementaryView))configuration {
    if (!identifier || preferredLayoutValue <= 0) {
        return CGSizeZero;
    }
    
    UICollectionReusableView *templateLayoutSupplementaryView = [self cp_templateSupplementaryViewOfKind:kind reuseIdentifier:identifier];
    return [self cp_sizeForReusableView:templateLayoutSupplementaryView
               preferredLayoutDimension:preferredLayoutDimension
                   preferredLayoutValue:preferredLayoutValue
                          configuration:configuration];
}

#pragma mark - Calculating ReusableView Size

- (CGSize)cp_sizeForReusableView:(__kindof UICollectionReusableView *)reusableView
        preferredLayoutDimension:(CPPreferredLayoutDimension)preferredLayoutDimension
            preferredLayoutValue:(CGFloat)preferredLayoutValue
                   configuration:(nullable void (^)(__kindof UICollectionReusableView *reusableView))configuration {
    if (!reusableView || preferredLayoutValue <= 0) {
        return CGSizeZero;
    }
    
    CGSize fittingSize = UILayoutFittingCompressedSize;
    UILayoutPriority hFittingPriority = UILayoutPriorityRequired;
    UILayoutPriority vFittingPriority = UILayoutPriorityRequired;
    UICollectionViewCell *templateLayoutCell;
    
    //如果reusableView为Cell时
    if ([reusableView isKindOfClass:[UICollectionViewCell class]]) {
        templateLayoutCell = reusableView;
        
        //修正Cell frame
        CGRect frame = templateLayoutCell.frame;
        if (preferredLayoutDimension == CPPreferredLayoutDimensionWidth) {
            frame.size.width = preferredLayoutValue;
        } else {
            frame.size.height = preferredLayoutValue;
        }
        templateLayoutCell.frame = frame;
    }
    
    //根据Dimension设置计算参数
    switch (preferredLayoutDimension) {
        case CPPreferredLayoutDimensionWidth:
        {
            fittingSize.width = preferredLayoutValue;
            vFittingPriority = UILayoutPriorityFittingSizeLevel;
        }
            break;
        case CPPreferredLayoutDimensionHeight:
        {
            fittingSize.height = preferredLayoutValue;
            hFittingPriority = UILayoutPriorityFittingSizeLevel;
        }
            break;
    }
    
    //prepare and configuration
    [reusableView prepareForReuse];
    if (configuration) {
        configuration(reusableView);
    }
    
    UIView *templateLayoutView = reusableView;
    if (templateLayoutCell) {
        //Cell需要使用其contentView计算尺寸
        [templateLayoutCell setNeedsLayout];
        [templateLayoutCell layoutIfNeeded];
        templateLayoutView = templateLayoutCell.contentView;
    }
    
    CGSize systemLayoutSize = [templateLayoutView systemLayoutSizeFittingSize:fittingSize
                                                withHorizontalFittingPriority:hFittingPriority
                                                      verticalFittingPriority:vFittingPriority];
    NSAssert(!CGSizeEqualToSize(systemLayoutSize, CGSizeZero), @"invalid systemLayoutSize");
    
    //检查是否需要修正
    switch (preferredLayoutDimension) {
        case CPPreferredLayoutDimensionWidth:
        {
            if (systemLayoutSize.width != preferredLayoutValue) {
                //iPhone 6 Plus在系统设置放大模式下，此处需要根据比例修正height
                systemLayoutSize.height = preferredLayoutValue/(systemLayoutSize.width/systemLayoutSize.height);
                systemLayoutSize.width = preferredLayoutValue;
            }
        }
            break;
        case CPPreferredLayoutDimensionHeight:
        {
            if (systemLayoutSize.height != preferredLayoutValue) {
                //iPhone 6 Plus在系统设置放大模式下，此处需要根据比例修正width
                systemLayoutSize.width = preferredLayoutValue/(systemLayoutSize.height/systemLayoutSize.width);
                systemLayoutSize.height = preferredLayoutValue;
            }
        }
            break;
    }
    
    return systemLayoutSize;
}

@end
