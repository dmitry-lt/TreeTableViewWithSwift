# TreeTableViewWithSwift
TreeTableViewWithSwift is a TableView control that is displayed in a tree structure written in Swift.


## The origin of TreeTableViewWithSwift
Hierarchical presentation is required when developing a corporate address book. I have done similar functions before developing Android, and also used some open source content to transform and utilize. This time, when doing ios's similar products, the research found that there are not many controls of the tree structure, although most of them seem to be more responsible, and they are all written in OC. Between my project is developed by Swift, and the TreeTableView seems to have no one written in Swift (maybe I did not find it). So I plan to write one by myself, so that I can get enough food.


## Introduction to TreeTableViewWithSwift
>~~ Development Environment: Swift 5.0, Xcode Version: 10.2.1, ios 9.0

It can also be viewed through a short book: [简书](http://www.jianshu.com/p/75bcd49f144e)
### 1, running effect

![image](https://github.com/robertzhang/TreeTableViewWithSwift/raw/master/screenshots/treetableview-01.png)

### 2, Interpretation of key code
TreeTableViewWithSwift is actually an extension to tableview. Before you need to create a TreeNode class to store our data.

``` Swift
public class TreeNode {
    
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
    func setExpand(isExpand: Bool) {
        self.isExpand = isExpand
        if !isExpand {
            for (var i=0;i<children.count;i++) {
                children[i].setExpand(isExpand)
            }
        }
    }
    
}
```

It needs to be explained here that id and pId are respectively labeled for the current Node ID and its parent node ID. Nodes directly establish relationships are key attributes. Children is an array of TreeNodes that hold the immediate children of the current node. Through the children and parent properties, you can quickly find the relationship node of the current node.
In order to be able to manipulate our TreeNode data, I also created a TreeNodeHelper class.

 ``` Swift
 class TreeNodeHelper {
    
    // singleton mode
    class var sharedInstance: TreeNodeHelper {
        struct Static {
            static var instance: TreeNodeHelper?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) { // This function means that the code will only be run once, and this run is thread synchronization
            Static.instance = TreeNodeHelper()
        }
        return Static.instance!
    }

 ```

TreeNodeHelper is a tool class for singleton mode. Get the class instance through TreeNodeHelper.sharedInstance

 ``` Swift
    // Incoming ordinary nodes, converted to sorted Node
    func getSortedNodes(groups: NSMutableArray, defaultExpandLevel: Int) -> [TreeNode] {
        var result: [TreeNode] = []
        var nodes = convetData2Node(groups)
        var rootNodes = getRootNodes(nodes)
        for item in rootNodes{
            addNode(&result, node: item, defaultExpandLeval: defaultExpandLevel, currentLevel: 1)
        }
        
        return result
    }
    
    
 ```
getSortedNodes is the entry method of the TreeNode. When calling this method, you need to pass in a dataset of type Array. This data set can be anything you want to use to build a tree structure. Although I only passed in a group parameter here, I can actually refactor this method as needed, passing in multiple parameters like groups. For example, when we need to do a corporate directory, there are departmental collections and user collections in the corporate directory data. There is a hierarchical relationship between departments, and users belong to a certain department. We can convert both departments and users into TreeNode metadata. This modification method can be modified to:

 ```
 func getSortedNodes(groups: NSMutableArray, users: NSMutableArray, defaultExpandLevel: Int) -> [TreeNode]
 ```
Does it feel very interesting?

 ``` Swift
    // Filter out all visible nodes
    func filterVisibleNode(nodes: [TreeNode]) -> [TreeNode] {
        var result: [TreeNode] = []
        for item in nodes {
            if item.isRoot() || item.isParentExpand() {
                setNodeIcon(item)
                result.append(item)
            }
        }
        return result
    }
    
    // Convert the data into a book node
    func convetData2Node(groups: NSMutableArray) -> [TreeNode] {
        var nodes: [TreeNode] = []
        
        var node: TreeNode
        var desc: String?
        var id: String?
        var pId: String?
        var label: String?
        var type: Int?
        
        for item in groups {
            desc = item["description"] as? String
            id = item["id"] as? String
            pId = item["pid"] as? String
            label = item["name"] as? String
            
            node = TreeNode(desc: desc, id: id, pId: pId, name: label)
            nodes.append(node)
        }
        
        /**
        * Set Node, parent-child relationship; let each two nodes compare once, you can set the relationship
        */
        var n: TreeNode
        var m: TreeNode
        for (var i=0; i<nodes.count; i++) {
            n = nodes[i]
            
            for (var j=i+1; j<nodes.count;j++) {
                m = nodes[j]
                if m.pId == n.id {
                    n.children.append(m)
                    m.parent = n
                } else if n.pId == m.id {
                    m.children.append(n)
                    n.parent = m
                }
            }
        }
        for item in nodes {
            setNodeIcon(item)
        }
        
        return nodes
    }
 ```
 
 The convetData2Node method converts the data into a TreeNode and also builds the relationship between the TreeNodes.
 
 ``` Swift
    // Get the root node set
    func getRootNodes(nodes: [TreeNode]) -> [TreeNode] {
        var root: [TreeNode] = []
        for item in nodes {
            if item.isRoot() {
                root.append(item)
            }
        }
        return root
    }
    
    // hang all the child nodes of a node
    func addNode(inout nodes: [TreeNode], node: TreeNode, defaultExpandLeval: Int, currentLevel: Int) {
        nodes.append(node)
        if defaultExpandLeval >= currentLevel {
            node.setExpand(true)
        }
        if node.isLeaf() {
            return
        }
        for (var i=0; i<node.children.count;i++) {
            addNode(&nodes, node: node.children[i], defaultExpandLeval: defaultExpandLeval, currentLevel: currentLevel+1)
        }
    }
    
    // Set the node icon
    func setNodeIcon(node: TreeNode) {
        if node.children.count > 0 {
            node.type = TreeNode.NODE_TYPE_G
            if node.isExpand {
                // Set the icon to the down arrow
                node.icon = "tree_ex.png"
            } else if !node.isExpand {
                // Set the icon to the right arrow
                node.icon = "tree_ec.png"
            }
        } else {
            node.type = TreeNode.NODE_TYPE_N
        }
    }
}
 ```
The rest of the code is not very difficult and easy to understand. Need to say more about TreeNode.NODE\_TYPE\_G and TreeNode.NODE\_TYPE\_N are used to tell the TreeNode the current type of node. As mentioned in the corporate directory, these two types can be used to distinguish node data.

TreeTableView is my main event. It inherits UITableView, UITableViewDataSource, UITableViewDelegate.

 ``` Swift
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Custom tableviewcell through nib
        let nib = UINib(nibName: "TreeNodeTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: NODE_CELL_ID)
        
        var cell = tableView.dequeueReusableCellWithIdentifier(NODE_CELL_ID) as! TreeNodeTableViewCell
        
        var node: TreeNode = mNodes![indexPath.row]
        
        // cell indent
        cell.background.bounds.origin.x = -20.0 * CGFloat(node.getLevel())
        
        // Code to modify the display mode of nodeIMG---UIImageView.
        if node.type == TreeNode.NODE_TYPE_G {
            cell.nodeIMG.contentMode = UIViewContentMode.Center
            cell.nodeIMG.image = UIImage(named: node.icon!)
        } else {
            cell.nodeIMG.image = nil
        }
        
        cell.nodeName.text = node.name
        cell.nodeDesc.text = node.desc
        return cell
    }
 ```
In the tableView:cellForRowAtIndexPath method, we used UINib because I populated the tableview by customizing the TableViewCell. The reuse mechanism of the cell is also used here.

Let's look at the key code that controls the expansion of the tree structure.

 ```
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var parentNode = mNodes![indexPath.row]
        
        var startPosition = indexPath.row+1
        var endPosition = startPosition
        
        if parentNode.isLeaf() {// The node clicked is the leaf node
            // do something
        } else {
            expandOrCollapse(&endPosition, node: parentNode)
            mNodes = TreeNodeHelper.sharedInstance.filterVisibleNode(mAllNodes!) // Update visible node
            
            // Fix indexpath
            var indexPathArray :[NSIndexPath] = []
            var tempIndexPath: NSIndexPath?
            for (var i = startPosition; i < endPosition ; i++) {
                tempIndexPath = NSIndexPath(forRow: i, inSection: 0)
                indexPathArray.append(tempIndexPath!)
            }
            
            // Insert and delete animations of nodes
            if parentNode.isExpand {
                self.insertRowsAtIndexPaths(indexPathArray, withRowAnimation: UITableViewRowAnimation.None)
            } else {
                self.deleteRowsAtIndexPaths(indexPathArray, withRowAnimation: UITableViewRowAnimation.None)
            }
            // Update the selected group node
            self.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            
        }
        
    }
    
    // Expand or close a node
    func expandOrCollapse(inout count: Int, node: TreeNode) {
        if node.isExpand { // If the current node is open, you need to close all children under the node
            closedChildNode(&count,node: node)
        } else { // If the node is closed, open the current node
            count += node.children.count
            node.setExpand(true)
        }
        
    }
    
    // Close a node and all children of the node
    func closedChildNode(inout count:Int, node: TreeNode) {
        if node.isLeaf() {
            return
        }
        if node.isExpand {
            node.isExpand = false
            for item in node.children { // close child node
                count++ // calculate the number of child nodes plus one
                closedChildNode(&count, node: item)
            }
        } 
    }

 ```
When we click on a non-leaf node, we add the child nodes of the node to our tableView and animate them. This is the tree-expanded view we need. First, we need to calculate the number of children of the node (when the node is closed, we need to calculate the number of nodes of the child nodes of the corresponding child nodes), and then obtain the set of these child nodes, through the insertRowsAtIndexPaths and deleteRowsAtIndexPaths methods of the tableview. Insert nodes and delete nodes.

Tableview:didSelectRowAtIndexPath is still well understood, the key is the expandOrCollapse and closedChildNode methods.

The role of expandOrCollapse is to open or close the click node. When the operation is to open a node, you only need to set the node to expand, and calculate the number of its children. Turning off a node is relatively cumbersome. Because we want to calculate whether the child node is open, if the child node is open, then the number of child nodes of the child node is also calculated. It may sound a bit confusing here, it is recommended to look at the examples to understand after running the program.

### 3, Acknowledgement
The materials borrowed are:

* [swift expandable shrinkable table view] (http://www.jianshu.com/p/706dcc4ccb2f)

* [Android builds any level of tree control to test your data structure and design] (http://blog.csdn.net/lmj623565791/article/details/40212367)

Interested friends can also refer to the above two blogs.

## License
All source code is licensed under the MIT License.




