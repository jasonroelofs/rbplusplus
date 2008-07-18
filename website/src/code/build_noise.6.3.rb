      # Ignore all but the default constructors
      node.classes("NoiseMap").constructors.find(:arguments => [nil, nil]).ignore
      node.classes("NoiseMap").constructors.find(:arguments => [nil]).ignore

      node.classes("Image").constructors.find(:arguments => [nil, nil]).ignore
      node.classes("Image").constructors.find(:arguments => [nil]).ignore
