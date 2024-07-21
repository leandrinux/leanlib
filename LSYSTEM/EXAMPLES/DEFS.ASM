.data

     def first = 1, second=2, third =3, fourth= 4  
  def fifth = 5

.code
  xor ax, ax
  add ax, first
  add ax, second
  sub ax, third
  add ax, fourth
  add ax, fifth
