# AdaptiSound
Complete BGM Manager for Godot 4.0

AdaptiSound te ayudará a implementar la música en tu videojuego. Explora el mundo de la música interactiva y adaptativa con las diferentes herramientas que te entrega este plugin.
Tu creatividad es el límite!


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
- `BGS` (Background Sounds)
- `ABGM` (Adaptive Background Music)

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

- Con `Debugging` podrás visualizar el output panel el funcionamiento del plugin.
- `ABGS Support` te permitirá agregar escenas con los nodos AdaptiveTrack o ParallelTrack en la categoría de BGS (Sólo si este directorio es diferente a ABGM)


### AudioManager Singleton
- AdaptiveTrack Node
- ParallelTrack Node


### Made by 
Isaías Arrué R. `(Mr. Walkman)`

[MIT License](https://github.com/MrWalkmanDev/AdaptiSound/blob/main/LICENSE)
