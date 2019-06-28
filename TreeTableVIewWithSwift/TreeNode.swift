//
//  TreeNode.swift
//  TreeTableVIewWithSwift
//
//  Created by Robert Zhang on 15/10/24.
//  Copyright © 2015年 robertzhang. All rights reserved.
//

import Foundation


open class TreeNode {
    
    static let NODE_TYPE_G: Int = 0 // indicates that the node is not a leaf node
    static let NODE_TYPE_N: Int = 1 // indicates that the node is a leaf node
    var type: Int?
    var desc: String? // For multiple types of content, you need to determine its content
    var id: String?
    var pId: String?
    var name: String?
    var level: Int?
    var isExpand: Bool = false
    var icon: String?
    var children: [TreeNode] = []
    var parent: TreeNode?
    
    init (desc: String?, id:String? , pId: String? , name: String?) {
        self.desc = desc
        self.id = id
        self.pId = pId
        self.name = name
    }
    
    // Is it the root node?
    func isRoot() -> Bool{
        return parent == nil
    }
    
    // Determine if the parent node is open
    func isParentExpand() -> Bool {
        if parent == nil {
            return false
        }
        return (parent?.isExpand)!
    }
    
    // Is it a leaf node?
    func isLeaf() -> Bool {
        return children.count == 0
    }
    
    // Get level, used to set the distance of the left side of the node content
    func getLevel() -> Int {
        return parent == nil ? 0 : (parent?.getLevel())!+1
    }
    
    // Set the expansion
    func setExpand(_ isExpand: Bool) {
        self.isExpand = isExpand
        if !isExpand {
            for i in 0 ..< children.count {
                children[i].setExpand(isExpand)
            }
        }
    }    
}
