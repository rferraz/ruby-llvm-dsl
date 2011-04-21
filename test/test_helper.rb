$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

begin
  require "ruby-debug"
rescue LoadError
  # Ignore ruby-debug is case it's not installed
end

require "test/unit"
require "tmpdir"

# Extra requires
require "llvm/execution_engine"
require "llvm/transforms/scalar"
require "llvm/bitcode"

require "llvm-dsl"

class Test::Unit::TestCase
  LLVM_SIGNED = true
  LLVM_UNSIGNED = false
end

def run_function_on_module(llvm_module, llvm_function, *argument_values)
  LLVM::ExecutionEngine.
    create_jit_compiler(llvm_module).
    run_function(llvm_function, *argument_values)
end

def run_default_function(wrapper, *argument_values)
  run_function_on_module(wrapper.verified_module, wrapper.default_function, *argument_values)
end