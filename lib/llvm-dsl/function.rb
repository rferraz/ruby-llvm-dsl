class FunctionBuilderWrapper
  
  include BuilderWrapper
  include GlobalBuilderWrapper
  
  def initialize(arguments, return_type, name = "default", host_module = nil, options = {})
    @default_module = host_module
    @current_function = get_function(name, arguments, return_type, options)
    builder.position_at_end(get_block(@current_function, :entry))
    yield self if block_given?
  end
      
end