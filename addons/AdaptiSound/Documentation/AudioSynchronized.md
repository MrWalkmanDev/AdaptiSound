# AudioSynchronized
Inherits from the AdaptiNode class.

AudioSynchronized is a node that allows multiple tracks to play simultaneously in parallel. Each track is a layer and can be controlled individually.

To access this node, you must create a scene with the AudioSynchronized node and save it to the "Audio Scene Preload" directory in AudioPanel to preload the file.

It can also be loaded dynamically using the `AudioManager.load_audio_from_filepath()` or `AudioManager.load_audio_from_packedscene()` methods.
This way it will be uploaded to the audio pool, where it can be accessed with the **file name**, and the different playback methods in `AudioManager` can be used.

## General Properties
![img](https://i.imgur.com/zPxKe7k.png[/img])

This is the editor inspector view.

### Layers
All the audio files you want to have in this node are added to this array. Each layer is a resource of type `AdaptiLayerResource`, and has internal options to configure its playback behavior.

![img](https://i.imgur.com/rhWiQ0X.png[/img])

To configure the clips, it is recommended to use the `Audio Editor Preview` Panel; its operation will be explained later.

`Note`: `Audio Editor Preview` will only be visible when you have an AdaptiNode selected (AudioInteractivePlaylist or AudioSynchronized Node).

### Beat System Enabled
If true, allows counting the beats and bars of the entire track. Every time a bar counts, a signal called `BarChanged` is emited.
In the Beat System resource you can change the **BPM** and **Beats per bar** of the track.

### Editor Preview
This is a version of the `Audio Editor Preview` in inspector. It's recommended to disable it and use `Audio Panel Preview`.

## Audio Editor Preview

Having this node selected will allow you to access the `Audio Editor Preview` in the bottom panels.
![img](https://i.imgur.com/GPhIXYo.png[/img])

With this editor we can configure the clips and play them to check their operation.

To start we have this view:

![img](https://i.imgur.com/P2TsToz.png[/img])

At the top we have the following properties that will only affect **the editor playback**:

* `Volume_db`: Controls the track's volume **only in the editor**
* `Pitch_Scale`: Controls the pitch scale **only in the editor**
* `Fade_time`: Controls the time it takes for a track to fade in or out
* `Update Panel Button`: This button refreshes the panel. It's recommended to use when making multiple changes.

At the bottom we have the `Add Clip` button, which adds new clips to the node. editing the clips property.

### Beat System
From here you can edit the values ​​of the Beat System resource
* **BPM**:  
beats per minute, equals the pulse of the audio.
* **Beats per bar**: 
Defines how many beats fit into a single measure of music. It depends on the time signature (e.g., 4 beats per bar in 4/4). 

### Playback Buttons

**`Play button`**: Plays the track from the beginning, as if using `AudioManager.play_music` method.

**`Pause button`**: Stops the track and maintains its position. It is used only for editing purposes in the panel.

**`Stop button`**:  Stops playback and returns it to the beginning. It works as if using `AudioManager.stop_all`method with a fade time of 0.0.

## Layer Settings

The internal properties of each layer are described below.

![img](https://i.imgur.com/9YIDhqn.png[/img])

* **Layer Name**: 
Assign a name to the clip, with this name you can call the `change_clip` method in `AudioManager`.
* **Clip File**: 
Assigns the audio file to be played.

### Visual Player
* **Mute / Unmute Button**: 
This button is responsible for muting or unmuting the selected layer. You can adjust the fade time parameters at the top for a smoother transition.
* **Audio Slider**: 
There's a slider that scrolls through the clip's time. You can interact with this to play the track from a specific point using the Change Clip button.
* **Snap**: 
The audio slider control snaps to the clip grid or not. The value next to it is used to increase the subdivision of the grid.
* **Remove Clip**:
Removes the clip from the Clips Array.

## Signals
* **BeatChanged(Value)**: Emitted when a **beat** is received from the current playback clip. Value (int) is beat number in playback.
* **BarChanged(Value)**: Emitted when a **bar** is received from the current playback clip. Value (int) is bar number in playback.
* **LoopBegin**: Emitted when a track loop starts again.
