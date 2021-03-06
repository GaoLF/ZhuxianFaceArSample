# Tracking and Visualizing Faces


## 如何使用CocoaPods

下载与安装`udo gem install cocoapods`

进入工程目录，终端中输入`pod init`

然后会产生PodFile，按照github中的ReadMe文件填写

然后终端中输入`pod install`

## Adding libpcap to Xcode

The first thing that we need to do is add libpcap to our project. Whenever there is a project that you need to add libpcap to, you need to follow the steps mentioned here.

### Getting ready

We need to create an OS X project that we can add the libpcap library to.

### How to do it…

Once the project is created, we need to add the library to our project using these steps:

1. Select the project name from the project navigator area within your Xcode project.
2. Select the project name from the **TARGET** section.
3. Select the **Build Phases** tab and open the **Link Binary With Libraries** section.
4. Click on the **+** sign.
5. Type `libpcap` in the search box and select the **libpcap.dylib** library.![img](https://static.packt-cdn.com/products/9781849698085/graphics/8085OT_04_03.jpg)

Now that we have the library linked to the project, we need to set the application to run as root for debugging. To do so, follow these steps:

1. To run your project as root, navigate to **Product** | **Scheme** | **Edit Scheme** from the top menu as shown in the following screenshot:

   ![img](https://static.packt-cdn.com/products/9781849698085/graphics/8085OT_04_04.jpg)

2. In the window that opens up, change the Debug Process As selection from Me to root:![image-20191125151948349](/Users/perfect/Library/Application Support/typora-user-images/image-20191125151948349.png)

## Apple Swift version 4.2.1 Well Tested UDP Example

STEP 1 :- `pod 'CocoaAsyncSocket'`

STEP 2 :- `import CocoaAsyncSocket` in your `UIViewController`.

STEP 3 :- `UIViewController`

```swift
        import UIKit
import CocoaAsyncSocket

class ViewController: UIViewController {
    @IBOutlet weak var btnOnOff: LightButton!
    @IBOutlet weak var lblStatus: UILabel!
    var inSocket : InSocket!
    var outSocket : OutSocket!
    override func viewDidLoad() {
        super.viewDidLoad()
        lblStatus.isHidden = true
        inSocket = InSocket()
        outSocket = OutSocket()
        outSocket.setupConnection {
            self.lblStatus.isHidden = false
        }
    }
    @IBAction func btnLight(_ sender: Any) {
        let signal:Signal = Signal()
        self.outSocket.send(signal: signal)
    }
}
```

STEP 4 :- ***Reciving Socket\***

```swift
       //Reciving End...
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
        do { try socket.bind(toPort: PORT)} catch { print("")}
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
```

STEP 5 :- ***Sending Socket..\***

```swift
//Sending End...
class OutSocket: NSObject, GCDAsyncUdpSocketDelegate {
    // let IP = "10.123.45.1"
    let IP = "127.0.0.1"
    let PORT:UInt16 = 5001
    var socket:GCDAsyncUdpSocket!
    override init(){
        super.init()

    }
    func setupConnection(success:(()->())){
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue:DispatchQueue.main)
          do { try socket.bind(toPort: PORT)} catch { print("")}
          do { try socket.connect(toHost:IP, onPort: PORT)} catch { print("joinMulticastGroup not procceed")}
          do { try socket.beginReceiving()} catch { print("beginReceiving not procceed")}
        success()
    }
    func send(signal:Signal){
        let signalData = Signal.archive(w: signal)
        socket.send(signalData, withTimeout: 2, tag: 0)
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
    }
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        print("didSendDataWithTag")
    }
}
```

STEP 6 :- Your **Signal** Data which you will **Send/Recieve**

```swift
import Foundation
struct Signal {
    var firstSignal:UInt16 = 20
    var secondSignal:UInt16 = 30
    var thirdSignal: UInt16  = 40
    var fourthSignal: UInt16 = 50
    static func archive(w:Signal) -> Data {
        var fw = w
        return Data(bytes: &fw, count: MemoryLayout<Signal>.stride)
    }
    static func unarchive(d:Data) -> Signal {
        guard d.count == MemoryLayout<Signal>.stride else {
            fatalError("BOOM!")
        }
        var s:Signal?
        d.withUnsafeBytes({(bytes: UnsafePointer<Signal>)->Void in
            s = UnsafePointer<Signal>(bytes).pointee
        })
        return s!
    }
}
```



## swift显示规定格式的浮点数

```swift
import Foundation

extension Int {
    func format(f: String) -> String {
        return String(format: "%\(f)d", self)
    }
}

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

let someInt = 4, someIntFormat = "03"
println("The integer number \(someInt) formatted with \"\(someIntFormat)\" looks like \(someInt.format(someIntFormat))")
// The integer number 4 formatted with "03" looks like 004

let someDouble = 3.14159265359, someDoubleFormat = ".3"
println("The floating point number \(someDouble) formatted with \"\(someDoubleFormat)\" looks like \(someDouble.format(someDoubleFormat))")
// The floating point number 3.14159265359 formatted with ".3" looks like 3.142
```
## Socket Exampal 2

**Server.cpp**

```cpp
#include <stdio.h>   
#include <sys/types.h>   
#include <sys/socket.h>   
#include <netinet/in.h>   
#include <unistd.h>   
#include <errno.h>   
#include <string.h>   
#include <stdlib.h>   
  
#define SERV_PORT   8000   
  
int main()  
{  
  /* sock_fd --- socket文件描述符 创建udp套接字*/  
  int sock_fd = socket(AF_INET, SOCK_DGRAM, 0);
  if(sock_fd < 0)  
  {  
    perror("socket");  
    exit(1);  
  }  
  
  /* 将套接字和IP、端口绑定 */  
  struct sockaddr_in addr_serv;  
  int len;  
  memset(&addr_serv, 0, sizeof(struct sockaddr_in));  //每个字节都用0填充
  addr_serv.sin_family = AF_INET;  　　　　　　　　　　　 //使用IPV4地址
  addr_serv.sin_port = htons(SERV_PORT);  　　　　　　　 //端口
  /* INADDR_ANY表示不管是哪个网卡接收到数据，只要目的端口是SERV_PORT，就会被该应用程序接收到 */  
  addr_serv.sin_addr.s_addr = htonl(INADDR_ANY);  //自动获取IP地址
  len = sizeof(addr_serv);  
    
  /* 绑定socket */  
  if(bind(sock_fd, (struct sockaddr *)&addr_serv, sizeof(addr_serv)) < 0)  
  {  
    perror("bind error:");  
    exit(1);  
  }  
  
    
  int recv_num;  
  int send_num;  
  char send_buf[20] = "i am server!";  
  char recv_buf[20];  
  struct sockaddr_in addr_client;  
  
  while(1)  
  {  
    printf("server wait:\n");  
      
    recv_num = recvfrom(sock_fd, recv_buf, sizeof(recv_buf), 0, (struct sockaddr *)&addr_client, (socklen_t *)&len);  
      
    if(recv_num < 0)  
    {  
      perror("recvfrom error:");  
      exit(1);  
    }  
  
    recv_buf[recv_num] = '\0';  
    printf("server receive %d bytes: %s\n", recv_num, recv_buf);  
  
    send_num = sendto(sock_fd, send_buf, recv_num, 0, (struct sockaddr *)&addr_client, len);  
      
    if(send_num < 0)  
    {  
      perror("sendto error:");  
      exit(1);  
    }  
  }  
    
  close(sock_fd);  
    
  return 0;  
}
```

**Client.cpp**

```cpp
#include <stdio.h>   
#include <string.h>   
#include <errno.h>   
#include <stdlib.h>   
#include <unistd.h>   
#include <sys/types.h>   
#include <sys/socket.h>   
#include <netinet/in.h>   
#include <arpa/inet.h>   
   
  
#define DEST_PORT 8000   
#define DSET_IP_ADDRESS  "127.0.0.1"   
   
  
int main()  
{  
  /* socket文件描述符 */  
  int sock_fd;  
  
  /* 建立udp socket */  
  sock_fd = socket(AF_INET, SOCK_DGRAM, 0);  
  if(sock_fd < 0)  
  {  
    perror("socket");  
    exit(1);  
  }  
    
  /* 设置address */  
  struct sockaddr_in addr_serv;  
  int len;  
  memset(&addr_serv, 0, sizeof(addr_serv));  
  addr_serv.sin_family = AF_INET;  
  addr_serv.sin_addr.s_addr = inet_addr(DSET_IP_ADDRESS);  
  addr_serv.sin_port = htons(DEST_PORT);  
  len = sizeof(addr_serv);  
  
    
  int send_num;  
  int recv_num;  
  char send_buf[20] = "hey, who are you?";  
  char recv_buf[20];  
      
  printf("client send: %s\n", send_buf);  
    
  send_num = sendto(sock_fd, send_buf, strlen(send_buf), 0, (struct sockaddr *)&addr_serv, len);  
    
  if(send_num < 0)  
  {  
    perror("sendto error:");  
    exit(1);  
  }  
    
  recv_num = recvfrom(sock_fd, recv_buf, sizeof(recv_buf), 0, (struct sockaddr *)&addr_serv, (socklen_t *)&len);  
    
  if(recv_num < 0)  
  {  
    perror("recvfrom error:");  
    exit(1);  
  }  
    
  recv_buf[recv_num] = '\0';  
  printf("client receive %d bytes: %s\n", recv_num, recv_buf);  
    
  close(sock_fd);  
    
  return 0;  
}
```

UdpMessageMulticastSocket


------------------------------ the apple introduction



Detect faces in a camera feed, overlay matching virtual content, and animate facial expressions in real-time.    

## Overview

This sample app presents a simple interface allowing you to choose between five augmented reality (AR) visualizations on devices with a TrueDepth front-facing camera.

- An overlay of x/y/z axes indicating the ARKit coordinate system tracking the face (and in iOS 12, the position and orientation of each eye).
- The face mesh provided by ARKit, showing automatic estimation of the real-world directional lighting environment, as well as a texture you can use to map 2D imagery onto the face.
- Virtual 3D content that appears to attach to (and interact with) the user's real face.
- Live camera video texture-mapped onto the ARKit face mesh, with which you can create effects that appear to distort the user's real face in 3D. 
- A simple robot character whose facial expression animates to match that of the user, showing how to use ARKit's animation blend shape values to create experiences like the system Animoji app.

Use the tab bar to switch between these modes.

![Screenshot of UI for choosing AR face modes](Documentation/FaceExampleModes.png)

## Getting Started

This sample code project requires:

- An iOS device with front-facing TrueDepth camera:
    - iPhone X, iPhone XS, iPhone XS Max, or iPhone XR.
    - iPad Pro (11-inch) or iPad Pro (12.9-inch, 3rd generation).
- iOS 11.0 or later.
- Xcode 10.0 or later.

ARKit is not available in iOS Simulator.

## Start a Face-Tracking Session in a SceneKit View

Like other uses of ARKit, face tracking requires configuring and running a session (an [`ARSession`][0] object) and rendering the camera image together with virtual content in a view. This sample uses [`ARSCNView`][1] to display 3D content with SceneKit, but you can also use SpriteKit or build your own renderer using Metal (see [ARSKView][2] and [Displaying an AR Experience with Metal][3]).

[0]:https://developer.apple.com/documentation/arkit/arsession
[1]:https://developer.apple.com/documentation/arkit/arscnview
[2]:https://developer.apple.com/documentation/arkit/arskview
[3]:https://developer.apple.com/documentation/arkit/displaying_an_ar_experience_with_metal

Face tracking differs from other uses of ARKit in the class you use to configure the session. To enable face tracking, create an instance of [`ARFaceTrackingConfiguration`][5], configure its properties, and pass it to the [`run(_:options:)`][6] method of the AR session associated with your view, as shown here:

[5]:https://developer.apple.com/documentation/arkit/arfacetrackingconfiguration
[6]:https://developer.apple.com/documentation/arkit/arsession/2875735-run

``` swift
guard ARFaceTrackingConfiguration.isSupported else { return }
let configuration = ARFaceTrackingConfiguration()
configuration.isLightEstimationEnabled = true
sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
```
[View in Source](x-source-tag://ARFaceTrackingSetup)

Before offering features that require a face-tracking AR session, check the [`isSupported`][7] property on the [`ARFaceTrackingConfiguration`][5] class to determine whether the current device supports ARKit face tracking.

[7]:https://developer.apple.com/documentation/arkit/arconfiguration/2923553-issupported

## Track the Position and Orientation of a Face

When face tracking is active, ARKit automatically adds [`ARFaceAnchor`][10] objects to the running AR session, containing information about the user's face, including its position and orientation. (ARKit detects and provides information about only face at a time. If multiple faces are present in the camera image, ARKit chooses the largest or most clearly recognizable face.)

[10]:https://developer.apple.com/documentation/arkit/arfaceanchor

In a SceneKit-based AR experience, you can add 3D content corresponding to a face anchor in the [`renderer(_:nodeFor:)`][11] or [`renderer(_:didAdd:for:)`][12] delegate method. ARKit manages a SceneKit node for the anchor, and updates that node's position and orientation on each frame, so any SceneKit content you add to that node automatically follows the position and orientation of the user's face. 

[11]:https://developer.apple.com/documentation/arkit/arscnviewdelegate/2865801-renderer
[12]:https://developer.apple.com/documentation/arkit/arscnviewdelegate/2865794-renderer

``` swift
func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
    // This class adds AR content only for face anchors.
    guard anchor is ARFaceAnchor else { return nil }
    
    // Load an asset from the app bundle to provide visual content for the anchor.
    contentNode = SCNReferenceNode(named: "coordinateOrigin")
    
    // Add content for eye tracking in iOS 12.
    self.addEyeTransformNodes()
    
    // Provide the node to ARKit for keeping in sync with the face anchor.
    return contentNode
}
```
[View in Source](x-source-tag://ARNodeTracking)

This example uses a convenience extension on [`SCNReferenceNode`][13] to load content from an `.scn` file in the app bundle. The [`renderer(_:nodeFor:)`][1] method provides that node to [`ARSCNView`][1], allowing ARKit to automatically adjust the node's position and orientation to match the tracked face.

[13]:https://developer.apple.com/documentation/scenekit/scnreferencenode

## Use Face Geometry to Model the User's Face

ARKit provides a coarse 3D mesh geometry matching the size, shape, topology, and current facial expression of the user's face. ARKit also provides the [`ARSCNFaceGeometry`][20] class, offering an easy way to visualize this mesh in SceneKit.

[20]:https://developer.apple.com/documentation/arkit/arscnfacegeometry

Your AR experience can use this mesh to place or draw content that appears to attach to the face. For example, by applying a semitransparent texture to this geometry you could paint virtual tattoos or makeup onto the user's skin.

To create a SceneKit face geometry, initialize an [`ARSCNFaceGeometry`][20] object with the Metal device your SceneKit view uses for rendering, and assign that geometry to the SceneKit node tracking the face anchor.

``` swift
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
```
[View in Source](x-source-tag://CreateARSCNFaceGeometry)

- Note: This example uses a texture with transparency to create the illusion of colorful grid lines painted onto a real face. You can use the `wireframeTexture.png` image included with this sample code project as a starting point to design your own face textures.

ARKit updates its face mesh conform to the shape of the user's face, even as the user blinks, talks, and makes various expressions. To make the displayed face model follow the user's expressions, retrieve an updated face meshes in the [`renderer(_:didUpdate:for:)`][21] delegate callback, then update the [`ARSCNFaceGeometry`][20] object in your scene to match by passing the new face mesh to its [`update(from:)`][22] method:

[21]:https://developer.apple.com/documentation/arkit/arscnviewdelegate/2865799-renderer
[22]:https://developer.apple.com/documentation/arkit/arscnfacegeometry/2928196-update

``` swift
func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    guard let faceGeometry = node.geometry as? ARSCNFaceGeometry,
        let faceAnchor = anchor as? ARFaceAnchor
        else { return }
    
    faceGeometry.update(from: faceAnchor.geometry)
}
```
[View in Source](x-source-tag://ARFaceGeometryUpdate)

## Place 3D Content on the User's Face

Another use of the face mesh that ARKit provides is to create *occlusion geometry* in your scene. An occlusion geometry is a 3D model that doesn't render any visible content (allowing the camera image to show through), but obstructs the camera's view of other virtual content in the scene. 

This technique creates the illusion that the real face interacts with virtual objects, even though the face is a 2D camera image and the virtual content is a rendered 3D object. For example, if you place an occlusion geometry and virtual glasses on the user's face, the face can obscure the frame of the glasses.

To create an occlusion geometry for the face, start by creating an [`ARSCNFaceGeometry`][20] object as in the previous example. However, instead of configuring that object's SceneKit material with a visible appearance, set the material to render depth but not color during rendering:

``` swift
let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!)!
faceGeometry.firstMaterial!.colorBufferWriteMask = []
occlusionNode = SCNNode(geometry: faceGeometry)
occlusionNode.renderingOrder = -1
```
[View in Source](x-source-tag://OcclusionMaterial)

Because the material renders depth, other objects rendered by SceneKit correctly appear in front of it or behind it. But because the material doesn't render color, the camera image appears in its place. 

The sample app combines this technique with a SceneKit object positioned in front of the user's eyes, creating an effect where the user's nose realistically obscures the object. This object uses physically-based materials, so it automatically benefits from the real-time directional lighting information that [`ARFaceTrackingConfiguration`][5] provides.

- Note: The `ARFaceGeometry.obj` file included in this sample project represents ARKit's face geometry in a neutral pose. You can use this as a template to design your own 3D art assets for placement on a real face. 

## Map Camera Video onto 3D Face Geometry

For additional creative uses of face tracking, you can texture-map the live 2D video feed from the camera onto the 3D geometry that ARKit provides. After mapping pixels in the camera video onto the corresponding points on ARKit's face mesh, you can modify that mesh, creating illusions such as resizing or distorting the user's face in 3D.

First, create an [`ARSCNFaceGeometry`][20] for the face and assign the camera image to its main material. [`ARSCNView`][1] automatically sets the scene's [`background`][40] material to use the live video feed from the camera, so you can set the geometry to use the same material.

[40]:https://developer.apple.com/documentation/scenekit/scnscene/1523665-background

``` swift
// Show video texture as the diffuse material and disable lighting.
let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!, fillMesh: true)!
let material = faceGeometry.firstMaterial!
material.diffuse.contents = sceneView.scene.background.contents
material.lightingModel = .constant
```
[View in Source](x-source-tag://VideoTexturedFace)

To correctly align the camera image to the face, you'll also need to modify the texture coordinates that SceneKit uses for rendering the image on the geometry. One easy way to perform this mapping is with a SceneKit shader modifier (see the [`SCNShadable`][41] protocol). The shader code here applies the coordinate system transformations needed to convert each vertex position in the mesh from 3D scene space to the 2D image space used by the video texture: 

[41]:https://developer.apple.com/documentation/scenekit/scnshadable

``` metal
// Transform the vertex to the camera coordinate system.
float4 vertexCamera = scn_node.modelViewTransform * _geometry.position;

// Camera projection and perspective divide to get normalized viewport coordinates (clip space).
float4 vertexClipSpace = scn_frame.projectionTransform * vertexCamera;
vertexClipSpace /= vertexClipSpace.w;

// XY in clip space is [-1,1]x[-1,1], so adjust to UV texture coordinates: [0,1]x[0,1].
// Image coordinates are Y-flipped (upper-left origin).
float4 vertexImageSpace = float4(vertexClipSpace.xy * 0.5 + 0.5, 0.0, 1.0);
vertexImageSpace.y = 1.0 - vertexImageSpace.y;

// Apply ARKit's display transform (device orientation * front-facing camera flip).
float4 transformedVertex = displayTransform * vertexImageSpace;

// Output as texture coordinates for use in later rendering stages.
_geometry.texcoords[0] = transformedVertex.xy;
```

When you assign a shader code string to the [`geometry`][42] entry point, SceneKit configures its renderer to automatically run that code on the GPU for each vertex in the mesh. This shader code also needs to know the intended orientation for the camera image, so the sample gets that from the ARKit [`displayTransform(for:viewportSize:)`][43] method and passes it to the shader's `displayTransform` argument:

[42]:https://developer.apple.com/documentation/scenekit/scnshadermodifierentrypoint/1524108-geometry
[43]:https://developer.apple.com/documentation/arkit/arframe/2923543-displaytransform

``` swift
// Pass view-appropriate image transform to the shader modifier so
// that the mapped video lines up correctly with the background video.
let affineTransform = frame.displayTransform(for: .portrait, viewportSize: sceneView.bounds.size)
let transform = SCNMatrix4(affineTransform)
faceGeometry.setValue(SCNMatrix4Invert(transform), forKey: "displayTransform")
```
[View in Source](x-source-tag://VideoTexturedFace)

- Note: This example's shader modifier also applies a constant scale factor to all vertices, causing the user's face to appear larger than life. Try other transformations to distort the face in other ways.

## Animate a Character with Blend Shapes

In addition to the face mesh shown in the earlier examples, ARKit also provides a more abstract representation of the user's facial expressions. You can use this representation (called *blend shapes*) to control animation parameters for your own 2D or 3D assets, creating a character that follows the user's real facial movements and expressions. 

As a basic demonstration of blend shape animation, this sample includes a simple model of a robot character's head, created using SceneKit primitive shapes. (See the `robotHead.scn` file in the source code.) 

To get the user's current facial expression, read the [`blendShapes`][50] dictionary from the face anchor in the [`renderer(_:didUpdate:for:)`][21] delegate callback. Then, examine the key-value pairs in that dictionary to calculate animation parameters for your 3D content and update that content accordingly. 

[50]:https://developer.apple.com/documentation/arkit/arfaceanchor/2928251-blendshapes

``` swift
let blendShapes = faceAnchor.blendShapes
guard let eyeBlinkLeft = blendShapes[.eyeBlinkLeft] as? Float,
    let eyeBlinkRight = blendShapes[.eyeBlinkRight] as? Float,
    let jawOpen = blendShapes[.jawOpen] as? Float
    else { return }
eyeLeftNode.scale.z = 1 - eyeBlinkLeft
eyeRightNode.scale.z = 1 - eyeBlinkRight
jawNode.position.y = originalJawY - jawHeight * jawOpen
```
[View in Source](x-source-tag://BlendShapeAnimation)

There are more than 50 unique [`ARFaceAnchor.BlendShapeLocation`][51] coefficients, of which your app can use as few or as many as necessary to create the artistic effect you want. In this sample, the [`BlendShapeCharacter`](x-source-tag://BlendShapeCharacter) class performs this calculation, mapping the [`eyeBlinkLeft`][52] and [`eyeBlinkRight`][53] parameters to one axis of the [`scale`][54] factor of the robot's eyes, and the [`jawOpen`][55] parameter to offset the position of the robot's jaw.

[51]:https://developer.apple.com/documentation/arkit/arfaceanchor/blendshapelocation
[52]:https://developer.apple.com/documentation/arkit/arfaceanchor/blendshapelocation/2928261-eyeblinkleft
[53]:https://developer.apple.com/documentation/arkit/arfaceanchor/blendshapelocation/2928262-eyeblinkright
[54]:https://developer.apple.com/documentation/scenekit/scnnode/1408050-scale
[55]:https://developer.apple.com/documentation/arkit/arfaceanchor/blendshapelocation/2928236-jawopen

