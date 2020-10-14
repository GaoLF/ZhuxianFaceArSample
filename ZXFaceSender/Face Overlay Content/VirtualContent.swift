/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Manages virtual overlays diplayed on the face in the AR experience.
*/

import ARKit
import SceneKit

enum VirtualContentType: Int {
    case connectpc, texture, anchorlist, videoTexture
    
    func makeController() -> VirtualContentController {
        switch self {
        case .connectpc:
            return ConnectPC()
        case .texture:
            return TexturedFace()
        case .anchorlist:
            return AnchorList()
        case .videoTexture:
            return VideoTexturedFace()
        }
    }
}

/// For forwarding `ARSCNViewDelegate` messages to the object controlling the currently visible virtual content.
protocol VirtualContentController: ARSCNViewDelegate {
    /// The root node for the virtual content.
    var contentNode: SCNNode? { get set }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode?
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor)
    
    func ShowPrivateWindow()
}
