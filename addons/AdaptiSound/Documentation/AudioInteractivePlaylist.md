# AudioInteractivePlaylist

Inherits from the AdaptiNode class.

AudioInteractivePlaylist is a node that allows you to arrange multiple audio clips in a playlist, with only one clip playing at a time.
Each clip has adjustable parameters, allowing for different behaviors.

To access this node, you must create a scene with the AudioInteractivePlaylist node and save it to the "Audio Scene Preload" directory in AudioPanel to preload the file.

It can also be loaded dynamically using the `AudioManager.load_audio_from_filepath()` or `AudioManager.load_audio_from_packedscene()` methods.
This way it will be uploaded to the audio pool, where it can be accessed with the **file name**, and the different playback methods in `AudioManager` can be used.

## General Properties
![img](https://i.imgur.com/SWQDtvp.png[/img])

This is the editor inspector view.

### Clips
All the audio clips you want to have in this node are added to this array. Each clip is a resource of type `AdaptiClipResource`, and has internal options to configure its playback behavior.

![img](https://i.imgur.com/AaB9nzS.png[/img])

To configure the clips, it is recommended to use the `Audio Editor Preview` Panel; its operation will be explained later.

`Note`: `Audio Editor Preview` will only be visible when you have an AdaptiNode selected (AudioInteractivePlaylist or AudioSynchronized Node).

### Initial Clips

This property selects the audio clip that will be played first, using the `AudioManager.play_music` method

### Shuffle Playback

If true, changes the `advance_type` property of all clips to Random **Auto-advance**. All clips will play once and then randomly switch to another clip.

## Audio Editor Preview

Having this node selected will allow you to access the `Audio Editor Preview` in the bottom panels.
![img](https://i.imgur.com/GPhIXYo.png[/img])

With this editor we can configure the clips and play them to check their operation.

To start we have this view:

![img](https://i.imgur.com/G8hi8gc.png[/img])

At the top we have the following properties that will only affect **the editor playback**:

* `Volume_db`: Controls the track's volume **only in the editor**
* `Pitch_Scale`: Controls the pitch scale **only in the editor**
* `Fade_in_time`: Controls the fade-in time of a clip when switching to another. 
* `Fade_out_time`: Controls the fade-out time of a clip when switching to another. 
* `Update Panel Button`: This button refreshes the panel. It's recommended to use when making multiple changes.

`Shuffle playback` and `Initial clip` change the properties previously seen in this document, and these changes affect **editor** and **runtime** playback.

At the bottom we have the `Add Clip` button, which adds new clips to the node. editing the clips property.

### Playback Buttons

**`Play button`**: Plays the track from the beginning, as if using `AudioManager.play_music` method.

**`Pause button`**: Stops the track and maintains its position. It is used only for editing purposes in the panel.

**`Stop button`**:  Stops playback and returns it to the beginning. It works as if using `AudioManager.stop_all`method with a fade time of 0.0.

## Clip Settings

The internal properties of each clip are described below.

![img](https://i.imgur.com/W9GJQZK.png[/img])

* **Clip Name**: 
Assign a name to the clip, with this name you can call the `change_clip` method in `AudioManager`.
* **Clip File**: 
Assigns the audio file to be played.
* **Advance Type**: Select the type of track advance
	* **Loop**: It plays in a loop from the beginning continuously until changing to another clip.
	* **Auto-Advance**: At the end it automatically switches to another clip. Select the target 		clip in the `Next Clip` property

		![img](https://i.imgur.com/CfZbAbH.png[/img])

	* **Once**: It only plays once, if there are no more clips playing the track will stop.

* **Next Clip**: 
Select the target clip to switch to. Only works if the `advance type` is **Auto-Advance**.

* **Can be Interrupted**: 
If true, this option allows you to change clips while they're playing; if false, you won't be able to change them until they've finished playing. It's recommended to set this option to false if your clip is a `advance type` **Once**, essentially a clip that ends playback of the entire track.
`Note`: Even if it is false you can still switch between general tracks (`AudioManager.play_music`), it only disabled changes to internal clips of the node.

### Visual Player
* **Play / Change Clip Button**: 
This button plays the selected clip, and if a clip is playing previously, it will switch to the next one. You can adjust the fade time parameters at the top for a smoother transition.
* **Audio Slider**: 
There's a slider that scrolls through the clip's time. You can interact with this to play the track from a specific point using the Change Clip button.

### BeatCount System
Each clip has an internal beat and bar counting system, allowing you to execute functions at a specific point in the clip.
For it to work correctly it is necessary to set the following parameters:

* **BPM**:  
beats per minute, equals the pulse of the audio.
* **Beats per bar**: 
Defines how many beats fit into a single measure of music. It depends on the time signature (e.g., 4 beats per bar in 4/4). 

By setting these options and update panel you will see a grid on the clip.

### Transition Keys
Transition keys are points in the audio where you can change clips.
If the track doesn't have any transition keys, then the change will be immediate, but if the track has at least one transition key, then the track will make the change once it passes through one of these keys.

Transition keys can be added manually by clicking on the grid lines, or by using the `All Keys` button to select all bars, or `None Key` to clear the keys.

![img](https://i.imgur.com/1jQk2hd.png[/img])

Finally, we have the buttons at the bottom:
* **Snap**: 
The audio slider control snaps to the clip grid or not. The value next to it is used to increase the subdivision of the grid.
* **Remove Clip**:
Removes the clip from the Clips Array.

## Signals
* **ClipChanged(Value)**: Emitted when the playback of a clip has been changed. Value (AdaptiClipResource) is the new clip that is played.
* **BeatChanged(Value)**: Emitted when a **beat** is received from the current playback clip. Value (int) is beat number in playback.
* **BarChanged(Value)**: Emitted when a **bar** is received from the current playback clip. Value (int) is bar number in playback.
* **LoopBegin**: Emitted when a clip loop starts again.
