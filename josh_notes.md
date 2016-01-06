Feedback on Sha1 algorithm
==========================

Toni, on things she's interested to get feedabck on:

> 1. test coverage and
> 2. if there are easier ways to implement some of the methods that I wrote
>    for like bitwise exclusive or.
>
> Also, after I was done, I looked up some other solutions and they were all
> very functional programming based so I couldn’t really compare my solution,
> so I’m wondering if I went a little overboard by doing it in OO instead of
> just a straight through program that takes in the original message and
> produces a digest without multiple classes or anything.


Testing
-------

* You had 100% code coverage, so coverage-wise, it's good.  [ref](https://github.com/JoshCheek/SHA-1/commit/682aebf916f32c771db645e960bf56c9e1725c0c)
* There's a lot of tests that are all basically the same, I'd consolidate them and use a generalized name [ref](https://github.com/JoshCheek/SHA-1/commit/836ac9c4d6026de8923da7ec7789e15d316feea4)
  In the one I refactored, it might be worth talking about what happens if you pass it a number that requires more than 8 bits
  (I'd probably make it explode so that I immediately know where the issue is)
* Preprocessor doesn't need to be an object. Notice that it has no instance variables,
  so we don't ever use the instance, we're really using it as a place to stick a bunch
  of methods.  This is what modules are good for :)
  [ref](https://github.com/JoshCheek/SHA-1/commit/bfa4c9b)
* The name of a test is its most important attribute.
  If done well, we can take the test names and they tell us how to think about the thing we're testing.
  So lets see what the test names are telling us about `word_to_binary`

  ```
  $ cat spec/preprocessor_test.rb | grep def | sed -n '/returns/,/entire/p' | tr _ " " | sed 's/  def test//'
  word to binary returns empty string for empty string
  converts lower case letter to binary
  converts different lower case letter to binary
  converts upper case letter to binary
  converts different upper case letter to binary
  converts entire string to binary
  ```

  So one thing to notice is that the "converts different lowercase letter to binary" tests
  aren't telling us anything interesting. They're telling us about the test, not about the
  object being tested.  So lets remove them from the output:

  ```
  word to binary returns empty string for empty string
  converts lower case letter to binary
  converts upper case letter to binary
  converts entire string to binary
  ```

  The "converts entire string to binary" is good, but it's not really
  necessary, it's mostly there because the other tests are very specific.
  If we made the description more general, we could communicate all this information in
  one sentence. "word to binary converts strings to binary". This statement encompasses each of the
  thigs that we're currently saying [ref](https://github.com/JoshCheek/SHA-1/commit/5053e1a).

  Now that's good, but that test is hard to look at and make sense of.
  Look at the amount of repetition. The only thing that's unique to each of the assertions
  is the input value and the output value. Lets build our own assertion to simplify this.

  ```ruby
  def assert_word_to_binary(word, expected_binary)
    assert_equal expected_binary, word_to_binary(word)
  end
  ```

  And then our test can change this

  ```ruby
  assert_word_to_binary "a", "01100001"
  expected = '01100001'
  ```

  To this:

  ```ruby
  assert_equal expected, word_to_binary('a')
  ```

  Which lets us write the test like this.

  ```ruby
  def test_word_to_binary_converts_strings_to_binary
    assert_word_to_binary '',    ''
    assert_word_to_binary 'a',   '01100001'
    assert_word_to_binary 'z',   '01111010'
    assert_word_to_binary 'D',   '01000100'
    assert_word_to_binary 'V',   '01010110'
    assert_word_to_binary 'abc', '011000010110001001100011'
  end
  ```

  The test name doesn't mention details about the test, but rather tells us what the thing we're testing does.
  The assertions are easier to read because we can see the entire barrage of tests we threw at `word_to_binary`,
  all in one place [ref](https://github.com/JoshCheek/SHA-1/commit/402861b).

  At this point, the tests seem pretty redundnat. What do I actually need to hit it with to prove to myself
  that it does what the test name says (converts strings to binary). Probably the empty string,
  because those tend to be weird. And then I have that other one that has "abc", well,
  that one already shows that it can do different letters, so the `"a"`/`"z"` tests aren't
  offering much over this one. If I threw the `"D"` or `"V"` in there, too, that one assertion
  would show that it does all these things. But it gets hard to read that binary string.
  So lets break the string up on the relevant boundaries.

  ```ruby
  def test_word_to_binary_converts_strings_to_binary
    assert_word_to_binary '', ''
    assert_word_to_binary 'abcD', '01100001' +
                                  '01100010' +
                                  '01100011' +
                                  '01000100'
  end
  ```

  Now we notice certain things: the relationship between a and b is that it is 1 bit higher.
  This makes sense, it gives that example more meaning [ref](https://github.com/JoshCheek/SHA-1/commit/9dcbf4dcad00817c0a4a22e54aed800d02a52e2f).

  Of course it brings up another question: what does "binary" mean? Why is that the binary it uses?
  Our test doesn't tell us this. Through an experiment, we deterine that it's the ascii value of the String.
  But that's not quite it, because the ascii value would be "1100001", losing the leading zero.
  So it also padds each character to 8 digits. So lets adjust the test to make this clear.
  We'll rename the test to "word to binary returns a string where each character is replaced
  by its binary". And we'll add this test:

  ```ruby
  def test_the_characters_binary_is_an_8_digit_string_of_1s_and_0s_based_on_its_ascii_value
    ascii_a = '01100001'
    assert_equal 8,   ascii_a.length
    assert_equal "a", ascii_a.to_i(2).chr
    assert_equal ascii_a, word_to_binary("a")
    refute_equal ascii_a, word_to_binary("b")
  end
  ```

  The variable is to make sure we use the same value each time and don't accidentally transcribe
  a 1 or a 0 somewhere. The first test proves that that our string is 8 characters, the second
  that it's the ascii value for `"a"`, now that we've established it has the characteristics
  that the name says it does, we can assert that it's what comes back from `word_to_binary`,
  and then just for sanity, some other character would return some other value [ref](https://github.com/JoshCheek/SHA-1/commit/16c160c).

  Now that we know this, the obvious question is what happens for non-ascii values.
  Eg what does it do for unicode? what does it do for pure binary data.

  So I'd probably add a test to check `"\xFF"` because `"\xFF".bytes.first.to_s(2) # => "11111111"`
  But I'll omit that for now :)

  So in the end, this is what we have to say about `word_to_binary`:

  ```
  $ cat spec/preprocessor_test.rb | tr _ " " | sed -n 's/  def test//p' | sed -n '2,3p'
  word to binary returns a string where each character is replaced by its binary
  the characters binary is an 8 digit string of 1s and 0s based on its ascii value
  ```
* > 2. if there are easier ways to implement some of the methods that I wrote
  >    for like bitwise exclusive or.

  Looking at that method, heres what I notice:

  1. That's some nice recursion!
  1. It's modifying the array (shift) which can bite you in weird ways
  1. It doesn't have a base case for an empty array, so would stack overflow in that situation.
  1. This is a good opportunity to use inject/reduce. Here's what I came up with for that one:

     ```ruby
     num_bits = (arr.first||"").length
     result   = arr.inject(0) { |result, binary| result ^ binary.to_i(2) }
     pad_front_with_zeros num_bits, result.to_s(2)
     ```
  1. I haven't read most of the code and don't know how the algorithm works, but
     here we're having to convert the binary to numbers to work on it, and then back
     to strings. So its possible that the string representation is making more work for us.
     It might be easier to leave it as an integer until some point where we do care about
     the binary value (or not, like I say, I don't know how it works)
     [ref](https://github.com/JoshCheek/SHA-1/commit/77ebd351b216a778b2e4d5b7505fd05028d507ba).
* Unfortunately, not enough time to look at the oo vs functional thing,
  but I wanted to get this to you today :)
