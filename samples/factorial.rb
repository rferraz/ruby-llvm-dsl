require "llvm"
require "llvm-dsl"

require "llvm/execution_engine"
require "llvm/core"

LLVM.init_x86

factorial_builder = simple_module "factorial" do |m|
  
  m.function [:int], :int, "factorial" do |f|
    f.entry do
      comparison = f.icmp(:eq, f.arg(0), int(1))
      f.condition(comparison, :exit, :recurse) 
    end
    f.block(:recurse) do     
      f.returns do
        sub = f.sub(f.arg(0), int(1))
        call = f.call("factorial", sub)
        f.set_bookmark(:result) do
          f.mul(f.arg(0), call)
        end
      end
    end
    f.exit do
      f.returns do
        f.phi :int,
          { :on => f.arg(0), :return_from => :entry },
          { :on => f.get_bookmark(:result), :return_from => :recurse }
      end
    end
  end
  
end

puts

factorial = factorial_builder.verified_module

factorial.dump

engine = LLVM::ExecutionEngine.create_jit_compiler(factorial)

arg = (ARGV[0] || 6).to_i
value = engine.run_function(factorial.functions.named("factorial"), arg)

printf("\nfac(%i) = %i\n\n", arg, value)

