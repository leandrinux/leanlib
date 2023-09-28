unit 
  lbin;

interface

  {$P+} { enables compatibility between strings of different type }

  const
    C_INVALID_OPCODE = $FFFF;  { invalid instruction code }
    C_INSTRUCTION_COUNT = 28;  { total number of supported instructions }

  function build(const sourceFilename, binaryFilename: string): boolean;

implementation

  uses
    lcommon, xcrt;

  type
    EParameterType = (
      EParameterTypeInmediate,
      EParameterTypeSymbol,
      EParameterTypeAddress,
      EParameterTypeRegister,
      EParameterTypeIndirect,
      EParameterTypeEmpty
    );
   
    TTreeNode = record
      left, right: byte;
      id: TString7;
      code: word;
    end;

    TTree = record
      root: byte;
      nodes: array[1 .. C_INSTRUCTION_COUNT] of TTreeNode;
    end;

    { Pending symbols list }
    PPendingSymbolNode = ^TPendingSymbolNode;
    TPendingSymbolNode = record
        position: TMemoryRange;
        next: PPendingSymbolNode;
    end;

    { Symbols list }
    PSymbolNode = ^TSymbolNode;
    TSymbolNode = record
        id: TString10;
        value: integer;
        pendingList: PPendingSymbolNode;
        next: PSymbolNode;
    end;

  const
    { search binary tree balanced by identifier }   
    C_INSTRUCTION_SET : TTree = (root:16; nodes:(
      (left:00;  right:00;  id:'JP';      code:$2600),
      (left:27;  right:05;  id:'JE';      code:$2200),
      (left:18;  right:26;  id:'OR';      code:$3200),
      (left:00;  right:00;  id:'CMP';     code:$0600),
      (left:10;  right:13;  id:'JMP';     code:$2100),
      (left:08;  right:00;  id:'AND';     code:$3100),
      (left:04;  right:09;  id:'DIV';     code:$0500),
      (left:00;  right:00;  id:'ADD';     code:$0200),
      (left:00;  right:00;  id:'DUMP';    code:$1300),
      (left:12;  right:00;  id:'JL';      code:$2400),
      (left:00;  right:00;  id:'JN';      code:$2700),
      (left:00;  right:00;  id:'JG';      code:$2300),
      (left:11;  right:01;  id:'JNZ';     code:$2800),
      (left:15;  right:00;  id:'MOV';     code:$0100),
      (left:00;  right:00;  id:'LSHIFT';  code:$0700),
      (left:02;  right:25;  id:'JZ';      code:$2500),
      (left:14;  right:03;  id:'MUL';     code:$0400),
      (left:00;  right:00;  id:'NOT';     code:$3300),
      (left:28;  right:22;  id:'STOP';    code:$7700),
      (left:00;  right:00;  id:'RSHIFT';  code:$0800),
      (left:00;  right:00;  id:'READ';    code:$1100),
      (left:23;  right:24;  id:'WRITE';   code:$1200),
      (left:00;  right:00;  id:'SUB';     code:$0300),
      (left:00;  right:00;  id:'XOR';     code:$3400),
      (left:17;  right:19;  id:'PUSH';    code:$4100),
      (left:00;  right:00;  id:'POP';     code:$4200),
      (left:06;  right:07;  id:'CALL';    code:$4300),
      (left:21;  right:20;  id:'RET';     code:$4400)
    ));

  {
    receives the list of symbols and a symbol identifier and returns pointer where a symbol is stored or nil if not found
  }
  function findSymbolNodeWithId(const list: PSymbolNode; const nid: TString10): PSymbolNode;
  var
    node: PSymbolNode;
  begin
    node := list;
    findSymbolNodeWithId := nil;
    if node <> nil then
    begin
      while (node<>nil) and (node^.id < nid) do node := node^.next;
      if (node<>nil) and (node^.id = nid) then findSymbolNodeWithId := node;
    end;
  end;

  { adds an element to the symbols list }
  function addToSymbolList(var list: PSymbolNode; const nid: TString10; value: integer): PSymbolNode;
  var 
    nnode, current, previous: PSymbolNode;
  begin
    new(nnode);
    nnode^.id := nid; 
    nnode^.value := value; 
    nnode^.pendingList := nil; 
    nnode^.next := nil; 
    
    if list = nil then
    begin
      list := nnode;
    end else
    begin
      previous := nil;
      current := list;
      while (current <> nil) and (nnode^.id > current^.id) do
      begin
        previous := current;
        current := current^.next;
      end;
      nnode^.next := current;
      if previous = nil then
        list := nnode
      else
        previous^.next := nnode;
    end;
    addToSymbolList := nnode;
  end;

  { gets a instruction identifier and returns the matching opcode }
  function getOpcode(const instruction: TString7): word;
  var
    b: byte;
  begin
    with C_INSTRUCTION_SET do
    begin
      b := root;
      while (b<>0) and (nodes[b].id <> instruction) do
        if nodes[b].id < instruction then
          b := nodes[b].right
        else
          b := nodes[b].left;
      if b = 0 then
        getOpcode := C_INVALID_OPCODE
      else
        getOpcode := nodes[b].code;
    end;
  end;

  { extracts a token from the input string, removing it and returning it as output }
  procedure extractToken(var input:string; var token:string);
  const
    C_DELIMITERS: set of char = [' ', ',', ':', #9];
  var
    i, l: byte;
  begin
    token := '';
    i := 1; 
    l := length(input);
    while (i <= l) and (input[i] in C_DELIMITERS) do i := i + 1;
    while (i <= l) and not (input[i] in C_DELIMITERS) do
    begin
      token := token + input[i];
      i := i + 1;
    end;
    delete(input, 1, i - 1);
  end;

  { gets a string with a valid parameter and returns its type }
  function getParameterType(parameter: string): EParameterType;
  begin
    if parameter = '' then
      getParameterType := EParameterTypeEmpty
    else
      case parameter[1] of
        '@', '#': getParameterType := EParameterTypeInmediate;
        '$': if isValidHexNumber(copy(parameter, 2, length(parameter) - 1)) then
               getParameterType := EParameterTypeInmediate
             else
               getParameterType := EParameterTypeSymbol;
        '0'..'9': getParameterType := EParameterTypeAddress;
        '[': getParameterType := EParameterTypeIndirect;
        'A'..'Z': if isValidRegister(parameter) then
                    getParameterType := EParameterTypeRegister
                  else
                    getParameterType := EParameterTypeSymbol;
      end;
  end;

  { adds an absolute memory value to the pending list }
  procedure addPendingValue(var pendingList: PPendingSymbolNode; value: integer);
  var 
    node: PPendingSymbolNode;
  begin
    new(node);
    node^.position := value;
    if pendingList <> nil then
      node^.next := pendingList
    else
      node^.next := nil;
    pendingList := node;
  end;

  { gets a symbol node and clears all its pending nodes by replacing in the memory structure }
  procedure clearPendingList(var symbolNode: PSymbolNode; var systemState: TSystemState);
  var 
    aux: PPendingSymbolNode;
  begin
    with symbolNode^ do
      while pendingList <> nil do
      begin
        systemState.memory[pendingList^.position] := symbolNode^.value;
        aux := pendingList^.next;
        dispose(pendingList);
        pendingList := aux;
      end;
  end;

  {
    receives:
      - a line of text representing a sentence to be compiled
      - the system state
      - the full list of symbols
      - the current line number
    returns true is compilation was successful, otherwise returns false
  }
  function compileInstruction( 
    const line: string; 
    var systemState: TSystemState;
    var symbolList: PSymbolNode; 
    var lineNumber: word
  ): boolean;
  var
    parameters: array[1..2] of string;
    types: array[1..2] of word;
    plus: integer;
    command: TString10; 
    lineCopy, aux, decstr: string;  
    opcode: word;  
    parameterValue: ^integer;
    i, b: byte;
    instruction: TInstruction;
    node: PSymbolNode;
  begin
    compileInstruction := true;
    lineCopy := line;
    extractToken(lineCopy, command);
    if command[1] = '*' then
      writeln(line) { line is a comment - outputs it to console }
    else begin
      strUpper(command);
      strupper(lineCopy);
      { first I'll check for the presence of a label or a command }
      if pos(':', line) <> 0 then
      begin
        { this line has a label and it is stored in the command variable }
        node := findSymbolNodeWithId(symbolList, command);
        if node <> nil then
        begin
          if node^.pendingList = nil then
          begin
            writeln('> ERROR: Symbol "', command, '" is being redefined.');
            compileInstruction := false;
          end else
          begin
            { this label was used before and now we clear its pending list }
            node^.value := lineNumber + 1;
            clearPendingList(node, systemState);
          end;
        end else
          addToSymbolList(symbolList, command, lineNumber + 1); { we are defining a new label symbol }
        extractToken(lineCopy, command);
      end;
     { there's no label, so I'll continue. }
     { Identify the command and search for its opcode }
     opcode := getOpcode(command);
     if opcode = C_INVALID_OPCODE then
     begin
       instruction := C_NULL_INSTRUCTION;
       writeln('> ERROR: Invalid opcode ("', command, '")');
       compileInstruction := false;
     end else begin
       { fill up the instruction record }
       for i := 1 to 2 do
       begin

         if i = 1 then 
           parameterValue := @instruction.param1
         else
           parameterValue := @instruction.param2;

         extractToken(lineCopy, parameters[i]);
         if parameters[i] <> '' then
         begin
           aux := parameters[i];
           case getParameterType(aux) of

             EParameterTypeInmediate:
             begin
               types[i] := 0;
               parameterValue^ := strToInt(aux);
             end;
      
             EParameterTypeSymbol:
             begin
               types[i] := 0;
               node := findSymbolNodeWithId(symbolList, aux);
               if node = nil then
               begin
                 node := addToSymbolList(symbolList, aux, -1);
                 addPendingValue(node^.pendingList, systemState.ds + i);
                 parameterValue^ := -1;
               end else
                 { if there's no pending list, then the symbol value is already set }
                 if node^.pendingList = nil then
                   parameterValue^ := node^.value
                 else begin
                   addPendingValue(node^.pendingList, systemState.ds + i);
                   parameterValue^ := -1;
                 end;
             end;

             EParameterTypeAddress: 
             begin
               types[i] := 2;
               parameterValue^ := decToInt(aux);
             end;
             
             EParameterTypeRegister: 
             begin
               types[i] := 1;
               if aux[2] = 'X' then
                 parameterValue^ := hexToInt(aux[1])
               else
                 if aux[2] = 'P' then
                   case aux[1] of
                     'S': parameterValue^ := 6;
                     'I': parameterValue^ := 8;
                     'B': parameterValue^ := 7;
                   end
                 else
                   if aux[1] = 'CC' then
                     parameterValue^ := 9;
             end;
             
             EParameterTypeIndirect:
             begin
               types[i] := 3;
               { we get the code for the specified register }
               if aux[3] = 'X' then
                 parameterValue^ := hexToInt(aux[2])
               else
                 if aux[3] = 'P' then
                   case aux[2] of
                     'S': parameterValue^ := 6;
                     'I': parameterValue^ := 8;
                     'B': parameterValue^ := 7;
                   end
                 else
                   parameterValue^ := 9;
               { if there is a constant present then we get its value }
               aux := aux + lineCopy;
               b := pos(',', aux);
               if b<>0 then delete(aux, b, ord(aux[0])-b+1);
               delete(aux, 1, 4);
               extractToken(aux, decstr);
               if decstr = '' then
                 plus := 0
               else begin
                 plus := 1;
                 if decstr[1] in ['+', '-'] then
                 begin
                   if decstr[1] = '-' then plus := -1;
                   delete(decstr, 1, 1);
                 end;
                 plus := (plus * decToInt(decstr)) shl 4;
               end;
               { we form the value for this parameter and assign it }
               parameterValue^ := parameterValue^ or plus;
             end;
           end; { case end}
         end else begin 
           { if parameter doesn't exist then assign default values }
           parameterValue^ := 0;
           types[i] := 0;
         end
       end; { end of parameter for cycle }
       instruction.opcode := opcode or (types[1] shl 2) or types[2];
     end;
     lineNumber := lineNumber + 1;
     with systemState, instruction do
     begin
       writeln('[', wordToHex(DS), ']  ', wordToHex(opcode), ' ',
         wordToHex(param1),' ', wordToHex(param2), lineNumber:5, ':', lineNumber
       );
       memory[ds] := opcode;
       memory[ds+1] := param1;
       memory[ds+2] := param2;
       ds := ds + 3;
     end;
   end;
  end;

  function build(const sourceFilename, binaryFilename: string): boolean;
  begin
  end;

end.

{RECIBE  : archivo de texto abierto, estructura de memoria y lista de
 simbolos
 DEVUELVE:
 ERR_NULL si la compilacion fue satisfactoria
 ERR_WARN si ocurrio un error leve y la compilacion puede continuar
 ERR_FATAL si ocurrio un error grave y la compilacion debe detenerse
}
Function LeeCabeza(var arch:Text; var lsimb:PTSimNodo; var m:TMem):byte;
var
 ln,cln,t:string;
 b,AuxByte:byte;
begin
 AuxByte:=ERR_NULL;
 readln(arch,cln);
 ln:=cln;
 token(ln,t);
 while (AuxByte<>ERR_FATAL) and (t[1]<>'\') do
 begin
  if t[1]='*' then
   writeln(cln)
  else
  begin
   strupper(ln);
   if (ln<>'') and (pos('EQU',ln)<>0) then
   begin
    strupper(t);
    {Vamos a incluir una constante en la lista de simbolos}
    if findSymbolNodeWithId(lsimb,t)<>nil then
    begin
     AuxByte:=ERR_WARN;
     writeln('> ADVERTENCIA: Identificador duplicado de constante');
    end else
    begin
     while not (ln[1] in ['@','#','$']) do
      delete(ln,1,1);
     addToSymbolList(lsimb,t,ToInt(ln));
    end;
   end;
  end;
  readln(arch,cln);
  if not seekeof(arch) then
  begin
   ln:=cln;
   token(ln,t);
  end else
   AuxByte:=ERR_FATAL;
 end;
 if AuxByte<>ERR_FATAL then
 begin
  {ahora procesamos la linea \\asm}
  while (ln<>'') and not (ln[1] in ['0'..'9']) do
   delete(ln,1,1);
  with m do
  begin
   if ln='' then
   begin
    regs[6]:=200;
    ss:=1800;
   end else
   begin
    regs[6]:=dec2int(ln);
    ss:=2000-regs[6];
   end;
  end;
 end;
 LeeCabeza:=AuxByte;
end;

{RECIBE  : lista de simbolos
 DEVUELVE: TRUE si no hubo simbolos indefinidos, FALSE en caso contrario}
Function ListayLimpiaSimb(var lsimb:PTSimNodo):boolean;
var
 sn:PTSimNodo; pn:PTPenNodo;
begin
 writeln; writeln(' > Lista de s�mbolos:');
 ListayLimpiaSimb:=true;
 while lsimb<>nil do
 begin
  if lsimb^.pend=nil then
   writeln('   ',lsimb^.id,' = ',lsimb^.int)
  else
  begin
   ListayLimpiaSimb:=false;
   writeln(' > ERROR: S�mbolo "',lsimb^.id,'" no definido.');
   while lsimb^.pend<>nil do
   begin
    pn:=lsimb^.pend^.sig;
    dispose(lsimb^.pend);
    lsimb^.pend:=pn;
   end;
  end;
  sn:=lsimb^.sig;
  dispose(lsimb);
  lsimb:=sn;
 end;
end;

{RECIBE  : archivo de codigo fuente (sin), archivo de salida de objeto (sout)
 DEVUELVE: TRUE si no hubo errores en la compilacion, FALSE en caso contrario}
Function Compilar(const sin,sout:string):boolean;
Var
  Mem   :TMem;   {memoria utilizada}
  LSimb :PTSimNodo;
  Arch  :Text;   {archivo asm}
  lin   :string; {linea leida}
  nrolin:word;   {nro de linea leida}
  band :boolean;
  res  :byte;
Begin
  assign(Arch,sin);            {Abro archivo}
  {$I-} Reset(arch); {$I+}
  if IOResult=0 then
  begin
   fillchar(mem,sizeof(mem),0); {inicializo memoria con 0}
   lsimb:=nil; nrolin:=0;
   res:=LeeCabeza(arch,lsimb,mem);
   if res<>ERR_FATAL then {Solo continuamos si no hubo error al leer la cabeza}
   begin
    band:=true;
    while not seekeof(arch) do
    begin
     readln(arch,lin);
     if (lin<>'') then
      band:=IntSent(lin,mem,lsimb,nrolin) and band;
    end;
    band:=ListayLimpiaSimb(lsimb) and band;
    Guardamem(mem,sout);
   end else
   begin
    writeln('> ERROR: El codigo no tiene la firma \\ASM');
    band:=false;
   end;
   close(arch);
  end else
  begin
   band:=false;
   writeln('> ERROR: El archivo "',sin,'" no existe.');
  end;
  Compilar:=band;
end;

end.
