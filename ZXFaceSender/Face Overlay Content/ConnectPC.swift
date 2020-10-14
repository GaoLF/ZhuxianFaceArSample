/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Displays coordinate axes visualizing the tracked face pose (and eyes in iOS 12).
*/

import ARKit
import SceneKit
import CocoaAsyncSocket
/*
class InSocket: NSObject, GCDAsyncUdpSocketDelegate {
   //let IP = "10.123.45.2"
    let IP = "127.0.0.1"
    let PORT:UInt16 = 5001
    var socket:GCDAsyncUdpSocket!
    override init(){
        super.init()
        setupConnection()
    }
    func setupConnection(){
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue:DispatchQueue.main)
        //do { try socket.bind(toPort: PORT)} catch { print("")}
        do { try socket.enableBroadcast(true)} catch { print("not able to brad cast")}
        do { try socket.joinMulticastGroup(IP)} catch { print("joinMulticastGroup not procceed")}
        do { try socket.beginReceiving()} catch { print("beginReceiving not procceed")}
    }
    //MARK:-GCDAsyncUdpSocketDelegate
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
          print("incoming message: \(data)");
          let signal:Signal = Signal.unarchive(d: data)
          print("signal information : \n first \(signal.firstSignal) , second \(signal.secondSignal) \n third \(signal.thirdSignal) , fourth \(signal.fourthSignal)")

    }
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
    }

    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
    }
}
*/

class OutSocket: NSObject, GCDAsyncUdpSocketDelegate {
    //let IP = "127.0.0.1"
    let IP = "192.168.1.1"
    //let IP = "10.64.16.108"
    //let IP = "10.5.17.9"
    
    
    let PORT:UInt16 = 7982
    var socket:GCDAsyncUdpSocket!
    override init(){
        super.init()

    }
    func setupConnection(success:(()->())){
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue:DispatchQueue.main)
        //socket.setPreferIPv4()
        //socket.setIPv6Enabled(false)
        do { try socket.enableReusePort(true)} catch { print("can not reuse")}
        do { try socket.bind(toPort: PORT)} catch { print("")}
        do { try socket.connect(toHost:IP, onPort: PORT)} catch { print("joinMulticastGroup not procceed")}
        do { try socket.beginReceiving()} catch { print("beginReceiving not procceed")}
        //do { try socket.enableBroadcast(true)} catch { print("")}
        //do { try socket.joinMulticastGroup(IP)} catch { print("")}
         
        success()
    }
    func send(signal:Signal){
        let signalData = Signal.archive(w: signal)
        socket.send(signalData, withTimeout: -1, tag: 0)
    }
    //MARK:- GCDAsyncUdpSocketDelegate
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        print("didConnectToAddress");
    }
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        if let _error = error {
            print("didNotConnect \(_error )")
        }
    }
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        print("didNotSendDataWithTag")
        //setupConnection{
        //    print("setupConnection")
        //}
    }
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        print("didSendDataWithTag")
    }
}

class ConnectController: UIViewController, UITextFieldDelegate, GCDAsyncUdpSocketDelegate  {
    
    var outSocket : OutSocket!
    var SendFlag  : Float = 0.0
    var BeginTime : Double = 0.0
    var beginSend : Bool  = false
    
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
     
    open var AnchorDict : [String:String] = [:]
    var lock = NSLock()
    
