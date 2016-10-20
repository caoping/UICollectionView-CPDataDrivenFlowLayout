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

#pragma mark - Public

- (CGSize)cp_sizeForCellWithIdentifier:(NSString *)identifier
              preferredLayoutDimension:(CPPreferredLayoutDimension)preferredLayoutDimension
                  preferredLayoutValue:(CGFloat)preferredLayoutValue
                         configuration:(nullable void (^)(__kindof UICollectionViewCell *cell))configuration {
    if (!identifier) {
        return CGSizeZero;
    }
    
    NSLayoutConstraint *tempConstraint;
    UICollectionViewCell *templateLayoutCell = [self cp_templateCellForReuseIdentifier:identifier];
    
    CGRect frame = templateLayoutCell.frame;
    switch (preferredLayoutDimension) {
        case CPPreferredLayoutDimensionWidth:
        {
            frame.size.width = preferredLayoutValue;
            tempConstraint = [NSLayoutConstraint constraintWithItem:templateLayoutCell.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:preferredLayoutValue];
        }
            break;
        case CPPreferredLayoutDimensionHeight:
        {
            frame.size.height = preferredLayoutValue;
            tempConstraint = [NSLayoutConstraint constraintWithItem:templateLayoutCell.contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:preferredLayoutValue];
        }
            break;
    }
    templateLayoutCell.frame = frame;
    [templateLayoutCell prepareForReuse];
    [templateLayoutCell setNeedsLayout];
    [templateLayoutCell layoutIfNeeded];
    if (configuration) {
        configuration(templateLayoutCell);
    }
    
    CGSize fittingSize = CGSizeZero;
    if (tempConstraint && preferredLayoutValue > 0) {
        [templateLayoutCell.contentView addConstraint:tempConstraint];
        fittingSize = [templateLayoutCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        [templateLayoutCell.contentView removeConstraint:tempConstraint];
        
        switch (preferredLayoutDimension) {
            case CPPreferredLayoutDimensionWidth:
            {
                if (fittingSize.width != preferredLayoutValue) {
                    //iPhone 6 Plus在系统设置放大模式下，此处会计算错误
                    fittingSize.height = preferredLayoutValue/(fittingSize.width/fittingSize.height);
                    fittingSize.width = preferredLayoutValue;
                }
            }
                break;
            case CPPreferredLayoutDimensionHeight:
            {
                if (fittingSize.height != preferredLayoutValue) {
                    //iPhone 6 Plus在系统设置放大模式下，此处会计算错误
                    fittingSize.width = preferredLayoutValue/(fittingSize.height/fittingSize.width);
                    fittingSize.height = preferredLayoutValue;
                }
            }
                break;
        }
    }
    
    return fittingSize;
}

- (CGSize)cp_sizeForCellWithIdentifier:(NSString *)identifier
              preferredLayoutDimension:(CPPreferredLayoutDimension)preferredLayoutDimension
                  preferredLayoutValue:(CGFloat)preferredLayoutValue
                      cacheByIndexPath:(NSIndexPath *)indexPath
                         configuration:(nullable void (^)(__kindof UICollectionViewCell *cell))configuration {
    if (!identifier || !indexPath) {
        return CGSizeZero;
    }
    
    CGSize size = [self cp_sizeForCellWithIdentifier:identifier preferredLayoutDimension:preferredLayoutDimension preferredLayoutValue:preferredLayoutValue configuration:configuration];
    
    return size;
}

#pragma mark - Supplementary View

- (CGSize)cp_sizeForSupplementaryViewOfKind:(NSString *)kind
                                 identifier:(NSString *)identifier
                   preferredLayoutDimension:(CPPreferredLayoutDimension)preferredLayoutDimension
                       preferredLayoutValue:(CGFloat)preferredLayoutValue
                              configuration:(nullable void (^)(__kindof UICollectionReusableView *supplementaryView))configuration {
    if (!identifier) {
        return CGSizeZero;
    }
    
    UICollectionReusableView *templateLayoutSupplementaryView = [self cp_templateSupplementaryViewOfKind:kind reuseIdentifier:identifier];
    [templateLayoutSupplementaryView prepareForReuse];
    if (configuration) {
        configuration(templateLayoutSupplementaryView);
    }
    
    NSLayoutConstraint *tempConstraint;
    switch (preferredLayoutDimension) {
        case CPPreferredLayoutDimensionWidth:
        {
            tempConstraint = [NSLayoutConstraint constraintWithItem:templateLayoutSupplementaryView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:preferredLayoutValue];
        }
            break;
        case CPPreferredLayoutDimensionHeight:
        {
            tempConstraint = [NSLayoutConstraint constraintWithItem:templateLayoutSupplementaryView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:preferredLayoutValue];
        }
            break;
    }
    
    CGSize fittingSize = CGSizeZero;
    if (tempConstraint && preferredLayoutValue > 0) {
        [templateLayoutSupplementaryView addConstraint:tempConstraint];
        fittingSize = [templateLayoutSupplementaryView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        [templateLayoutSupplementaryView removeConstraint:tempConstraint];
        
        switch (preferredLayoutDimension) {
            case CPPreferredLayoutDimensionWidth:
            {
                if (fittingSize.width != preferredLayoutValue) {
                    //iPhone 6 Plus在系统设置放大模式下，此处会计算错误
                    fittingSize.height = preferredLayoutValue/(fittingSize.width/fittingSize.height);
                    fittingSize.width = preferredLayoutValue;
                }
            }
                break;
            case CPPreferredLayoutDimensionHeight:
            {
                if (fittingSize.height != preferredLayoutValue) {
                    //iPhone 6 Plus在系统设置放大模式下，此处会计算错误
                    fittingSize.width = preferredLayoutValue/(fittingSize.height/fittingSize.width);
                    fittingSize.height = preferredLayoutValue;
                }
            }
                break;
        }
    }
    
    return fittingSize;
}

@end
