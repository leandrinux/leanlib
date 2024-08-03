.data

  def 
    value = 123,
    another= 234,
    owl = 30

  var 
    number: byte,
    other: word = 255,
    name: string = "Leandro",
    cat: long = 10,
    dog: byte = 15

.code
  mov ax, value   # internally, value is here treated as a literal argument with value 123
  mov cx, other   # other is internally treated as an address argument
  mov dx, cat
  