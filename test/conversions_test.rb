require "test_helper"

class ConversionsTestCase < Test::Unit::TestCase

  def setup
    LLVM.init_x86
  end

  def test_trunc_to
    integer_conversion_assertion(:trunc, int(257, :size => 32), :int8, LLVM_UNSIGNED, 1)
    integer_conversion_assertion(:trunc, int(123, :size => 32), :int1, LLVM_UNSIGNED, 1)
    integer_conversion_assertion(:trunc, int(122, :size => 32), :int1, LLVM_UNSIGNED, 0)
  end

  def test_zext_to
    integer_conversion_assertion(:zext, int(257, :size => 16), :int32, LLVM_UNSIGNED, 257)
  end

  def test_sext_to
    integer_conversion_assertion(:sext, int(1, :size => 1), :int32, LLVM_SIGNED, -1)
    integer_conversion_assertion(:sext, int(-1, :size => 8), :int16, LLVM_UNSIGNED, 65535)
  end

  def test_fptrunc_to
    float_conversion_assertion(:fp_trunc, double(123.0), :float, 123.0)
  end

  def test_fpext_to
    float_conversion_assertion(:fp_ext, float(123.0), :double, 123.0)
    float_conversion_assertion(:fp_ext, float(123.0), :float, 123.0)
  end

  def test_fptoui_to
    different_type_assertion(:fp2ui, double(123.3), :int32, :integer, 123)
    different_type_assertion(:fp2ui, double(0.7), :int32, :integer, 0)
    different_type_assertion(:fp2ui, double(1.7), :int32, :integer, 1)
  end

  def test_fptosi_to
    different_type_assertion(:fp2si, double(-123.3), :int32, :integer, -123)
    different_type_assertion(:fp2si, double(0.7), :int32, :integer, 0)
    different_type_assertion(:fp2si, double(1.7), :int32, :integer, 1)
  end

  def test_uitofp_to
    different_type_assertion(:ui2fp, int(257, :size => 32), :float, :float, 257.0)
    different_type_assertion(:ui2fp, int(-1, :size => 8), :double, :float, 255.0)
  end

  def test_sitofp_to
    different_type_assertion(:si2fp, int(257, :size => 32), :float, :float, 257.0)
    different_type_assertion(:si2fp, int(-1, :size => 8), :double, :float, -1.0)
  end

  def test_bitcast_to
    different_type_assertion(:bit_cast, LLVM::Int8.from_i(255), :int8, :integer, -1)
  end

  def integer_conversion_assertion(operation, operand, return_type, signed, expected_result)
    result = run_conversion_operation(operation, operand, return_type)
    assert_equal expected_result, result.to_i(signed)
  end

  def float_conversion_assertion(operation, operand, return_type, expected_result)
    result = run_conversion_operation(operation, operand, return_type)
    assert_in_delta expected_result, result.to_f(type_by_name(return_type)), 0.001
  end

  def different_type_assertion(operation, operand, return_type, assertion_type, expected_result)
    result = run_conversion_operation(operation, operand, return_type)
    if assertion_type == :integer
      assert_equal expected_result, result.to_i
    else
      assert_in_delta expected_result, result.to_f(type_by_name(return_type)), 0.001
    end
  end

  def run_conversion_operation(operation, operand, return_type)
    run_default_function(simple_function(return_type) do |f|
      f.returns(f.send(operation, operand, type_by_name(return_type)))
    end)
  end

end
