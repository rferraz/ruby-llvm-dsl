def simple_function(return_type, options = {}, &block)
  FunctionBuilderWrapper.new([], return_type, "default", nil, options, &block)
end

def function(arguments, return_type, options = {}, &block)
  FunctionBuilderWrapper.new(arguments, return_type, "default", nil, options, &block)
end

def simple_module(name, &block)
  SimpleModuleBuilderWrapper.new(name, &block)
end

def int(value, options = {})
  LLVM::const_get("Int#{options[:size] || LLVM::NATIVE_INT_SIZE}").
    from_i(value, options[:signed] || true)
end

def float(value)
  LLVM::Float(value)
end

def double(value)
  LLVM::Double(value)
end

def pointer_type(name)
  LLVM::Pointer(type_by_name(name))
end

def array_type(name, size)
  LLVM::Array(type_by_name(name), size)
end

def vector_type(name, size)
  LLVM::Vector(type_by_name(name), size)
end

def struct_type(*types)
  options = types.last.is_a?(Hash) ? types.pop : {}
  LLVM::Type.struct(types.collect { |name| type_by_name(name) }, options[:packed] || false)
end

def opaque_type
  LLVM::Type.opaque
end

def function_type(arguments, return_type)
  LLVM::Function(arguments.collect { |name| type_by_name(name) }, type_by_name(return_type))
end

def recursive_type(&block)
  LLVM::Type.rec(&block)
end

def type_by_name(type)
  if type.is_a?(Array)
    raise "Array types should have just one element type" unless type.uniq.size == 1
    LLVM::Array(type_by_name(type.first), type.size)
  elsif type.is_a?(LLVM::Type) || type.is_a?(LLVM::Value)
    type
  else
    case type.to_s
    when "void"
      LLVM.Void
    when "int"
      LLVM::Int
    when /int(\d+)/
      LLVM::const_get("Int#{$1}")
    when "bool"
      LLVM::Int1
    when "float"
      LLVM::Float
    when "double"
      LLVM::Double
    else
      raise "Unrecognized type: #{type}"
    end
  end
end