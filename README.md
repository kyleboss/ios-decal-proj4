# PluckIt

## Authors

* Kyle Boss

## Features

* Tune each guitar string individually.
* Keep beat with a metronome.

## Control Flow

* User brought to a splash screen that has two options: "Tune Me" or "Keep a beat". 
* User selects "Tune Me" and is brought to a string where they can choose a string (with a skeuomorphic design of a guitar).
* User selects a string and is brought to a screen that demands that they pluck the respective string. 
* User plucks string and the Fast Fourier Transform is performed on the sound to detect frequency.
* The user is told whether to loosen or tighten the string if it is not tuned.
* Repeat process until all strings are tuned.
* User then goes back to splash screen and selects "Keep a beat"
* User is brought to a screen with just a Start button and an input for BPM.
* User changes BPM and selects START. The start button changes to stop and the phone will vibrate x beats per minute.
* User presses stop to stop the metronome.

## Implementation

### Model

* String.swift
* Metronome.swift

### View

* SplashUiView
* StringSelectionUIView
* TuningFeedbackUIView
* MetronomeUIView

### Controller

* SplashUiViewController
* StringSelectionUIViewController
* TuningFeedbackUIViewController
* MetronomeUIViewController
