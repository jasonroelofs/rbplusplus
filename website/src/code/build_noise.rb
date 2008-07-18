require 'rbplusplus'
require 'fileutils'
include RbPlusPlus

OGRE_RB_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
NOISE_DIR = File.join(OGRE_RB_ROOT, "tmp", "noise")
HERE_DIR = File.join(OGRE_RB_ROOT, "wrappers", "noise")

Extension.new "noise" do |e|
  e.working_dir = File.join(OGRE_RB_ROOT, "generated", "noise")
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

  e.module "Noise" do |m|
    m.namespace "noise"

    m.module "Model" do |model|
      model.namespace "model"
    end

    m.module "Utils" do |utils|
      node = utils.namespace "utils"
      node.classes("NoiseMapBuilder").methods("SetCallback").ignore

      # Ignore all but the default constructors
      node.classes("NoiseMap").constructors.find(:arguments => [nil, nil]).ignore
      node.classes("NoiseMap").constructors.find(:arguments => [nil]).ignore

      node.classes("Image").constructors.find(:arguments => [nil, nil]).ignore
      node.classes("Image").constructors.find(:arguments => [nil]).ignore
    end

    m.module "Module" do |mod|
      node = mod.namespace "module"

      # Ignore pure virtual
      node.classes("Module").methods("GetSourceModuleCount").ignore
      node.classes("Module").methods("GetValue").ignore
    end
  end
end