    var headQuat:simd_quatf = simd_quatf()
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //inSocket = InSocket()
        outSocket = OutSocket()
        outSocket.setupConnection{
            print("setupConnection")
        }
    }
    
    func UpdateAnchorValues(_ Anchor:ARFaceAnchor) ->Void {
        lock.lock()
        AnchorDict.removeAll()
        
       // [ARFaceAnchor.BlendShapeLocation : NSNumber]
        
        //var AAA:[String] = []
        for (key, value) in Anchor.blendShapes {
            let temp1:String = String(key.rawValue)
            let temp2:String = String(value.floatValue)
            AnchorDict[temp1] = temp2
            //AAA.append(key.rawValue)
        }
        //AAA.sort()
        //var p:String = ""
        //for value in AAA
        //{
        //    p += value + " "
        //}
        //print(p)
        //simdconvertpos
        
        headQuat = simd_quatf(Anchor.transform)
       
        lock.unlock()
        
        var s: Signal = Signal()
        var values:[Float32] = [Float32]()
        
        for v in AnchorNames{
            
            let f = Float32(AnchorDict[v]!)
            //if values.count < 10
            //{
            values.append(f!)
            //}
        }
    
        
        values.append(headQuat.imag[0])
        values.append(headQuat.imag[1])
        values.append(headQuat.imag[2])
        values.append(headQuat.real)
        
        //56
        values.append(SendFlag)
        
        let nowtime = Double(Date().timeIntervalSince1970)
        //57
        var timestamp = Float(0.0)
        
        //sendflag=0,不发，=1 开始发，=2，持续发，=3停止发
        //sendflag == 0,不发送时间戳(发送0)
        if abs(SendFlag) < 0.001
        {
            values.append(timestamp)
        }
        //sendflag == 1,开始发送时间戳，时间戳置0
        else if abs(SendFlag - 1.0) < 0.001
        {
            BeginTime = nowtime
            values.append(timestamp)
            SendFlag = 2.0
        }
        else if abs(SendFlag - 2.0) < 0.001
        {
            timestamp = Float((nowtime - BeginTime))
            values.append(timestamp)
        }
        else if abs(SendFlag - 3.0) < 0.001
        {
            timestamp = Float((nowtime - BeginTime))
            values.append(timestamp)
            SendFlag = 0.0
        }
        
        /*
        values.append(Anchor.transform[0][0])
        values.append(Anchor.transform[0][1])
        values.append(Anchor.transform[0][2])
        values.append(Anchor.transform[0][3])
        values.append(Anchor.transform[1][0])
        values.append(Anchor.transform[1][1])
        values.append(Anchor.transform[1][2])
        values.append(Anchor.transform[1][3])
        values.append(Anchor.transform[2][0])
        values.append(Anchor.transform[2][1])
        values.append(Anchor.transform[2][2])
        values.append(Anchor.transform[2][3])
        values.append(Anchor.transform[3][0])
        values.append(Anchor.transform[3][1])
        values.append(Anchor.transform[3][2])
        values.append(Anchor.transform[3][3])
        */
        //print(Date().timeIntervalSince1970)
        //print(BeginTime)
        //print(timestamp)
        
        s.SetValues(values)
        
        
        self.outSocket.send(signal:s)
        
        let string = "1:" + String(headQuat.imag[0]) + "  2:" + String(headQuat.imag[1]) + "  3:" + String(headQuat.imag[2]) + "  4:" + String(headQuat.real)
        
       //let string = String(SendFlag)
        print(string)

    }
    
    func BeginRecord() ->Void {
        SendFlag = 1.0
    }
    func StopRecord() ->Void {
        SendFlag = 3.0
    }
    
    @IBAction func IPTextChanged(_ sender: Any) {
        //IP = Text
    }
    
    @IBAction func PortTextChanged(_ sender: Any) {
        
    }
    
    @objc func newButtonAction() {
        
        if beginSend == false {
            beginSend = true
            print("Begin to send")
            
            if outSocket == nil {
                outSocket = OutSocket()
                outSocket.setupConnection{
                }
            }
        }
        else{
            beginSend = false
            print("End to Send")
        }
    }
}

class ConnectPC: NSObject, VirtualContentController {
    
    var contentNode: SCNNode?
    weak var ConnectView: UIStackView!
    var connectController: ConnectController?
    
    weak var BtnBegin: UIButton!
    weak var BtnStop: UIButton!
    
    var IsSending:Bool = false
    
    func SetTrueConnectController(_ controller:ConnectController)->Void{
        connectController = controller
    }
    
    /// - Tag: ARNodeTracking
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
        guard connectController != nil else { return }
        if connectController?.beginSend == true{
            if let FaceAnchor = anchor as? ARFaceAnchor{
                connectController?.UpdateAnchorValues(FaceAnchor)
            }
            
            if IsSending == false{
                IsSending = true
               // BtnBegin.isHidden = false
                //BtnStop.isHidden  = true
            }
        }
        else{
            IsSending = false
            //BtnBegin.isHidden = true
            //BtnStop.isHidden  = true
        }
        
        guard let faceGeometry = node.geometry as? ARSCNFaceGeometry,
            let faceAnchor = anchor as? ARFaceAnchor
            else { return }
        
        faceGeometry.update(from: faceAnchor.geometry)
    }

    func SetStackUI(_ UI: UIStackView){
        ConnectView = UI
    }
    
    func ShowPrivateWindow(){
        ConnectView.isHidden = false
        BtnBegin.isHidden = false
        BtnStop.isHidden  = false
    }
    
    func SetBtnUI(_ begin:UIButton, stop:UIButton){
        BtnBegin = begin
        BtnStop  = stop
    }
}
