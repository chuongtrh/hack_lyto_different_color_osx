//
//  ViewController.swift
//  hackcolor
//
//  Created by Sam on 4/30/20.
//  Copyright © 2020 Sam. All rights reserved.
//

import Foundation
import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var ivCapture: NSImageView!
    @IBOutlet weak var lbCount: NSTextField!
    
    lazy var window: NSWindow = self.view.window!
    var timer:Timer?
    var numberClick:Int = 0
    var tempImage:NSImage?
    var clickPoints: [CGPoint] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear() {
        super.viewWillAppear()
    }
    
    @IBAction func clickStart(_ sender: Any) {
        print("Start")
        timer = Timer.scheduledTimer(timeInterval: 0.12, target: self, selector: #selector(self.onTimerTick), userInfo: nil, repeats: true)
    }
    @IBAction func clickStop(_ sender: Any) {
        print("Stop")
        timer?.invalidate()
        numberClick = 0
    }
    
    @objc func onTimerTick()
    {
        // Rect of game on screen
        let cropRect:CGRect = CGRect(x: 130, y: 555, width: 500, height: 500)
        let imageRef = CGDisplayCreateImage(CGMainDisplayID(), rect: cropRect)
        
        if let image = imageRef!.asNSImage() {
            
            let dict = OpenCVWrapper.hack(image)
            if let imageX = dict["image"] as? NSImage {
                DispatchQueue.main.async(execute: {
                    self.ivCapture.image = imageX
                    self.lbCount.stringValue = "\(self.numberClick+1)"
                })
            }
            
            let points = dict["points"] as! [[String:Int]]
            for temp in points {
                let x = temp["x"]!
                let y = temp["y"]!
                self.clickPoints.append(CGPoint(x:x, y:y))
            }
            
            
            if clickPoints.count > 0 {
                for (index, clickPoint) in clickPoints.enumerated() {
                    let click = CGPoint(x: cropRect.origin.x + clickPoint.x/2, y: cropRect.origin.y + clickPoint.y/2)
                    
                    print("click: \(numberClick) \(index) \(click)")
                    Mouse.click(position: click)
                }
                clickPoints.removeAll()
                numberClick+=1
            }
        }
    }
}
