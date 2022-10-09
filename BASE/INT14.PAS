{
  INT 14 - BIOS Asynchronous Communications Services
  Built with info from https://stanislavs.org/helppc/int_14.html
  2022 LRT
}
unit
  int14;

interface

  type
    ECOMPort = ( COM1, COM2, COM3, COM4 );

    ECOMParity = ( EParityNone, EParityOdd, EParityEven );

    ECOMData = ( EData5, EData6, EData7, EData8 );

    ECOMStop = ( EStop1, EStop2 );

    ECOMBaud = (
      EBaud110,
      EBaud150,
      EBaud300,
      EBaud600,
      EBaud1200,
      EBaud2400,
      EBaud4800,
      EBaud9600,
      EBaud19200
    );

  procedure initCOM(port: ECOMPort; baud: ECOMBaud; data: ECOMData; stop: ECOMStop; parity: ECOMParity );

implementation

  procedure initCOM(port: ECOMPort; baud: ECOMBaud; data: ECOMData; stop: ECOMStop; parity: ECOMParity); assembler;
  asm
    mov ah, 4
    mov al, 0
    mov bh, parity
    mov bl, stop
    mov ch, data
    mov cl, baud
    mov dh, 0
    mov dl, port
    int 14h
  end;

end.