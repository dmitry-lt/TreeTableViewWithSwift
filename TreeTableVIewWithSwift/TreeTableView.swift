//
//  TreeTableView.swift
//  TreeTableVIewWithSwift
//
//  Created by Robert Zhang on 15/10/24.
//  Copyright © 2015年 robertzhang. All rights reserved.
//

import UIKit

protocol TreeTableViewCellDelegate: NSObjectProtocol {
    func cellClick() // The parameter has not been added yet, and the TreeNode represents the node.
}


class TreeTableView: UITableView, UITableViewDataSource,UITableViewDelegate{
    
    var mAllNodes: [TreeNode]? // All nodes
    var mNodes: [TreeNode]? // Visible nodes
    
    //    var treeTableViewCellDelegate: TreeTableViewCellDelegate?
    
    let NODE_CELL_ID: String = "nodecell"
    
    init(frame: CGRect, withData data: [TreeNode]) {
        super.init(frame: frame, style: UITableView.Style.plain)
        self.delegate = self
        self.dataSource = self
        mAllNodes = data
        mNodes = TreeNodeHelper.sharedInstance.filterVisibleNode(mAllNodes!)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Custom tableviewcell through nib
        let nib = UINib(nibName: "TreeNodeTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: NODE_CELL_ID)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NODE_CELL_ID) as! TreeNodeTableViewCell
        
        let node: TreeNode = mNodes![indexPath.row]
        
        // cell indent
        cell.background.bounds.origin.x = -20.0 * CGFloat(node.getLevel())
        
         // Code to modify the display mode of nodeIMG---UIImageView.
        if node.type == TreeNode.NODE_TYPE_G {
            cell.nodeIMG.contentMode = UIView.ContentMode.center
            cell.nodeIMG.image = UIImage(named: node.icon!)
        } else {
            cell.nodeIMG.image = nil
        }
        
        cell.nodeName.text = node.name
        cell.nodeDesc.text = node.desc
        return cell
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (mNodes?.count)!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let parentNode = mNodes![indexPath.row]
        
        let startPosition = indexPath.row+1
        var endPosition = startPosition
        
        if parentNode.isLeaf() {// The node clicked is the leaf node
            // do something
        } else {
            expandOrCollapse(&endPosition, node: parentNode)
            mNodes = TreeNodeHelper.sharedInstance.filterVisibleNode(mAllNodes!) // Update visible node
            
            // Fix indexpath
            var indexPathArray :[IndexPath] = []
            var tempIndexPath: IndexPath?
            for i in startPosition ..< endPosition {
                tempIndexPath = IndexPath(row: i, section: 0)
                indexPathArray.append(tempIndexPath!)
            }
            
            // Insert and delete animations of nodes
            if parentNode.isExpand {
                self.insertRows(at: indexPathArray, with: UITableView.RowAnimation.none)
            } else {
                self.deleteRows(at: indexPathArray, with: UITableView.RowAnimation.none)
            }
            // Update the selected group node
            self.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
            
        }
        
    }
    
    // Expand or close a node
    func expandOrCollapse(_ count: inout Int, node: TreeNode) {
        if node.isExpand { // If the current node is open, you need to close all children under the node
            closedChildNode(&count,node: node)
        } else { // If the node is closed, open the current node
            count += node.children.count
            node.setExpand(true)
        }
        
    }
    
    // Close a node and all children of the node
    func closedChildNode(_ count:inout Int, node: TreeNode) {
        if node.isLeaf() {
            return
        }
        if node.isExpand {
            node.isExpand = false
            for item in node.children { // close child node
                count += 1 // calculate the number of child nodes plus one
                closedChildNode(&count, node: item)
            }
        } 
    }
    
}

