class SimpleModuleBuilderWrapper
  
  include GlobalBuilderWrapper
  
  def initialize(name)
    @module = LLVM::Module.create(name)
    @wrappers = {}
    yield self if block_given?
  end
  
  def function(arguments, return_type, name = "default", options = {}, &block)
    if @wrappers[name]
      yield @wrappers[name]
    else
      @wrappers[name] ||= FunctionBuilderWrapper.new(arguments, return_type, name, @module, options, &block)
    end
  end
  
  def with(name)
    yield @wrappers[name]
  end
  
  def get_function(name)
    @module.functions.named(name.to_s)
  end
  
  def external(name, arguments, return_type, options = {})
    function = @module.functions.add(name, arguments.collect { |argument| type_by_name(argument) }, type_by_name(return_type), options)
    function.linkage = options[:linkage] || :external
    function
  end
  
  def verified_module
    @module.verify
    @module
  end
  
  def default_function
    @module.functions.last
  end
  
  protected
  
  def default_module
    @module
  end
  
end