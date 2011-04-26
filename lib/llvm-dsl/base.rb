require "forwardable"

module BuilderWrapper
  
  attr_accessor :default_module
  
  extend Forwardable
  
  def_delegators :builder, *%w(add sub mul udiv sdiv urem srem shl lshr ashr and or xor fadd fsub fmul fdiv frem)
  def_delegators :builder, *%w(eq ne ugt uge ult ule sgt sge slt sle)
  def_delegators :builder, *%w(trunc zext sext fp_trunc fp_ext fp2ui fp2si ui2fp si2fp bit_cast)
  
  def_delegator :builder, :icmp
  def_delegator :builder, :fcmp

  def_delegator :builder, :select
  
  def_delegator :builder, :unreachable
  
  def_delegators :builder, :store, :load
  def_delegators :builder, :insert_value, :extract_value
  
  def_delegators :builder, :shuffle_vector
  
  def global(name, type, linkage = :internal, initializer = nil)
    global = default_module.globals.add(type_by_name(type), name.to_s)
    global.linkage = linkage
    global.initializer = block_given? ? yield : initializer
    global
  end
  
  def returns(value = nil)
    if value == :void
      builder.ret_void
    else
      block_given? ? builder.ret(yield self) : builder.ret(value)
    end
  end
  
  def cast(pointer, name)
    builder.bit_cast(pointer, type_by_name(name))
  end
  
  def ptr2int(pointer, name)
    builder.ptr2int(pointer, type_by_name(name))
  end

  def int2ptr(pointer, name)
    builder.int2ptr(pointer, type_by_name(name))
  end
  
  def gep(pointer, *indices)
    builder.gep(pointer, indices)
  end
  
  def allocate(name, options = {})
    if options[:size]
      builder.array_alloca(type_by_name(name), LLVM::Int(options[:size]))
    else
      builder.alloca(type_by_name(name))
    end
  end
  
  def insert_element(pointer, value, index)
    builder.insert_element(pointer, value, LLVM::Int32.from_i(index))
  end
  
  def extract_element(pointer, index)
    builder.extract_element(pointer, LLVM::Int32.from_i(index))
  end
  
  def call(name, *arguments)
    if name.is_a?(Symbol) || name.is_a?(String)
      builder.call(default_module.functions.named(name.to_s), *arguments)
    else
      builder.call(name, *arguments)
    end
  end
  
  def branch(name)
    builder.br(get_block(current_function, name))
  end
  
  def condition(comparison, true_branch, false_branch)
    builder.cond(comparison, 
      get_block(current_function, true_branch),
      get_block(current_function, false_branch))
  end
  
  def switch(value, default, *branches)
    switch = builder.switch(value, get_block(current_function, default), {})
    branches.each do |branch|
      switch.add_case(branch[:on], get_block(current_function, branch[:go_to]))
    end
  end

  def phi(type, *incomings)
    phi = builder.phi(type_by_name(type), {})
    add_incoming(phi, *incomings)
    phi
  end
  
  # Just a convenience method
  def partial_phi(type, *incomings)
    phi(type, *incomings)
  end
  
  def add_incoming(phi, *incomings)
    incomings.each do |incoming|
      phi.add_incoming(get_block(current_function, incoming[:return_from]) => incoming[:on])
    end
  end

  def arg(index)
    return current_function.params[current_function.params.size - 1] if index == :last
    current_function.params[index]
  end
  
  def block(name)
    builder.position_at_end(get_block(current_function, name))
    yield self
  end
  
  def entry(&block)
    block(:entry, &block)
  end

  def exit(&block)
    block(:exit, &block)
  end
  
  def default_function
    default_module.functions.first
  end
  
  def verified_module
    default_module.verify
    default_module
  end
  
  def set_bookmark(name, value = nil)
    bookmarks[name] = block_given? ? yield : value
  end
  
  def get_bookmark(name)
    bookmarks[name]
  end
  
  protected
  
  def bookmarks
    @bookmarks ||= {}
  end
  
  def current_function
    @current_function || default_module.functions.last
  end

  def default_module
    @default_module ||= LLVM::Module.create("default")
  end

  def builder
    @builder ||= LLVM::Builder.create
  end
  
  def get_function(name, arguments, return_type, options = {})
    default_module.functions.named(name.to_s) || 
      default_module.functions.add(name, arguments.collect { |argument| type_by_name(argument) }, type_by_name(return_type), options)
  end

  def get_block(function, name)
    real_name = name.to_s
    @blocks ||= {}
    @blocks[real_name] = function.basic_blocks.append(real_name) unless @blocks[real_name]
    @blocks[real_name]
  end
  
end