module GlobalBuilderWrapper

  def global(name, type, linkage = :internal, initializer = nil)
    global = default_module.globals.add(type_by_name(type), name.to_s)
    global.linkage = linkage
    global.initializer = block_given? ? yield : initializer
    global
  end

  def get_global(name)
    default_module.globals.named(name.to_s)
  end

  def write_bitcode(path_or_io)
    default_module.write_bitcode(path_or_io)
  end
  
  def constant(value, options = {})
    if value.is_a?(String)
      LLVM::ConstantArray.string(value, options[:null_terminated].nil? ? true : options[:null_terminated])
    else
      raise "Invalid constant value: #{value}"
    end
  end
  
end