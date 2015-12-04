//
//  InterfaceController.swift
//  PluckIt WatchKit Extension
//
//  Created by Kyle Boss on 11/15/15.
//  Copyright © 2015 Kyle Boss. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class HomeController: WKInterfaceController, WCSessionDelegate {
    
    var sharedFilePath: NSURL?
    var appFileManager:NSFileManager? = NSFileManager.defaultManager()
    var sharedContainer:NSURL?
    var session: WCSession!
    @IBOutlet var instLabel: WKInterfaceLabel!
    @IBOutlet var eNoteLeft: WKInterfaceButton!
    @IBOutlet var eNote: WKInterfaceButton!
    @IBOutlet var dNote: WKInterfaceButton!
    @IBOutlet var aNote: WKInterfaceButton!
    @IBOutlet var gNote: WKInterfaceButton!
    @IBOutlet var bNote: WKInterfaceButton!
    
    @IBAction func tuneELeft() {
        recordAudio("Eb")
    }
    
    @IBAction func tuneD() {
        recordAudio("D")
    }
    
    @IBAction func tuneA() {
        recordAudio("A")
    }
    
    @IBAction func tuneG() {
        recordAudio("G")
    }
    
    @IBAction func tuneB() {
        recordAudio("B")
    }
    
    @IBAction func tuneE() {
        recordAudio("E")
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        sharedContainer = appFileManager!.containerURLForSecurityApplicationGroupIdentifier("group.pluckit")
        sharedFilePath  = sharedContainer?.URLByAppendingPathComponent("tuner.wav")
        instLabel.setText("Choose a String")
    }
    
    override func willActivate() {
        super.willActivate()
        
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
    }
    
    
    @IBAction func playAudio() {
        let options = [WKMediaPlayerControllerOptionsAutoplayKey : "true"]
        
        presentMediaPlayerControllerWithURL(sharedFilePath!, options: options,
            completion: { didPlayToEnd, endTime, error in
                if let err = error {
                    print(err.description)
                }
        })
    }
    
    
    func recordAudio(note: String) {
        let duration        = NSTimeInterval(5)
        let recordOptions   = [WKAudioRecorderControllerOptionsMaximumDurationKey : duration]
        presentAudioRecorderControllerWithOutputURL(sharedFilePath!,
            preset: .NarrowBandSpeech,
            options: recordOptions,
            completion: { saved, error in
                if let err = error {
                    NSLog(err.description)
                }
                if saved {

                    NSLog(String(self.sharedFilePath!))
                    do {
                        let attr : NSDictionary? = try NSFileManager.defaultManager().attributesOfItemAtPath(self.sharedFilePath!.path!)
                        
                        if let _attr = attr {
                            NSLog(String(_attr.fileSize()))
                        }
                    } catch {
                        print("Error: \(error)")
                    }
                    let metadata = ["note": note]
                    _ = WCSession.defaultSession().transferFile(self.sharedFilePath!, metadata: metadata)
                    self.instLabel.setText("Calculating...")
                }
        })
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        if (applicationContext["accuracy"] != nil) {
            let noteName    = applicationContext["noteName"] as! String
            let accuracy    = applicationContext["accuracy"] as! Int
            var absAccuracy = accuracy
            var instText    = ""
            if (accuracy == -1) {
                instLabel.setText("Try again.")
            } else {
                if (accuracy > 100) {
                    absAccuracy = 200 - absAccuracy
                }
                if (accuracy > 90 && accuracy < 110) {
                    instText = "Perfect!"
                } else if (accuracy < 100) {
                    instText = "Tighten String"
                } else {
                    instText = "Loosen String"
                }
                instText = instText + " " + noteName + ": " + String(absAccuracy) + "%"
                instLabel.setText(instText)
            }
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
