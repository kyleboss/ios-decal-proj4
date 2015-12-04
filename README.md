# PluckIt

## Authors

* Kyle Boss

## Features

* Tune each guitar string individually with a one-screen experience on the Apple Watch

## Control Flow

* User brought to string where they can choose a string (with a skeuomorphic design of a guitar).
* User selects a string and is asked to pluck the string. 
* User plucks string and the Fast Fourier Transform mixed with the MPM algorithm is performed on the sound through the phone to detect frequency.
* The user is told whether to loosen or tighten the string if it is not tuned as well as the accuracy of the current tuning.
* Repeat process until all strings are tuned.

## Implementation

### Model

* PitchDetectory.swift

### Storyboard

* interface.storyboard

### Controller

* HomeController
