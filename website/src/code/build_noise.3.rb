  e.sources [
      File.join(NOISE_DIR, "include/noise.h"),
      File.join(HERE_DIR, "code", "noiseutils.h")
    ],
    :library_paths => File.join(OGRE_RB_ROOT, "lib", "noise"),
    :include_paths => File.join(OGRE_RB_ROOT, "tmp", "noise", "include"),
    :libraries => "noise",
    :include_source_files => [
      File.join(HERE_DIR, "code", "noiseutils.cpp"), 
      File.join(HERE_DIR, "code", "noiseutils.h"),
      File.join(HERE_DIR, "code", "custom_to_from_ruby.cpp"), 
      File.join(HERE_DIR, "code", "custom_to_from_ruby.hpp")
    ],
    :includes => File.join(HERE_DIR, "code", "custom_to_from_ruby.hpp")
