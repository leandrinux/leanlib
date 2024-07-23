.data

  def 
    value = 123,
    another= 234

  var 
    number: byte

  def owl=30

  var 
    other: word = 255

  var 
    cat: long = 10,
    dog: byte = 15

.code
  mov ax, value   # internally, value is here treated as a literal argument with value 123
  mov cx, other   # other is internally treated as an address argument
  