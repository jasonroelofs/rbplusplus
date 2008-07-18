    m.module "Module" do |mod|
      node = mod.namespace "module"

      # Ignore pure virtual
      node.classes("Module").methods("GetSourceModuleCount").ignore
      node.classes("Module").methods("GetValue").ignore
    end
  end
end
