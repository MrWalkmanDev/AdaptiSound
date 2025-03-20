# Audio Panel

![img](https://i.imgur.com/IKoyUjL.png)

The `AudioPanel` will save audio files to pools and preload them into memory. This way, all preloaded audio files can be used simply by calling the `AudioManager` singleton's playback methods.

**When making any changes in this panel, they must be saved by pressing the save button for the changes to take effect.**

![img](https://i.imgur.com/ED7M2Ec.png)


## Properties
* **Process Mode** 
Defines the `AudioManager` process mode, this property is the same as the process_mode property that all Nodes already have.

* **Debugging**
If true, activates `AudioManager` debugging in the console.

## Audio Pool Options
`AudioManager` is divided into two audio categories: 
* Bckground music (BGM),
* Background sound effects (BGS).

#### Audio Buses
For each category you can assign a bus channel, all files in the pool will play on this channel by default.
The left button updates the bus options.

![img](https://i.imgur.com/wciXAyN.png)
![img](https://i.imgur.com/olhUkrm.png)

#### Preload System
For each category a pool of files is created that is preloaded when the singleton starts, making audio playback more efficient. However, this option is not required for the plugin to work. You can dynamically load the files you want to play at a convenient time. The methods for achieving dynamic loading are found in [AudioManager](https://github.com/MrWalkmanDev/AdaptiSound/blob/main/addons/AdaptiSound/Documentation/AudioManager.md)

To enable the preload system, you must set the `Audio Files Preload` and `Adaptive Scene Preload` properties for BGM, and `Audio and Scenes Files Preload` for BGS.

![img](https://i.imgur.com/kA368tE.png)

To create the pools you will have to assign a directory for each category, `AudioPanel` will look in all the subfolders for audio files with the extensions selected in **Audio Extensions**.
With the *search* button you can view the files found in the directories.

*`Note`: Adaptive Scenes Preload will search only .tscn files, as it will use only the scenes created with AudioInteractive, or AudioSynchronized Nodes*


#### Preloaded files are saved with the file name as the key to access them, so you should ensure that the files you play have **unique names**.


![img](https://i.imgur.com/wbKBNil.png)

#### Audio Extensions
Audio Extensions ahese are the types of audio files that `AudioPanel` can find for pools.

![img](https://i.imgur.com/7UDXRik.png)



