//
//  DebugLayout.swift
//  CollectionLayoutTest
//
//  Created by O.Harmatiuk on 10/17/17.
//  Copyright © 2017 O.Harmatiuk. All rights reserved.
//

import UIKit

class DebugLayout: UICollectionViewFlowLayout {
    
    var cellSizeCache:[Int: CGSize] = [:]
    
    var cachedAttributes:[UICollectionViewLayoutAttributes] = []
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return super.layoutAttributesForItem(at: indexPath)
    }
    
    func cacheCalculatedSize(_ calculatedSize:CGSize, forItemAt indexPath:IndexPath) {
        cellSizeCache.updateValue(calculatedSize, forKey: indexPath.item)
        
        let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        let spacing:CGFloat = 10.0
        
        let itemIndex = indexPath.item
        
        var y = spacing
        if itemIndex > 0 {
            let previousItemSize = cellSizeCache[itemIndex - 1]
            let previousItemHeight:CGFloat = previousItemSize?.height ?? 0.0
            
            let previousItemAttributes = cachedAttributes[itemIndex - 1]
            
            y = previousItemAttributes.frame.origin.y + previousItemHeight + spacing
        }
        
        let originPoint = CGPoint(x: spacing, y: y)
        let size = calculatedSize
        
        attribute.frame = CGRect(origin: originPoint, size: size)
        
        print("Attributes #\(attribute.indexPath.item)\(attribute.frame)")
        
        cachedAttributes.append(attribute)
        
        if itemIndex == 0 {
            invalidateLayout()
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        print(items: rect)
        return cachedAttributes
    }
    
    override func prepare() {
        super.prepare()
    }
    
    override var collectionViewContentSize: CGSize {
        if cachedAttributes.isEmpty {
            return super.collectionViewContentSize
        } else {
            let lastAttribute = cachedAttributes.last!
            return CGSize(width: lastAttribute.size.width, height: lastAttribute.frame.origin.y + lastAttribute.size.height)
        }
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
    }
    
    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return super.shouldInvalidateLayout(forBoundsChange: newBounds)
    }
}
