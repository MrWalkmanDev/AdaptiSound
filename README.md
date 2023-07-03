# AdaptiSound
Complete BGM Manager for Godot 4.0

AdaptiSound will help you implement music in your videogame. Explore the world of interactive and adaptive music with the different tools that this plugin gives you.
Your creativity is the limit!


## 🎵 AdaptiSound v0.1 ![](https://camo.githubusercontent.com/d8177663f486ebdd812419dbf9fe4f8e750c01f2026590e5994ee31bbf7a8123/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f476f646f742d76342e302d253233343738636266)
### ⚙ Installation
To Install AdaptiSound you must download the ZIP file, once downloaded move the `/addons` in the root of your project. Once the project is open you must activate the plugin in the project settings. If you see errors in the output panel, you might need to reboot the editor after enabling AdaptiSound for the first time.

If you want to know more about installing plugins you can read the [Godot docs page](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html)


## 🎛Documentation
### Main Panel

![MainPanel](https://github.com/MrWalkmanDev/AdaptiSound/assets/109055491/e9348ba6-5fb8-4d33-b96f-9adb4f76a1d8)

El `Main Panel` te ayudará a organizar los archivos de audio en tu proyecto.
El objetivo es separar la música en 3 categorías diferentes:
- `BGM` (Background Music)
- `ABGM` (Adaptive Background Music)
- `BGS` (Background Sounds)

#### **Audio Directories**

![Directories](https://github.com/MrWalkmanDev/AdaptiSound/assets/109055491/43df5d91-49a7-4f7c-ad4b-018936f2d3ab)

Deberás asignar un directorio para cada categoría, `Main Panel` buscará en todas las subcarpetas archivos de audio con las extensiones seleccionadas en **Audio Extensions**.
Con el botón *buscar* podrás visualizar los archivos encontrados en los directorios.

*`Nota`: ABGM buscará sólo archivos .tscn, ya que usará sólo las escenas creadas con AdaptiveTrack, o ParallelTrack*

#### **Audio Bus**

![Bus](https://github.com/MrWalkmanDev/AdaptiSound/assets/109055491/85044888-b568-4134-9d89-39cfede581b7)

Aquí podrás asignar un *BUS* de audio para cada categoría. Esto ayudará al posterior manejo del volumen de audio dentro del juego.

#### **Debug and ABGS Support**

![Debugging](https://github.com/MrWalkmanDev/AdaptiSound/assets/109055491/138b7e7d-3bd2-47e5-b860-3a06a794b796)

- `Debugging`: Podrás visualizar el output panel el funcionamiento del plugin.
- `ABGS Support`: Te permitirá agregar escenas con los nodos AdaptiveTrack o ParallelTrack en la categoría de BGS (Sólo si este directorio es diferente a ABGM)


### AudioManager Singleton
![AudioManager](https://github.com/MrWalkmanDev/AdaptiSound/assets/109055491/8bdfc8b4-9ede-4844-9335-7db9dfebbd91)

`AudioManager` precargará automáticamente los archivos de audio para cuando las `opciones de reproduccion` sean llamadas.

**Playback Methods**

**play_music(`sound_name: String`, `volume_db : Float`= 0.0, `fade_in : Float`= 0.5, `fade_out: Float`= 1.5, `skip_intro : Bool`= false, `loop_index : Int`= 0)**

Este método reproducirá desde el inicio el audio con el nombre asignado en *sound_name*. Si ya existe un audio reproduciéndose éste lo reemplazará, almenos que sea el mismo, en ese caso, continuará la reproducción actual.

- *sound_name:* con este argumento `AudioManager` buscara los sonido precargados y reproducira el que tenga este nombre


### AdaptiNodes

**ParallelTrack**

**AdaptiveTrack**


### 📃Credits
- Made by [Isaías Arrué R.](https://github.com/MrWalkmanDev) ( [Mr. Walkman](https://mr-walkman.itch.io) )
- DEMO art assets by [AnalogStudios](https://analogstudios.itch.io)
- DEMO music by [Isaías Arrué R.](https://www.instagram.com/colorwave.music/)

[MIT License](https://github.com/MrWalkmanDev/AdaptiSound/blob/main/LICENSE)
