//
//  PitchDetector.swift
//  PluckIt
//
//  Created by Kyle Boss on 11/24/15.
//  Copyright © 2015 Kyle Boss. All rights reserved.


import Foundation

private let PITCH_LOW_LIMIT:Float   = 20.0;
private let PITCH_HIGH_LIMIT:Float  = 4200.0;
private let noteNames               = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "G#", "A", "Bb", "B"];
private let oct0:[Float]            = [16.35, 17.32, 18.35, 19.45, 20.60, 21.83, 23.12, 24.50, 25.96, 27.50, 29.14, 30.87];
private let oct1:[Float]            = [32.70, 34.65, 36.71, 38.89, 41.20, 43.65, 46.25, 49, 51.91, 55, 58.27, 61.74];
private let oct2:[Float]            = [65.41, 69.30, 73.42, 77.78, 82.41, 87.31, 92.50, 98, 103.8, 110, 116.5, 123.5];
private let oct3:[Float]            = [130.8, 138.6, 146.8, 155.6, 164.8, 174.6, 185.0, 196, 207.7, 220, 233.1, 246.9];
private let oct4:[Float]            = [261.6, 277.2, 293.7, 311.1, 329.6, 349.2, 370, 392, 415.3, 440, 466.2, 493.9];
private let oct5:[Float]            = [523.3, 554.4, 587.3, 622.3, 659.3, 698.5, 740, 784, 830.6, 880, 932.3, 987.8];
private let oct6:[Float]            = [1047, 1109, 1175, 1245, 1319, 1397, 1480, 1568, 1661, 1760, 1865, 1976];
private let oct7:[Float]            = [2093, 2217, 2349, 2489, 2637, 2794, 2960, 3136, 3322, 3520, 3729, 3951];
private let oct8:[Float]            = [4186, 4435, 4699, 4978, 5274, 5588, 5920, 6272, 6645, 7040, 7459, 7902];
private let notes                   = [oct0, oct1, oct2, oct3, oct4, oct5, oct6, oct7, oct8];
private let ALLOWABLE_ERROR:Float   = 1.2;

/**
 A Tuner uses the devices microphone and interprets the frequency, pitch, etc.
 */
public class PitchDetector: NSObject {
    
    private let threshold:Float
    private let microphone:AKMicrophone
    private let analyzer:AKAudioAnalyzer
    private var timer:NSTimer;
    
    /**
     Initializes a new Tuner.
     
     - parameter threshold: The minimum amplitude to recognize, must not be negative
     */
    public init(threshold: Float = 0.0) {
        self.threshold  = abs(threshold)
        microphone      = AKMicrophone()
        analyzer        = AKAudioAnalyzer(input: microphone.output)
        timer           = NSTimer()
        AKOrchestra.addInstrument(microphone)
        AKOrchestra.addInstrument(analyzer)
    }
    
    public func getPitch() {
        if self.analyzer.trackedAmplitude.value > self.threshold {
            print(String(PitchDetector.displayNoteOf(self.analyzer.trackedFrequency.value, noteName: "E")))
        }
    }
    
    /**
     Starts the tuner.
     */
    public func start() {
        AKSettings.shared().audioInputEnabled = true
        microphone.start()
        analyzer.start()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("getPitch:"), userInfo: nil, repeats: true)
    }
    
    /**
     Stops the tuner.
     */
    public func stop() {
        microphone.stop()
        analyzer.stop()
    }
    
    /**
        Get percent accuracy of a note given the pitch.
     */
    static func displayNoteOf(pitch: Float, noteName: String) -> Float {
        var percentCloseness:Float = 0.0;
        
        var comparisonOctave:[Float];
        var octave:[Float] = [];
        
        if ((pitch < PITCH_LOW_LIMIT) || (pitch > PITCH_HIGH_LIMIT)) {
            return -1;
        } else {
            for (var i = 0; i < notes.count; i++) {
                comparisonOctave = notes[i];
                if ((pitch > (comparisonOctave[0] - ALLOWABLE_ERROR)) &&
                    (pitch < (comparisonOctave[notes[i].count - 1] + ALLOWABLE_ERROR))) {
                        octave = comparisonOctave;
                        break;
                }
            }
        }
        var bestFitNoteIndex:Int    = -1;
        for (var i = 0; i < noteNames.count; i++) {
            if (noteNames[i] == noteName) {
                bestFitNoteIndex = i;
            }
        }
        if (octave.count == 0) {
            return -1
        }
        percentCloseness    = (pitch / octave[bestFitNoteIndex]) * 100;
        return percentCloseness;
    }
}