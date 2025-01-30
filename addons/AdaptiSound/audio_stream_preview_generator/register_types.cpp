#include "register_types.h"

#include "core/object/class_db.h"
#include "audio_stream_preview.h"

void initialize_audio_stream_preview_generator_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }
    ClassDB::register_class<AudioStreamPreviewGenerator>();
}

void uninitialize_audio_stream_preview_generator_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }
}
