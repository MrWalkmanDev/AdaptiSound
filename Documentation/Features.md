# Features

## Main Panel

![Imgur](https://i.imgur.com/ue4WQfU.png)

The `Main Panel` will help you organize the audio files in your project.
You can separate the music into 3 different categories:
- `BGM` (Background Music)
- `ABGM` (Adaptive Background Music)
- `BGS` (Background Sounds)

### **Audio Directories**

![Imgur](https://i.imgur.com/GDCFHb8.png)

You will have to assign a directory for each category, `Main Panel` will look in all the subfolders for audio files with the extensions selected in **Audio Extensions**.
With the *search* button you can view the files found in the directories.

*`Note`: ABGM will search only .tscn files, as it will use only the scenes created with AdaptiveTrack, or ParallelTrack*

### **Audio Bus**

![Imgur](https://i.imgur.com/eQ1QWgm.png)

Here you can assign an audio *BUS* for each category. This will help with later in-game audio volume management.

### **Debug and ABGS Support**

![Imgur](https://i.imgur.com/gtskvKC.png)

- `Debugging`: You will be able to see the plugin's operation in the output panel.
- `ABGS Support`: It will allow you to add scenes with AdaptiveTrack or ParallelTrack nodes in the BGS category.

## **Save Button** 
you must use this button to save any changes you make in the main panel.
![Imgur](https://i.imgur.com/pAEEVqe.png)


## AudioManager Singleton

This tool is designed with the objective of implementing global background music and/or sounds. `AudioManager` will only play a single `BGM` or `ABGM` track, and in parallel one of `BGS`.

- The `current_playback` variable stores the only currently playing BGM or ABGM.
- The `current_bgs_playback` variable stores the only current playback of the BGS.

![Imgur](https://i.imgur.com/X41Xw0x.png)

`AudioManager` will automatically preload audio files for when `playback methods` are called.

*Only add_track method and play_music method add an instance to the `AudioManager` tree in the container with its category.*

## Playback Methods

### `play_music` 
<sub>Only for BGM/ABGM</sub>

![Imgur](https://i.imgur.com/1NKMCrg.png)

This method will play from the beginning the audio with the name assigned in *sound_name*. If there is already an audio being played, it will replace it, unless it is the same one, in which case, it will continue the current playback.

- `sound_name:` type `String`, `AudioManager` will look for the preloaded sounds and play audio with this name.
- ~~volume_db: type Float, set volume in dB of the track when played. 0.0 default~~ To manage the volume you will have to use the `set_volume_db` function. see [Setters and Getters](https://github.com/MrWalkmanDev/AdaptiSound/blob/main/Documentation/Features.md#setters--getters)
- `fade_in:` `Float`, set the fade time when the track is played. `0.5 default`
- `fade_out:` type `Float`, set the fade time when the current playback out. `1.5 default`
- `skip_intro:` **only for AdaptiveTrack**, type `Bool`, if true, play the loop directly. `false default`
- `loop_index:` **only for AdaptiveTrack**, type `Int`, sets the index of the loop to be played after the intro. `0 default`


### `reset_music` 
<sub>Only for BGM/ABGM</sub>

![Imgur](https://i.imgur.com/PvFIyCe.png)

This method returns the currently playing track to the beginning.
- `fade_out:` type `Float`, set the fade time when the current playback out. `0.0 default`
- `fade_in:` type `Float`, set the fade time when the track is played. `0.0 default`


### `stop_music` 
<sub>Only for BGM/ABGM</sub>

![Imgur](https://i.imgur.com/h5yE4sL.png)

This method stops the current playback.
- `can_fade:` type `Bool`, if true, apply fade_out on current playback track. `false default`
- `fade_out:` type `Float`, set the fade time when the current playback out. `1.5 default`


### `change_loop` 
<sub>Only for ABGM</sub>

![Imgur](https://i.imgur.com/q8LL0bG.png)

- `sound_name:` type `String`, name of the AdaptiveTrack on which the playing `Loop` will be changed.
- `loop_by_index:` type `Int`, loop index to play.
- `can_fade:` type `Bool`, if true, tracks will change with fades. `false default`
- `fade_in:` type `Float`, time of fade in. `0.5 default`
- `fade_out:` type `Float`, time of fade out. `1.5 default`

### `to_outro` 
<sub>Only for ABGM</sub>

![Imgur](https://i.imgur.com/Iqv62Hg.png)

- `sound_name:` type `String`, name of the AdaptiveTrack in which to switch to the `Outro`
- `can_fade:` type `Bool`, if true, tracks will change with fades. `false default`
- `fade_out:` type `Float`, time of fade out. `1.5 default`
- `fade_in:` type `Float`, time of fade in. `0.5 default`

### `mute_layer` 
<sub>Only for ABGM</sub>

![Imgur](https://i.imgur.com/lOTRekw.png)

- `track_name:` type `String`, name of the ParallelTrack in which the layers will be muted or unmuted.
- `layer_names:` type `Array`, names, groups, or indexes of the layers to be unheard.
- `fade_time:` type `Float`, time of fade in. `2.0 default`

### `play_layer`
<sub>Only for ABGM</sub>

![Imgur](https://i.imgur.com/Fmz0ZTI.png)

- `track_name:` type `String`, name of the track that contains the layers to play.
- `layer_names:` type `Array`, names, groups, or indices of trigger layers to play.
- `can_fade:` type `Bool`, if true, tracks will play with fade in. `false default`
- `fade_time:` type `Float`, time of fade in. `3.0 default`

### `stop_layer`
<sub>Only for ABGM</sub>

- `track_name:` type `String`, name of the track that contains the layers to stop.
- `layer_names:` type `Array`, names, groups, or indices of trigger layers to stop.
- `can_fade:` type `Bool`, if true, tracks will play with fade out. `false default`
- `fade_time:` type `Float`, time of fade out. `3.0 default`

### `stop_all` 
<sub>For All</sub>

![Imgur](https://i.imgur.com/sKLJbHk.png)

This method stops all currently playing BGM/ABGM and BGS tracks, and removes them from the tree.
- `type:` type `String`, set a specific category you want to stop. `"all" default`
- `fade_out:` type `Float`, set the fade time when the current playback out. `1.5 default`
- `can_destroy:` type `Bool`, if true, all tracks removes from the tree. `true default`


### `play_sound`
<sub>Only for BGS</sub>

![Imgur](https://i.imgur.com/Fqplyxs.png)

This method will play from the beginning the audio with the name assigned in *sound_name*. If there is already an audio being played, it will replace it, unless it is the same one, in which case, it will continue the BGS current playback.

- `sound_name:` type `String`, `AudioManager` will look for the preloaded sounds and play audio with this name.
- `fade_in:` type `Float`, set the fade time when the track is played. `0.5 default`
- `fade_out:` type `Float`, set the fade time when the current playback out. `1.5 default`

### `stop_sound`
<sub>Only for BGS</sub>

![Imgur](https://i.imgur.com/ShLqw4z.png)

This method stops the BGS current playback.
- `can_fade:` type `Bool`, if true, apply fade_out on BGS current playback track. `false default`
- `fade_out:` type `Float`, set the fade time when the BGS current playback out. `1.5 default`

### `mute_bgs_layer`

![Imgur](https://i.imgur.com/tSK7l9p.png)

- `track_name:` type `String`, name of the ParallelTrack in which the layers will be muted or unmuted.
- `layer_names:` type `Array`, names, groups, or indexes of the layers to be unheard.
- `fade_time:` type `Float`, time of fade in. `2.0 default`


## AdaptiNodes

To add adaptive music to our project we can use the AdaptiNodes. The objective of these nodes is to create a single track that contains several audio tracks and a certain structure to be played.

### ParallelTrack & ParallelLayer

The main function of `ParallelTrack` is to play multiple tracks at the same time, and with methods called from `AudioManager` control the different layers.
To get started, you'll need to add a `ParallelLayer` node to the parent node.

![Imgur](https://i.imgur.com/Otz3qC7.png)

You can rename the layers so that later it is easier to manage them. Each ParallelLayer can contain multiple tracks, and all tracks will play together when the layer they belong to is activated.

For example we can have the following structure:
- (ParallelLayer)Base: contains drum and bass tracks
- (ParallelLayer)Top: contains melodic tracks

![Imgur](https://i.imgur.com/vkvvqmN.png)

`ParallelLayer` has the following properties:

- `playing_type:` if `Always`, will play when calling `play_music`, and it will always be activated unless stopped with `stop_music`, if `Trigger` it will only be activated when calling the `play_layer` method.

Note: `Always` plays from the start, but it won't necessarily be listening. for is the `layer_on` property.

- `audio_stream:` here you add the audio tracks that will be activated with this layer.
- `layer_on:` if true, then the layer will be listenning from the beginning, when called by `play_music`.
- `loop:` if true, the layer will play in a loop.
- `Groups:` you can assign custom groups to each layer, and then call them with the `mute_layer` method.

![Imgur](https://i.imgur.com/Ka5jHfO.png)

The objective of this structure is that all the layers of type `Always` are playing in parallel, and with the `mute_layer` method they are muted or unmuted.


### AdaptiTrack

The `AdaptiveTrack` node was replaced by `AdaptiTrack`, a more complete node with new features.

The main function of `AdaptiTrack` is to reproduce the following structure:

| Intro | Loops | Outro |
| ----- | ----- | ----- |
- `Intro:` It is a track that plays only once, and can only be stopped with a track change (`play_music`), or with the `stop_music` method.
- `Loops:` These tracks will play in a loop, but only one track will play at a time, to change from one loop to another you must call the `change_loop` method.
- `Outro:` This track will play only once, and can only be interrupted by the `change_loop`, or `stop_music` method. to go from the loops section to the outro you must call `to_outro` method.

![Imgur](https://i.imgur.com/hDHQcdX.png)

AdaptiTrack properties
- `intro_file:` here you must add the audio file that will be played as `Intro`. you can leave it empty and playback will start directly with the first loop.
- `outro_file:` here you need to add the audio file to be played as `Outro`. You can leave it empty and the playback will stop when calling `to_outro` method.
- `outro_to_loop:` type `Bool`, Enables switching of the Outro to the Loop section.
- `volume_db:` type `Float`, Sets the volume of the track. All layers will be affected by this parameter.
- `pitch_scale:` type `Float`, Sets the pitch scale of the track. All layers will be affected by this parameter.
- `show_measure_count:` type `Bool`, If true, show measure count system in the output.
- `loops:` To add a loop you will need to follow some additional steps:

![Imgur](https://i.imgur.com/7RFqEQ4.png)

Loops are resources of `LoopResource` class, you can create a new one as seen in the image above.

![Imgur](https://i.imgur.com/NIJHMjc.png)

In `Music Layers` you can choose the number of layers your loop plays. Each layer is a `LayerResource` class resource, and as with loops, you'll need to create one.

The layer properties are:

- `audio_stream:` assign the audio file to the layer.
- `name_layer:` type `String`, assign a name to the layer, this name will be used to recognize the AudioStreamPlayer in the scene.
- `mute:` type `Bool`, if true, then the layer will be listenning from the beginning, when called by `play_music`.
- `loop:` type `Bool`, if true, the layer will play in a loop.
- `groups:` you can assign custom groups to each layer, and then call them with the `mute_layer` method.

![Imgur](https://i.imgur.com/WvDjznG.png)

Back to the loops, in `Sequence Track`:

- `random_sequence:` type `Bool`, Defines if the loop is a random sequence. If true, sequence track plays only one layer at a time, and when finished goes to the next random layer. Remember set (loop = false) in each Layers
- `first_playback_idx:` type `Int`, Assign the first audio to be played. If -1, the first play will be random.

![Imgur](https://i.imgur.com/1xmxu4f.png)

- `BPM:` beat per minute from track.
- `metric:` is the number of beats within a measure/bar.

The loops have a beat and bar counting system. The following properties make use of this feature.
- `total_beat_count:` is the total number of beats that the loop has. ***You must have this data to make the beats and bars counter work***

(An easy way to get it is to multiply the total number of bars x metric)

- `keys_loop_in_measure:` in this property you can assign keys to specific measures/bar, when the `change_loop` method is called the track will be changed ***only when the track enters one of these keys(measures/bar)***.
- `keys_end_in_measure:` in this property you can assign keys to specific measures/bar, when the `to_outro` method is called the track will be changed ***only when the track enters one of these keys(measures/bar)***.

If the above properties are not defined, then the track will instantly switch to another loop, or the outro.


## Setters & Getters

