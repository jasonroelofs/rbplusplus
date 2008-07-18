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
