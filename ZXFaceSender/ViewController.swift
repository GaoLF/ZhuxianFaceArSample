/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import ARKit
import SceneKit
import UIKit

class ViewController: UIViewController, ARSessionDelegate, UITextFieldDelegate {
    
    // MARK: Outlets

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var AnchorList: UITableView!
    
    @IBOutlet weak var ConnectView: UIStackView!
    @IBOutlet weak var IPInput: UITextField!
    @IBOutlet weak var PortInput: UITextField!
    @IBOutlet weak var ConnectConfirm: UIButton!
 
    @IBOutlet weak var BtnRecord: UIButton!
    @IBOutlet weak var BtnStopRecord: UIButton!
    
    
    // MARK: Properties

    var contentControllers: [VirtualContentType: VirtualContentController] = [:]
    
    let AnchorController : AnchorListController = AnchorListController()
    let ConnectViewController : ConnectController = ConnectController()
    
    var selectedVirtualContent: VirtualContentType! {
        didSet {
            guard oldValue != nil, oldValue != selectedVirtualContent
                else { return }
            
            // Remove existing content when switching types.
            contentControllers[oldValue]?.contentNode?.removeFromParentNode()
            
            // If there's an anchor already (switching content), get the content controller to place initial content.
            // Otherwise, the content controller will place it in `renderer(_:didAdd:for:)`.
            
            AnchorList.isHidden = true
            ConnectView.isHidden = true
            BtnRecord.isHidden = true
            BtnStopRecord.isHidden = true
            
            selectedContentController.ShowPrivateWindow()
            

            
            if let anchor = currentFaceAnchor, let node = sceneView.node(for: anchor),
                let newContent = selectedContentController.renderer(sceneView, nodeFor: anchor) {
                node.addChildNode(newContent)
            }
        }
    }
    var selectedContentController: VirtualContentController {
        if let controller = contentControllers[selectedVirtualContent] {
            return controller
        } else {
            let controller = selectedVirtualContent.makeController()
            
            if selectedVirtualContent == VirtualContentType.connectpc{
                if let TempView = controller as? ConnectPC{
                    TempView.SetStackUI(ConnectView)
                    TempView.SetBtnUI(BtnRecord, stop:BtnStopRecord)
                    TempView.SetTrueConnectController(ConnectViewController)
                }
            }
            
            if selectedVirtualContent == VirtualContentType.anchorlist{
                if let TempView = controller as? AnchorList{
                    TempView.SetTableUI(AnchorList)
                }
            }
            
            contentControllers[selectedVirtualContent] = controller
            return controller
        }
    }
    
    var currentFaceAnchor: ARFaceAnchor?
    
    // MARK: - View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        
        // Set the initial face content.
        tabBar.selectedItem = tabBar.items!.first!
        selectedVirtualContent = VirtualContentType(rawValue: tabBar.selectedItem!.tag)
        
        selectedVirtualContent = VirtualContentType(rawValue: 2)
        
        AnchorList.dataSource = AnchorController
        AnchorList.delegate = AnchorController
        
        IPInput.delegate = ConnectViewController
        PortInput.delegate = ConnectViewController
        //ConnectConfirm.delegate = ConnectViewController
        
        ConnectConfirm.addTarget(ConnectViewController, action: #selector(ConnectViewController.newButtonAction), for: .touchUpInside)
        
        BtnRecord.addTarget(self, action: #selector(OnBeginRecord), for: .touchUpInside)
        BtnStopRecord.addTarget(self, action: #selector(OnStopRecord), for: .touchUpInside)
    }
    
    @objc func OnConfirmConnect() {
        print("select new button")
        let outSocket:OutSocket = OutSocket()
        outSocket.setupConnection{
            print("setupConnection")
        }


        let signal:Signal = Signal()
        outSocket.send(signal: signal)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // AR experiences typically involve moving the device without
        // touch input for some time, so prevent auto screen dimming.
        UIApplication.shared.isIdleTimerDisabled = true
        
        // "Reset" to run the AR session for the first time.
        resetTracking()
    }

    // MARK: - ARSessionDelegate

    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            self.displayErrorMessage(title: "The AR session failed.", message: errorMessage)
        }
    }
    
    /// - Tag: ARFaceTrackingSetup
    func resetTracking() {
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        configuration.worldAlignment = ARConfiguration.WorldAlignment.camera
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // MARK: - Error handling
    
    func displayErrorMessage(title: String, message: String) {
        // Present an alert informing about the error that has occurred.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.resetTracking()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension ViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let contentType = VirtualContentType(rawValue: item.tag)
            else { fatalError("unexpected virtual content tag") }
        
        selectedVirtualContent = contentType
    }
}

extension ViewController: ARSCNViewDelegate {
        
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        currentFaceAnchor = faceAnchor
        
        // If this is the first time with this anchor, get the controller to create content.
        // Otherwise (switching content), will change content when setting `selectedVirtualContent`.
        if node.childNodes.isEmpty, let contentNode = selectedContentController.renderer(renderer, nodeFor: faceAnchor) {
            node.addChildNode(contentNode)
        }
    }
    
    /// - Tag: ARFaceGeometryUpdate
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard anchor == currentFaceAnchor,
            let contentNode = selectedContentController.contentNode,
            contentNode.parent == node
            else { return }
        
        if let FaceAnchor = anchor as? ARFaceAnchor{
            AnchorController.UpdateAnchorValues(FaceAnchor)
            DispatchQueue.main.async {
                self.AnchorList.reloadData()
                self.AnchorList.layoutIfNeeded()
                //self.AnchorList.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            }
        }
        selectedContentController.renderer(renderer, didUpdate: contentNode, for: anchor)
    }
    
    @objc func OnBeginRecord() {
        
        BtnRecord.isHidden = true
        BtnStopRecord.isHidden = false
        ConnectViewController.BeginRecord()
    }
    
    @objc func OnStopRecord() {
        BtnRecord.isHidden = false
        BtnStopRecord.isHidden = true
        
        ConnectViewController.StopRecord()
    }
}



