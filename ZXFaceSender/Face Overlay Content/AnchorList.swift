/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Demonstrates how to simulate occlusion of virtual content by the real-world face.
*/

import ARKit
import SceneKit

struct MyDevice:Codable {
    var deviceId:String
    var deviceName:String
    var deviceCount:String
}

class AnchorListController: UITableViewController {
    
    open var AnchorNames = ["browDown_L",    "browDown_R",     "browInnerUp",    "browOuterUp_L",   "browOuterUp_R",
                            "cheekPuff",     "cheekSquint_L",  "cheekSquint_R",  "eyeBlink_L",      "eyeBlink_R",
                            "eyeLookDown_L", "eyeLookDown_R",  "eyeLookIn_L",    "eyeLookIn_R",     "eyeLookOut_L",
                            "eyeLookOut_R",  "eyeLookUp_L",    "eyeLookUp_R",    "eyeSquint_L",     "eyeSquint_R",
                            "eyeWide_L",     "eyeWide_R",      "jawForward",     "jawLeft",         "jawOpen",
                            "jawRight",      "mouthClose",     "mouthDimple_L",  "mouthDimple_R",   "mouthFrown_L",
                            "mouthFrown_R",  "mouthFunnel",    "mouthLeft",      "mouthLowerDown_L","mouthLowerDown_R",
                            "mouthPress_L",  "mouthPress_R",   "mouthPucker",    "mouthRight",      "mouthRollLower",
                            "mouthRollUpper","mouthShrugLower","mouthShrugUpper","mouthSmile_L",    "mouthSmile_R",
                            "mouthStretch_L","mouthStretch_R", "mouthUpperUp_L", "mouthUpperUp_R",  "noseSneer_L",
                            "noseSneer_R",   "tongueOut"]
     
    //var AnchorNames:[String] = []
    var AnchorDict : [String:String] = [:]
    var lock = NSLock()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
     //   #warning Incomplete implementation, return the number of sections
          return 1
     }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 52
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let cellId = String(describing: AnchorListCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! AnchorListCell
        
        lock.lock()
        
        if indexPath.row < AnchorNames.count {
            cell.AnchorName.text = AnchorNames[indexPath.row]
            cell.AnchorValue.text = AnchorDict[AnchorNames[indexPath.row]]
        }

        lock.unlock()
        
        return cell
    }
    
    func UpdateAnchorValues(_ Anchor:ARFaceAnchor) ->Void {
        lock.lock()
        AnchorDict.removeAll()
        
       // [ARFaceAnchor.BlendShapeLocation : NSNumber]
        

        for (key, value) in Anchor.blendShapes {
            let temp1:String = String(key.rawValue)
            let temp2:String = String(format: "%.3f", value.floatValue)
            //let temp2:String = String(value.floatValue.format(""))
            AnchorDict[temp1] = temp2
        }
        lock.unlock()

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

class AnchorListCell: UITableViewCell {


    @IBOutlet weak var AnchorName: UILabel!
    @IBOutlet weak var AnchorValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

class AnchorList: NSObject, VirtualContentController {
    
    var contentNode: SCNNode?
    weak var TableView: UITableView!
   
    ///	 - Tag: ARNodeTracking
    /// - Tag: CreateARSCNFaceGeometry
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let sceneView = renderer as? ARSCNView,
            anchor is ARFaceAnchor else { return nil }
        
        #if targetEnvironment(simulator)
        #error("ARKit is not supported in iOS Simulator. Connect a physical iOS device and select it as your Xcode run destination, or select Generic iOS Device as a build-only destination.")
        #else
        let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!)!
        let material = faceGeometry.firstMaterial!
        
        material.diffuse.contents = #imageLiteral(resourceName: "wireframeTexture") // Example texture map image.
        material.lightingModel = .physicallyBased
        
        contentNode = SCNNode(geometry: faceGeometry)
        #endif
        return contentNode 
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceGeometry = node.geometry as? ARSCNFaceGeometry,
            let faceAnchor = anchor as? ARFaceAnchor
            else { return }
        
        faceGeometry.update(from: faceAnchor.geometry)
    }

    func SetTableUI(_ UI: UITableView){
        TableView = UI
    }
    
    func ShowPrivateWindow(){
        if TableView != nil {
            TableView.isHidden = false
            print("2\n")
        }
    }
}
