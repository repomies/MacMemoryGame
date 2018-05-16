//
//  ViewController.swift
//  MacMemoryGame
//
//  Created by Janne Käki on 15/05/2018.
//  Copyright © 2018 Awesomeness Factory Oy. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSCollectionViewDataSource, NSCollectionViewDelegate {

    var collectionView: NSCollectionView!
    
    var objects: [String] = []
    var foundIndexPaths: [IndexPath] = []
    var previouslyOpenedIndexPath: IndexPath?
    
    let itemIdentifier = NSUserInterfaceItemIdentifier(rawValue: "GridItem")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = NSCollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 75, height: 75)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        layout.sectionInset = NSEdgeInsetsMake(10, 10, 10, 10)
        
        collectionView = NSCollectionView()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = layout
        collectionView.isSelectable = true
        collectionView.allowsMultipleSelection = false
        collectionView.register(GridItem.self, forItemWithIdentifier: itemIdentifier)
        view.addSubview(collectionView)
        
        collectionView.widthAnchor.constraint(equalToConstant: 326).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: 326).isActive = true
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        startNewGame()
    }
    
    func startNewGame() {
        
        objects = []
        foundIndexPaths = []
        previouslyOpenedIndexPath = nil
        
        let animals = ["🐨","🐗","🐷","🐸","🐺","🐤","🐴","🐧"]
        for animal in animals {
            for _ in 1 ... 2 {
                objects.append(animal)
            }
        }
        
        for _ in 1 ... 10 {
            objects.sort { a, b in
                return arc4random_uniform(2) == 0
            }
        }
        
        collectionView.reloadData()
    }
    
    @IBAction func startNewGame(_ sender: Any) {
        startNewGame()
    }
    
    public func collectionView(_ collectionView: NSCollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        
        return objects.count
    }
    
    public func collectionView(_ collectionView: NSCollectionView,
                               itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let item = collectionView.makeItem(withIdentifier: itemIdentifier, for: indexPath) as! GridItem
        
        item.label.stringValue = objects[indexPath.item]
        
        let isFound = foundIndexPaths.contains(indexPath)
        item.setOpened(isFound, animated: false)
        
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        didSelectItemsAt indexPaths: Set<IndexPath>) {
        
        guard let indexPath = indexPaths.first,
              let item = collectionView.item(at: indexPath) as? GridItem else { return }
        
        if foundIndexPaths.contains(indexPath) {
            return // No more flipping over the ones you've found
        }
        
        guard indexPath != previouslyOpenedIndexPath else { return }
        
        if previouslyOpenedIndexPath == nil {
            
            previouslyOpenedIndexPath = indexPath
            item.setOpened(true)
            
        } else {
            
            let previouslyOpenedObject = objects[previouslyOpenedIndexPath!.item]
            let currentlyOpenedObject = objects[indexPath.item]
            
            if previouslyOpenedObject == currentlyOpenedObject {
                
                foundIndexPaths.append(previouslyOpenedIndexPath!)
                foundIndexPaths.append(indexPath)
                item.setOpened(true)
                
            } else {
                
                let previouslyOpenedItem = collectionView.item(at: self.previouslyOpenedIndexPath!) as! GridItem
                item.setOpened(true) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        previouslyOpenedItem.setOpened(false)
                        item.setOpened(false)
                    }
                }
            }
            
            previouslyOpenedIndexPath = nil
        }
    }
}

class GridItem: NSCollectionViewItem {
    
    @IBOutlet var label: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer = CALayer()
        view.wantsLayer = true
    }
    
    func setOpened(_ opened: Bool,
                   animated: Bool = true,
                   completion: (() -> Void)? = nil) {
        
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = animated ? 0.2 : 0
            self.view.animator().alphaValue = 0
        }, completionHandler: {
            self.label.alphaValue = opened ? 1 : 0
            self.view.layer?.backgroundColor = NSColor(white: opened ? 0.95 : 0.85, alpha: 1).cgColor
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = animated ? 0.2 : 0
                self.view.animator().alphaValue = 1
            }, completionHandler: {
                completion?()
            })
        })
    }
}
