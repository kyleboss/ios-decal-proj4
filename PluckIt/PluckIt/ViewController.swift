//
//  ViewController.swift
//  PluckIt
//
//  Created by Kyle Boss on 11/15/15.
//  Copyright © 2015 Kyle Boss. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let instrument = AKInstrument()
        instrument.setAudioOutput(AKOscillator())
        AKOrchestra.addInstrument(instrument)
        instrument.play()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

