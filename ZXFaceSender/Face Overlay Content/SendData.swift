//
//  SendData.swift
//  ARKitFaceExample
//
//  Created by Perfect on 2019/12/3.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation

struct Signal {
    var Signals = [Float32](repeating: 0.0, count: 10)
    
    mutating func SetValues(_ values:[Float])->Void{
        Signals.removeAll()
        for value in values{
            Signals.append(value)
        }
    }
    
    static func archive(w:Signal) -> Data {
        var data:Data = Data()
        for value in w.Signals{
            var fw = value
                data += Data(bytes: &fw, count: MemoryLayout<Float32>.stride)
        }
        return data
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
