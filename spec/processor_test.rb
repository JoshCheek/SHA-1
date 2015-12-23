require 'minitest'
require 'processor'

class ProcessorTest < Minitest::Test
  def setup
    @p = Processor.new
  end

  def one_segment_block
    "01100001011000100110001101100100011001010110000101100010011000110110010001100101011000010110001001100011011001000110010101100001011000100110001101100100011001010110000101100010011000110110010001100101011000010110001001100011011001000110010101100001011000100110001101100100011001010110000101100010011000110110010001100101011000010110001001100011011001000110010101100001011000100110001101100100011001010110000101100010011000110110010001100101011000010110001001100011011001000110010101100001011000100110001101100100"
  end

  def two_segment_message
    ["01100001011000100110001101100100011001010110000101100010011000110110010001100101011000010110001001100011011001000110010101100001011000100110001101100100011001010110000101100010011000110110010001100101011000010110001001100011011001000110010101100001011000100110001101100100011001010110000101100010011000110110010001100101011000010110001001100011011001000110010101100001011000100110001101100100011001010110000101100010011000110110010001100101011000010110001001100011011001000110010101100001011000100110001101100100", "01100101011000010110001001100011011001000110010101100001011000100110001101100100011001010110000101100010011000110110010001100101011000010110001001100011011001000110010101100001011000100110001101100100011001010110000101100010011000110110010001100101011000010110001001100011011001000110010110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001100100000"]
  end

  def test_performs_circular_left_shift_one_time_on_binary_string
    str = '00010111'
    expected = '00101110'

    assert_equal expected, @p.circular_left_shift(str, 1)
  end

  def test_performs_circular_left_shift_three_times_on_binary_string
    str = '00010111'
    expected = '10111000'

    assert_equal expected, @p.circular_left_shift(str, 3)
  end

  def test_performs_bitwise_exclusive_or_on_four_binary_strings
    str1 = '0001'
    str2 = '0011'
    str3 = '0111'
    str4 = '0000'

    assert_equal '0101', @p.bitwise_exclusive_or([str1, str2, str3, str4])
  end

  def test_performs_bitwise_exclusive_or_on_four_long_binary_strings
    str1 = '000100101'
    str2 = '001110000'
    str3 = '011111011'
    str4 = '000010000'

    assert_equal '010111110', @p.bitwise_exclusive_or([str1, str2, str3, str4])
  end

  def test_preps_message_schedule_for_one_block_message
    message = one_segment_block

    message_schedule = {
      "t0" => "01100001011000100110001101100100",
      "t1" => "01100101011000010110001001100011",
      "t2" => "01100100011001010110000101100010",
      "t3" => "01100011011001000110010101100001",
      "t4" => "01100010011000110110010001100101",
      "t5" => "01100001011000100110001101100100",
      "t6" => "01100101011000010110001001100011",
      "t7" => "01100100011001010110000101100010",
      "t8" => "01100011011001000110010101100001",
      "t9" => "01100010011000110110010001100101",
      "t10" => "01100001011000100110001101100100",
      "t11" => "01100101011000010110001001100011",
      "t12" => "01100100011001010110000101100010",
      "t13" => "01100011011001000110010101100001",
      "t14" => "01100010011000110110010001100101",
      "t15" => "01100001011000100110001101100100",
      "t16" => "00001010000011100000010000001100",
      "t17" => "00001100000010100000111000000100",
      "t18" => "00001100000011000000101000001110",
      "t19" => "11011010110100101100000011010100",
      "t20" => "11011110110110101101001011000000",
      "t21" => "11010100110111101101101011010010",
      "t22" => "01111101011010010100011101100111",
      "t23" => "01110011011111010110100101000111",
      "t24" => "10111001101011011011000110110111",
      "t25" => "11101100110000101001111011001010",
      "t26" => "11110100111011001100001010011110",
      "t27" => "11001010111101001110110011000010",
      "t28" => "01101000001111001001001000011010",
      "t29" => "01000100011010000011110010010010",
      "t30" => "10111111111000011001011110011001",
      "t31" => "11101100010100110010110001111010",
      "t32" => "11110111100011110000011001001111",
      "t33" => "00001011111101111000111100000111",
      "t34" => "10010100110100100110110001010101",
      "t35" => "01100110111011111110000100010110",
      "t36" => "10000000111100010001000101110101",
      "t37" => "11101110001100111100011010100100",
      "t38" => "00111011100101010000000010111110",
      "t39" => "11100110001110111001010100000101",
      "t40" => "10101001111110110110011110000100",
      "t41" => "00101100101010011111101101100010",
      "t42" => "11011100011100110101001110101001",
      "t43" => "10000011000100001010110110000100",
      "t44" => "11110111000010111101111100101000",
      "t45" => "00110100111101110000101111001011",
      "t46" => "11100001110101100111100111011001",
      "t47" => "11101101001010011101001010100001",
      "t48" => "11111100101000100000110010101011",
      "t49" => "01000000110011111101100101010101",
      "t50" => "01001010111100111111100001010000",
      "t51" => "11101110110111010000110100111011",
      "t52" => "00011001010000000010111101101100",
      "t53" => "11101100000110010100000001110100",
      "t54" => "00111010110010100010011110110001",
      "t55" => "01111101111101110010011101010100",
      "t56" => "11001010011001101111000111100100",
      "t57" => "10101011011110010101000000000101",
      "t58" => "00111000111110001010011100001010",
      "t59" => "00100110101110001011010100100001",
      "t60" => "01001001110010011011001100110001",
      "t61" => "00011010011111100111110000101000",
      "t62" => "00000010000011011100111111000100",
      "t63" => "00110011101100010011111100100011",
      "t64" => "11001100100100101111001001101110",
      "t65" => "00001110110011001001011101011110",
      "t66" => "10110001111101001001111000101010",
      "t67" => "11010001110111000001010000000001",
      "t68" => "11001001000111100101100101100100",
      "t69" => "01110100110010010000101001000100",
      "t70" => "01000110111110100001101100100000",
      "t71" => "01011000010000100010001000101100",
      "t72" => "10010101100010110101110110001000",
      "t73" => "10001011111011101101001010110101",
      "t74" => "00110001000011110101000001111011",
      "t75" => "11110001001000110000000100000000",
      "t76" => "00010010011010011110111001001000",
      "t77" => "11011000000100100011001001101000",
      "t78" => "11110010100011000100111100010100",
      "t79" => "11101110101011001100100000110010"
    }

    t16 = '00001010000011100000010000001100'

    assert_equal message_schedule, @p.generate_schedule(message)
    assert_equal t16, @p.generate_schedule(message)['t16']
  end

  def test_preps_message_schedule_for_two_block_message
    skip # will come back to later
    message = two_segment_message
  end

  def test_working_vars_initialize_as_initial_hash
    expected = {
      T: nil,
      a: "01100111010001010010001100000001",
      b: "11101111110011011010101110001001",
      c: "10011000101110101101110011111110",
      d: "00010000001100100101010001110110",
      e: "11000011110100101110000111110000"
    }

    assert_equal expected, @p.initialize_working_vars
  end
end
