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

![Imgur](https://i.imgur.com/isVC4CR.png)

This method will play from the beginning the audio with the name assigned in *sound_name*. If there is already an audio being played, it will replace it, unless it is the same one, in which case, it will continue the current playback.

- `sound_name:` with this argument type `String`, `AudioManager` will look for the preloaded sounds and play audio with this name.
- `volume_db:` argument type `Float`, set volume in dB of the track when played. `0.0 default`
- `fade_in:` argument type `Float`, set the fade time when the track is played. `0.5 default`
- `fade_out:` argument type `Float`, set the fade time when the current playback out. `1.5 default`
- `skip_intro:` **only for AdaptiveTrack**, `Bool` if true, play the loop directly. `false default`
- `loop_index:` **only for AdaptiveTrack**, `Int` sets the index of the loop to be played after the intro. `0 default`


### `reset_music` 
<sub>Only for BGM/ABGM</sub>

![Imgur](https://i.imgur.com/PvFIyCe.png)

This method returns the currently playing track to the beginning.
- `fade_out:` argument type `Float`, set the fade time when the current playback out. `0.0 default`
- `fade_in:` argument type `Float`, set the fade time when the track is played. `0.0 default`


### `stop_music` 
<sub>Only for BGM/ABGM</sub>

![Imgur](https://i.imgur.com/h5yE4sL.png)

This method stops the current playback.
- `can_fade:` if true, apply fade_out on current playback track. `false default`
- `fade_out:` argument type `Float`, set the fade time when the current playback out. `1.5 default`


### `change_loop` 
<sub>Only for ABGM</sub>

![Imgur](https://i.imgur.com/q8LL0bG.png)

- `sound_name:` argument type `String`, name of the AdaptiveTrack on which the playing `Loop` will be changed.
- `loop_by_index:` loop index to play.
- `can_fade:` if true, tracks will change with fades. `false default`
- `fade_in:` time of fade in. `0.5 default`
- `fade_out:` time of fade out. `1.5 default`

### `to_outro` 
<sub>Only for ABGM</sub>

![Imgur](https://i.imgur.com/Iqv62Hg.png)

- `sound_name:` argument type `String`, name of the AdaptiveTrack in which to switch to the `Outro`
- `can_fade:` if true, tracks will change with fades. `false default`
- `fade_out:` time of fade out. `1.5 default`
- `fade_in:` time of fade in. `0.5 default`


### `layer_on` 
<sub>Only for ABGM</sub>

![Imgur](https://i.imgur.com/G42Roq9.png)

- `track_name:` argument type `String`, name of ParallelTrack on which a layer will be played.
- `layer_names:` type `Array`, names, groups, or indexes of the layers to be heard.
- `fade_time:` time of fade in. `2.0 default`

### `layer_off` 
<sub>Only for ABGM</sub>

![Imgur](https://i.imgur.com/SolmYzZ.png)

- `track_name:` argument type `String`, name of ParallelTrack on which to stop listening to a layer
- `layer_names:` type `Array`, names, groups, or indices of the layers to be unheard.
- `fade_time:` time of fade in. `3.0 default`

### `play_layer`
<sub>Only for ABGM</sub>

![Imgur](https://i.imgur.com/Fmz0ZTI.png)

- `track_name:` argument type `String`, name of the track that contains the layers to play.
- `layer_names:` type `Array`, names, groups, or indices of trigger layers to play.
- `can_fade:` if true, tracks will play with fade in. `false default`
- `fade_time:` time of fade in. `3.0 default`

### `stop_layer`
<sub>Only for ABGM</sub>

- `track_name:` argument type `String`, name of the track that contains the layers to stop.
- `layer_names:` type `Array`, names, groups, or indices of trigger layers to stop.
- `can_fade:` if true, tracks will play with fade out. `false default`
- `fade_time:` time of fade out. `3.0 default`

### `stop_all` 
<sub>For All</sub>

![Imgur](https://i.imgur.com/sKLJbHk.png)

This method stops all currently playing BGM/ABGM and BGS tracks, and removes them from the tree.
- `type:` argument type `String`, set a specific category you want to stop. `"all" default`
- `fade_out:` argument type `Float`, set the fade time when the current playback out. `1.5 default`
- `can_destroy:` if true, all tracks removes from the tree. `true default`


### `play_sound`
<sub>Only for BGS</sub>

![Imgur](https://i.imgur.com/r7e01zW.png)

This method will play from the beginning the audio with the name assigned in *sound_name*. If there is already an audio being played, it will replace it, unless it is the same one, in which case, it will continue the current playback.

*Same as play_music*

*Use `stop_all("BGS")` for stop sounds*

*ABGS playback options not yet available.*


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
- `Groups:` you can assign custom groups to each layer, and then call them with the `layer_on` or `layer_off` function.

![Imgur](https://i.imgur.com/Ka5jHfO.png)

The objective of this structure is that all the layers of type `Always` are playing in parallel, and with the `layer_on` and `layer_off` methods we activate or deactivate them respectively to be heard.


### AdaptiveTrack

The main function of `AdaptiveTrack` is to reproduce the following structure:

| Intro | Loops | Outro |
| ----- | ----- | ----- |
- `Intro:` It is a track that plays only once, and can only be stopped with a track change (`play_music`), or with the `stop_music` method.
- `Loops:` These tracks will play in a loop, but only one track will play at a time, to change from one loop to another you must call the `change_loop` method.
- `Outro:` This track will play only once, and can only be interrupted by the `change_loop`, or `stop_music` method. to go from the loops section to the outro you must call `to_outro` method.

![Imgur](https://i.imgur.com/5av3yLb.png)

AdaptiveTrack properties
- `intro_file:` here you must add the audio file that will be played as `Intro`. you can leave it empty and playback will start directly with the first loop.
- `outro_file:`  here you need to add the audio file to be played as `Outro`. You can leave it empty and the playback will stop when calling `to_outro` method.
- `loops_files:` To add a loop you will need to follow some additional steps:

![Imgur](https://i.imgur.com/Hq85fNJ.png)

Loops are resources of `BaseAudioTrack` class, you can create a new one as seen in the image above.

- `audio_file:` here you must add the audio file that will be played in a loop
- `track_name:` give the loop a name
- `BPM:` beat per minute from track
- `metric:` is the number of beats within a measure/bar

The loops have a beat and bar counting system. The following properties make use of this feature.
- `total_beat_count:` is the total number of beats that the loop has. ***You must have this data to make the beats and bars counter work***

(An easy way to get it is to multiply the total number of bars x metric)

- `keys_loop_in_measure:` in this property you can assign keys to specific measures/bar, when the `change_loop` method is called the track will be changed ***only when the track enters one of these keys(measures/bar)***.
- `keys_end_in_measure:` in this property you can assign keys to specific measures/bar, when the `to_outro` method is called the track will be changed ***only when the track enters one of these keys(measures/bar)***.

If the above properties are not defined, then the track will instantly switch to another loop, or the outro.
