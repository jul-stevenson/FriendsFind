//
//  InterfaceController.swift
//  BoilerMake2015 Watch Extension
//
//  Created by Julianna Stevenson on 10/17/15.
//  Copyright © 2015 BoilerMake2015. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var textLabel: WKInterfaceLabel!
    @IBOutlet var arrowImage: WKInterfaceImage!
    
    var session : WCSession!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        print("session called")
        
        let image = message["image"] as? Int
        
        print(image)
        
        if image != -1 {
            textLabel.setHidden(true)
            arrowImage.setHidden(false)
        }
        switch image {
        case (-1)?:
            arrowImage.setHidden(true)
            textLabel.setHidden(false)
        case 0?:
            arrowImage.setImage(UIImage(named: "arrow0.png"))
        case 1?:
            arrowImage.setImage(UIImage(named: "arrow1.png"))
        case 2?:
            arrowImage.setImage(UIImage(named: "arrow2.png"))
        case 3?:
            arrowImage.setImage(UIImage(named: "arrow3.png"))
        case 4?:
            arrowImage.setImage(UIImage(named: "arrow4.png"))
        case 5?:
            arrowImage.setImage(UIImage(named: "arrow5.png"))
        case 6?:
            arrowImage.setImage(UIImage(named: "arrow6.png"))
        case 7?:
            arrowImage.setImage(UIImage(named: "arrow7.png"))
        case 8?:
            arrowImage.setImage(UIImage(named: "arrow8.png"))
        case 9?:
            arrowImage.setImage(UIImage(named: "arrow9.png"))
        case 10?:
            arrowImage.setImage(UIImage(named: "arrow10.png"))
        case 11?:
            arrowImage.setImage(UIImage(named: "arrow11.png"))
        case 12?:
            arrowImage.setImage(UIImage(named: "arrow12.png"))
        case 13?:
            arrowImage.setImage(UIImage(named: "arrow13.png"))
        case 14?:
            arrowImage.setImage(UIImage(named: "arrow14.png"))
        case 15?:
            arrowImage.setImage(UIImage(named: "arrow15.png"))
        default: break
        }
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        
    }

    override func willActivate() {
        super.willActivate()
        
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
