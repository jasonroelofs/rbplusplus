    m.module "Utils" do |utils|
      node = utils.namespace "utils"
      node.classes("NoiseMapBuilder").methods("SetCallback").ignore

      # Ignore all but the default constructors
      node.classes("NoiseMap").constructors.find(:arguments => [nil, nil]).ignore
      node.classes("NoiseMap").constructors.find(:arguments => [nil]).ignore

      node.classes("Image").constructors.find(:arguments => [nil, nil]).ignore
      node.classes("Image").constructors.find(:arguments => [nil]).ignore
    end
