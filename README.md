# AdaptiSound
Complete Background Audio Manager for Godot 4.0

AdaptiSound will help you implement music in your videogame. Explore the world of interactive and adaptive music with the different tools that this plugin gives you.
Your creativity is the limit!


## 🎵 AdaptiSound Alpha v0.1 ![](https://camo.githubusercontent.com/d8177663f486ebdd812419dbf9fe4f8e750c01f2026590e5994ee31bbf7a8123/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f476f646f742d76342e302d253233343738636266)
### ⚙ Installation
To Install AdaptiSound you must download the ZIP file, once downloaded move the `/addons` in the root of your project. Once the project is open you must activate the plugin in the project settings. If you see errors in the output panel, you might need to reboot the editor after enabling AdaptiSound for the first time.

If you want to know more about installing plugins you can read the [Godot docs page](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html)


## 🎛Documentation

### Main Panel

![MainPanel](https://github.com/MrWalkmanDev/AdaptiSound/assets/109055491/e9348ba6-5fb8-4d33-b96f-9adb4f76a1d8)

The `Main Panel` will help you organize the audio files in your project.
You can separate the music into 3 different categories:
- `BGM` (Background Music)
- `ABGM` (Adaptive Background Music)
- `BGS` (Background Sounds)

#### **Audio Directories**

![Directories](https://github.com/MrWalkmanDev/AdaptiSound/assets/109055491/43df5d91-49a7-4f7c-ad4b-018936f2d3ab)

You will have to assign a directory for each category, `Main Panel` will look in all the subfolders for audio files with the extensions selected in **Audio Extensions**.
With the *search* button you can view the files found in the directories.

*`Note`: ABGM will search only .tscn files, as it will use only the scenes created with AdaptiveTrack, or ParallelTrack*

#### **Audio Bus**

![Bus](https://github.com/MrWalkmanDev/AdaptiSound/assets/109055491/85044888-b568-4134-9d89-39cfede581b7)

Here you can assign an audio *BUS* for each category. This will help with later in-game audio volume management.

#### **Debug and ABGS Support**

![Debugging](https://github.com/MrWalkmanDev/AdaptiSound/assets/109055491/138b7e7d-3bd2-47e5-b860-3a06a794b796)

- `Debugging`: You will be able to see the plugin's operation in the output panel.
- `ABGS Support`: It will allow you to add scenes with AdaptiveTrack or ParallelTrack nodes in the BGS category.


## AudioManager Singleton

This tool is designed with the objective of implementing global background music and/or sounds. `AudioManager` will only play a single `BGM` or `ABGM` track, and in parallel one of `BGS`.

- The `current_playback` variable stores the only currently playing BGM or ABGM.
- The `current_bgs_playback` variable stores the only current playback of the BGS.

![AudioManager](https://github.com/MrWalkmanDev/AdaptiSound/assets/109055491/8bdfc8b4-9ede-4844-9335-7db9dfebbd91)

`AudioManager` will automatically preload audio files for when `playback methods` are called.

*Only add_track method and play_music method add an instance to the `AudioManager` tree in the container with its category.*

## Playback Methods

### `play_music` 
<sub>Only for BGM/ABGM</sub>

![play_music](https://github.com/MrWalkmanDev/AdaptiSound/assets/109055491/d97fedf0-1d24-4194-8f92-d716bc403764)

This method will play from the beginning the audio with the name assigned in *sound_name*. If there is already an audio being played, it will replace it, unless it is the same one, in which case, it will continue the current playback.

- `sound_name:` with this argument type `String`, `AudioManager` will look for the preloaded sounds and play audio with this name.
- `volume_db:` argument type `Float`, set volume in dB of the track when played. *0.0 default*
- `fade_in:` argument type `Float`, set the fade time when the track is played. *0.5 default*
- `fade_out:` argument type `Float`, set the fade time when the current playback out. *1.5 default*
- `skip_intro:` **only for AdaptiveTrack**, `Bool` if true, play the loop directly. *false default*
- `loop_index:` **only for AdaptiveTrack**, `Int` sets the index of the loop to be played after the intro. *0 default*


### `reset_music` 
<sub>Only for BGM/ABGM</sub>

![reset_music](https://github.com/MrWalkmanDev/AdaptiSound/assets/109055491/4061983a-3a92-42d2-8f0e-76ce33332c9d)

This method returns the currently playing track to the beginning.
- `fade_out:` argument type `Float`, set the fade time when the current playback out. *0.0 default*
- `fade_in:` argument type `Float`, set the fade time when the track is played. *0.0 default*


### `stop_music` 
<sub>Only for BGM/ABGM</sub>

![stop_music](https://github.com/MrWalkmanDev/AdaptiSound/assets/109055491/b3fd1554-36d5-4dca-9399-cb5d6a2ccafd)

This method stops the current playback.
- `can_fade:` if true, apply fade_out on current playback track. *false default*
- `fade_out:` argument type `Float`, set the fade time when the current playback out. *1.5 default*



### `change_loop` 
<sub>Only for ABGM</sub>

![change_loop](https://github.com/MrWalkmanDev/AdaptiSound/assets/109055491/3ce8a847-c3f4-46af-8271-a4350645a381)



### `to_outro` 
<sub>Only for ABGM</sub>

![to_outro](https://github.com/MrWalkmanDev/AdaptiSound/assets/109055491/d588bcf8-6a7f-4f38-a364-07b92cc39dc9)

### `layer_on` 
<sub>Only for ABGM</sub>

![layer_on](https://github.com/MrWalkmanDev/AdaptiSound/assets/109055491/c9bfa806-ba06-4eb1-8aad-17d247823868)

### `layer_off` 
<sub>Only for ABGM</sub>

![layer_off](https://github.com/MrWalkmanDev/AdaptiSound/assets/109055491/4465b310-6636-47a8-b700-504233a09644)


### `play_sound` 
<sub>Only for BGS</sub>

![play_sound](https://github.com/MrWalkmanDev/AdaptiSound/assets/109055491/931b7595-c39a-4e53-bacf-f2a60ee03eb1)

This method will play from the beginning the audio with the name assigned in *sound_name*. If there is already an audio being played, it will replace it, unless it is the same one, in which case, it will continue the current playback.

*Same as play_music*



### `stop_all` 
<sub>For All</sub>

![stop_all](https://github.com/MrWalkmanDev/AdaptiSound/assets/109055491/c509e425-9ec9-4f45-a455-cbe914b34747)

This method stops all currently playing BGM/ABGM and BGS tracks, and removes them from the tree.
- `type:` argument type `String`, set a specific category you want to stop. *all default*
- `fade_out:` argument type `Float`, set the fade time when the current playback out. *1.5 default*
- `can_destroy:` if true, all tracks removes from the tree. *true default*




### AdaptiNodes

**ParallelTrack**

**AdaptiveTrack**


### 📃Credits
- Made by [Isaías Arrué R.](https://github.com/MrWalkmanDev) ( [Mr. Walkman](https://mr-walkman.itch.io) )
- DEMO art assets by [AnalogStudios](https://analogstudios.itch.io)
- DEMO music by [Isaías Arrué R.](https://www.instagram.com/colorwave.music/)

[MIT License](https://github.com/MrWalkmanDev/AdaptiSound/blob/main/LICENSE)
