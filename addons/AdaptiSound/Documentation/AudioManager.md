# Audio Manager

This tool is designed with the objective of implementing global background music and/or sounds. `AudioManager` will only play a single `BGM` track, and in parallel one of `BGS`.

- The `current_playback` variable stores the only currently playing BGM
- The `current_bgs_playback` variable stores the only current playback of the BGS.

`AudioManager` will automatically preload audio files for when `playback methods` are called.

![img](https://i.imgur.com/JAO2IRF.png[/img])

There are two categories of files that can be played: Simple Audio files: .wav, .mp3, .ogg, and AdaptiNodes (AudioInteractive, AudioSynchronized), which are nodes created to implement adaptive music.
To learn more about these nodes see [AudioInteractive](https://github.com/MrWalkmanDev/AdaptiSound/blob/main/addons/AdaptiSound/Documentation/AudioInteractivePlaylist.md) [AudioSynchronized](https://github.com/MrWalkmanDev/AdaptiSound/blob/main/addons/AdaptiSound/Documentation/AudioSynchronized.md)

## Audio Pool Methods
### load_audio_from_stream / load_audio_from_packedscene / load_audio_from_filepath
![img](https://i.imgur.com/5RELwHp.png[/img])

These three methods load the files into the pool that can be played using the AudioManager methods.
You can load a simple audio file, a scene from an AdaptiNode, or the filepath of an audio file or AdaptiNode scene.
* `sound_name`: Assign the name with which the track will be called
* `category`: Assigns the track's category. You can use AudioManager.BGM or AudioManager.BGS.

### remove_audio_from_pool

![img](https://i.imgur.com/9o2i5EL.png[/img])

Removes a pre-loaded audio from the pool
* `sound_name`: name of the audio to delete

### create_audio_tracks

![img](https://i.imgur.com/6Jzgdse.png[/img])

Add an audio track to the AudioManager tree without playing it
* `sound_name`: name of the audio to create

### remove_audio_track

![img](https://i.imgur.com/JKQ9cve.png[/img])

Removes a specific track from the tree
* `sound_name`: name of the audio to remove

### remove_all_audio_tracks

![img](https://i.imgur.com/1g22j7Q.png[/img])

Removes all tracks from the tree


## General Playback Methods

### `play_music` 
<sub>Only for BGM (AudioFiles and AdaptiNodes)</sub>

![img](https://i.imgur.com/5dz2XBK.png[/img])

This method will play from the beginning the audio with the name assigned in *sound_name*. If there is already an audio being played, it will replace it, unless it is the same one, in which case, it will continue the current playback.

play_music automatically instantiates a track in AudioManager, so there is no need to use create_audio_track first.

- `sound_name:` type `String`, `AudioManager` will look for the preloaded sounds and play audio with this name.
- `vol_db`: type Float, set volume in dB of the track when played. `0.0 default.`
- `fade_in:` `Float`, set the fade time when the track is played. `0.0 default`.
- `fade_out:` type `Float`, set the fade time when the current playback out. `0.0 default`.

### `reset_music` 
<sub>Only for BGM (AudioFiles and AdaptiNodes)</sub>

![img](https://i.imgur.com/9TxMTd8.png[/img])

This method returns the currently playing track to the beginning.
- `vol_db:` type `Float`, set the fade time when the current playback out.


### `stop_music` 
<sub>Only for BGM (AudioFiles and AdaptiNodes)</sub>

![img](https://i.imgur.com/6k7mb9D.png[/img])

This method stops the current playback.
- `fade_out:` type `Float`, set the fade time when the current playback out. `0.0 default`.
- `can_destroy` type `bool`, if true, all tracks removes from the tree. `true default`.

### `stop_all` 
<sub>For All (BGS and BGM)</sub>

![Imgur](https://i.imgur.com/sKLJbHk.png)

This method stops all currently playing BGM/ABGM and BGS tracks, and removes them from the tree.
- `type:` type `String`, set a specific category you want to stop. `"all" default`
- `fade_out:` type `Float`, set the fade time when the current playback out. `1.5 default`
- `can_destroy:` type `Bool`, if true, all tracks removes from the tree. `true default`

## AdaptiNodes Playback Methods

### AudioInteractivePlaylist

### `change_clip` 
<sub>Only for BGM AdaptiNodes</sub>

![img](https://i.imgur.com/MdZxl3W.png[/img])

Changes the currently playing audio clip on the track named in the `sound_name` parameter.
- `sound_name:` type `String`, name of the AudioInteractive Node on which the playing `clip` will be changed.
- `clip_by_name_or_index:` type `String/Int`, clip name or index to play.
- `fade_in:` type `Float`, time of fade in. `0.0 default`.
- `fade_out:` type `Float`, time of fade out. `0.0 default`.

### `set_initial_clip` 
<sub>Only for BGM AdaptiNodes</sub>

![img](https://i.imgur.com/RUOtcWG.png[/img])

Sets the first clip to play when using the `play_music` method
- `sound_name:` type `String`, name of the AudioInteractive node where the initial clip will be changed.
- `clip_name:` type `String`,  name of the clip to assign.

### `set_can_be_interrupted` 
<sub>Only for BGM AdaptiNodes</sub>

![img](https://i.imgur.com/saPknk0.png[/img])

Sets whether the named clip can be interrupted by change_clip or not.
- `track_name:` type `String`, AudioInteractive node name.
- `clip_name:` type `String`,  name of the clip whose variable can_be_interrupted will be changed.

### AudioSynchronized

### `mute_layer` 
<sub>Only for BGM AdaptiNodes</sub>

![img](https://i.imgur.com/87JM6kJ.png[/img])

Mute or unmute specific audio layer of AudioSynchronized Node
- `layer:` type `Int/String`, name or index of the layer to be change mute state.
- `mute_state:` type `bool`, assigning mute status
- `fade_time:` type `Float`, time of fade. `2.0 default`

### `mute_all_layers` 
<sub>Only for BGM AdaptiNodes</sub>

![img](https://i.imgur.com/MIXaLup.png[/img])

Mute or unmute all layers of an AudioSynchronized Node
- `mute_state:` type `bool`, assigning mute status
- `fade_time:` type `Float`, time of fade. `2.0 default`

## General Methods
### `set_destroy`

![img](https://i.imgur.com/RFe5kxs.png[/img])

If the state is true, then the track will be removed from the tree once it finishes playing.
* `track_name:` name of the track to which the value is assigned
- `state:` if true, the track will be removed from the tree once it stops.


### `set_callback`

![img](https://i.imgur.com/IciHwFM.png[/img])

Assigns a callable method that runs when the track finishes playing
* `track_name:` name of the track to which the value is assigned
- `method:` when the current track ends, the assigned method will be executed.

### `remove_callback`

![img](https://i.imgur.com/wzFc0qN.png[/img])

Removes the callback method assigned to a track.
* `track_name:` name of the track to remove the method from


## BGS Playback Methods
### `play_sound`
<sub>Only for BGS</sub>

![img](https://i.imgur.com/MROH0Zu.png[/img])

This method will play from the beginning the audio with the name assigned in *sound_name*. If there is already an audio being played, it will replace it, unless it is the same one, in which case, it will continue the BGS current playback.

- `sound_name:` type `String`, `AudioManager` will look for the preloaded sounds and play audio with this name.
- `vol_db`: type Float, set volume in dB of the track when played. `0.0 default.`
- `fade_in:` type `Float`, set the fade time when the track is played. `0.5 default`
- `fade_out:` type `Float`, set the fade time when the current playback out. `1.5 default`

### `stop_sound`
<sub>Only for BGS</sub>

![img](https://i.imgur.com/6Ed2cJa.png[/img])

This method stops the BGS current playback.
- `fade_time:` type `Float`, set the fade time when the BGS current playback out. `0.0 default`

### `mute_bgs_layer`
<sub>Only for BGS</sub>

![img](https://i.imgur.com/zdgGMY4.png[/img])

Mute or unmute specific audio layer of AudioSynchronized Node
- `layer_name:` type `Int/String`, name or index of the layer to be mute.
 `mute_state:` type `bool`, assigning mute status
- `fade_time:` type `Float`, time of fade in. `2.0 default`

### `mute_bgs_all_layer`
<sub>Only for BGS</sub>

![img](https://i.imgur.com/3OVUwD6.png[/img])

Mute or unmute all audio layers of AudioSynchronized Node
 `mute_state:` type `bool`, assigning mute status
- `fade_time:` type `Float`, time of fade in. `2.0 default`


## Audio Bus Methods

### `add_bus`

![Imgur](https://i.imgur.com/1itXEeC.png)

- `bus_name:` assigns the name of the audio bus.

### `get_track_bus_name`

![Imgur](https://i.imgur.com/YYdGpjh.png)

gets the bus name of the assigned track

### `get_track_bus_index`

![Imgur](https://i.imgur.com/6FGnVXF.png)

gets the bus index of the assigned track

### `get_track_bus_volume_db`

![Imgur](https://i.imgur.com/MLo4jiO.png)

gets the bus volume_db of the assigned track

### `set_bus_volume_db`

![Imgur](https://i.imgur.com/hTi8Xhp.png)

sets the volume of the bus. need bus index.
