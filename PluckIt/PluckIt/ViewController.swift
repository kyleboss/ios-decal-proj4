//
//  ViewController.swift
//  PluckIt
//
//  Created by Kyle Boss on 11/15/15.
//  Copyright © 2015 Kyle Boss. All rights reserved.
//

import UIKit
import WatchConnectivity
import Accelerate

class ViewController: UIViewController, WCSessionDelegate {
    
    private var tuner: PitchDetector?
    private var appFileManager:NSFileManager? = NSFileManager()
    private var sharedFilePath:NSURL?
    private var sharedContainer:NSURL?
    var session : WCSession!
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    func session(session: WCSession, didReceiveFile file: WCSessionFile) {
        let checkValidation = NSFileManager.defaultManager()
        let noteName        = file.metadata!["note"] as! String
        let fileName        = getDocumentsDirectory().stringByAppendingPathComponent("tuner.wav")
        if (checkValidation.fileExistsAtPath(fileName))
        {
            try! checkValidation.removeItemAtPath(fileName)
        }
        try! checkValidation.copyItemAtPath(file.fileURL.path!, toPath: fileName)
            let coinSound = NSURL(fileURLWithPath: fileName)
            do{
                let audioPlayer = try AVAudioPlayer(contentsOfURL:coinSound)
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            }catch {
                NSLog("Error getting the audio file")
            }

        do {
            if (!checkValidation.fileExistsAtPath(fileName))
            {
                return
            }
            let attr : NSDictionary? = try! NSFileManager.defaultManager().attributesOfItemAtPath(fileName)
            
            if let _attr = attr {
                
                let fileURL:NSURL = NSURL(fileURLWithPath: fileName)
                let audioFile = try!  AVAudioFile(forReading: fileURL)
                let frameCount = UInt32(audioFile.length)
                
                let buffer = AVAudioPCMBuffer(PCMFormat: audioFile.processingFormat, frameCapacity: frameCount)
                do {
                    try audioFile.readIntoBuffer(buffer, frameCount:frameCount)
                } catch {
                    return
                }
                

                let log2n = UInt(round(log2(Double(frameCount))))
                
                let bufferSizePOT = Int(1 << log2n)
                
                // Set up the transform
                let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))
                
                // create packed real input
                var realp = [Float](count: bufferSizePOT/2, repeatedValue: 0)
                var imagp = [Float](count: bufferSizePOT/2, repeatedValue: 0)
                var output = DSPSplitComplex(realp: &realp, imagp: &imagp)
                
                vDSP_ctoz(UnsafePointer<DSPComplex>(buffer.floatChannelData.memory), 2, &output, 1, UInt(bufferSizePOT / 2))
                
                // Do the fast Fourier forward transform, packed input to packed output
                vDSP_fft_zrip(fftSetup, &output, 1, log2n, Int32(FFT_FORWARD))
                
                
                // you can calculate magnitude squared here, with care 
                // as the first result is wrong! read up on packed formats
                var fft = [Float](count:Int(bufferSizePOT / 2), repeatedValue:0.0)
                let bufferOver2: vDSP_Length = vDSP_Length(bufferSizePOT / 2)
                vDSP_zvmags(&output, 1, &fft, 1, bufferOver2)
                
                var spectrum = [Float]()
                var maxPart = 0;
                var maxPartMagnitude:Float = 0;
                var frequencies:[Float] = []
                for var i=1; i<bufferSizePOT/2; ++i {
                    let imag = output.imagp[i]
                    let real = output.realp[i]
                    frequencies.append(real)
                    let magnitude = sqrt(pow(real,2)+pow(imag,2))
                    if (magnitude > maxPartMagnitude) {
                        maxPartMagnitude = magnitude
                        maxPart = i;
                    }
                    spectrum.append(magnitude) }
                
                // Release the setup
                vDSP_destroy_fftsetup(fftSetup)
                let maxPartFft          = Float(maxPart)*(8000.0/Float(bufferSizePOT))
                let accuracy            = PitchDetector.displayNoteOf(maxPartFft, noteName: noteName)
                let applicationContext  = ["accuracy": accuracy, "noteName": noteName]
                do {
                    try session.updateApplicationContext(applicationContext as! [String : AnyObject])
                } catch {
                    
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        sharedContainer = appFileManager!.containerURLForSecurityApplicationGroupIdentifier("group.pluckit")
        sharedFilePath  = sharedContainer?.URLByAppendingPathComponent("tuner.wav")
        if (WCSession.isSupported()) {
            session             = WCSession.defaultSession()
            session.delegate    = self
            session.activateSession()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

