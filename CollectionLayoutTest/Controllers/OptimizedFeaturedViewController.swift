//
//  OptimizedFeaturedViewController.swift
//  CollectionLayoutTest
//
//  Created by O.Harmatiuk on 10/20/17.
//  Copyright © 2017 O.Harmatiuk. All rights reserved.
//

import UIKit

class OptimizedFeaturedViewController: UIViewController {
    fileprivate let reuseIdentifier = "OptimizedCollectionViewCell"
    
    private var generator = LoremIpsumGenerator()
    
    fileprivate var phrases:[String] = []
    fileprivate var cellPhrases:[Int:[String]] = [:]

    fileprivate var cacheSize = 1000
    fileprivate var cellNib: UINib = UINib(nibName: "OptimizedCollectionViewCell", bundle: nil)
    
    @IBOutlet weak var collectionView: DebugCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(cellNib, forCellWithReuseIdentifier: reuseIdentifier)
        
        if let layout = collectionView?.collectionViewLayout as? OptimizedLayout {
            layout.estimatedItemSize = CGSize(width: 240, height: 300)
        }
        
        pregeneratePhrases()
        precalculateCellSizes()
    }
    
    private func pregeneratePhrases() {
        for index in 1...100 {
            let randomMultiplier = Int(arc4random_uniform(UInt32(index))) + 5
            phrases.append(generator.createPhrase((randomMultiplier)))
        }
    }
    
    private func precalculateCellSizes() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let weakSelf = self else { return }
            
            for index in 0..<weakSelf.cacheSize {
                let indexPath = IndexPath(row: index, section: 0)
                let size = weakSelf.calculateCellSize(for: indexPath)
                guard let layout = weakSelf.collectionView.collectionViewLayout as? OptimizedLayout else { return }
                DispatchQueue.main.async {
                    layout.cacheCalculatedSize(size, forItemAt: indexPath)
                }
            }
        }
    }
    
    private func calculateCellSize(for indexPath:IndexPath)->CGSize {
        let nib = UINib(nibName: "OptimizedCollectionViewCell", bundle: nil)
        let templateCell = nib.instantiate(withOwner: self, options: nil).first as! OptimizedCollectionViewCell
        setupCell(cell: templateCell, at: indexPath)
        return templateCell.mainContainer.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    }
    
    fileprivate func setupCell(cell:OptimizedCollectionViewCell, at indexPath:IndexPath) {
        //print("\(#function) for \(indexPath)")
        cell.widthConstraint.constant = collectionView.bounds.size.width
        cell.titleLabel.text = "Cell \(indexPath.item)"
    
        var features = cellPhrases[indexPath.item]
        if features == nil {
            let randomMultiplier = Int(arc4random_uniform(10)) + 5
            features = phrases.prefix(upTo: randomMultiplier).reversed()
            cellPhrases.updateValue(features!, forKey: indexPath.item)
        }
        cell.setupStackView(with: features!)
    
        cell.emptyView.backgroundColor = UIColor.randomColor()
    }
}

extension OptimizedFeaturedViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10000
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.tag = indexPath.item
        guard let customCell = cell as? OptimizedCollectionViewCell else { return cell }
        
        setupCell(cell: customCell, at: indexPath)
        
        return cell
    }
}
