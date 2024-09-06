# TStream Class

*UStream Unit*

The TStream class is an abstraction used for devices or media which are capable of reading and writing binary or text info.

This is a very versatile class that is inherited by classes that provide seamless access to memory, files, or devices like the serial port, the keyboard and the screen. It makes it easy to move around information from disk to screen or from different areas of memory, as well as working around the 64K segment memory limit.

### Initialization

This class is not intended to be initialized directly. You should define your own class based on this one and create instances of that class instead.

### Methods

`function read(buffer: pointer; count: word): word; virtual;`

Reads *count* bytes from the stream into the specified *buffer*. The function returns the actual number of bytes that were read, since there's a chance that the stream ended before the requested *count* was reached. 

---
`procedure write(buffer: pointer; count: word); virtual;`

Writes *count* bytes from *buffer* into the stream

---
`procedure seek(pos: longint); virtual;`

Relocates the internal cursor position of the stream. The position moves forward each time info is read or written to the stream. 

--- 
`function getPosition: longint; virtual;`

Returns the current cursor position of the stream.

---
`function isEOF: boolean; virtual;`

Returns true if the end of the stream has been reached

---
`function getSize: longint; virtual;`

Returns the size of the stream in bytes. 

---
`function isReadOnly: boolean; virtual;`

Returns true if the stream is read-only and false if writing is allowed

---
`procedure copyTo(stream: PStream; count: longint);`

Copies a block of data of size *count* from the current position into the specified *stream*.

---
`procedure copyAllTo(stream: PStream);`

Copied the entire contents of the stream, from beginning to end, into the specified stream

---
`procedure writeln(line: string);`

Writes into the stream a line of text ending with a carry return and line feed (CRLF) sequence of bytes

---
`procedure writestr(str: string);`

Writes the specified string into the stream

--- 
`procedure writepchar(str: string);`

Writes a Pascal string as a null terminated string into the stream

---
`function readUntilChar(c: char): string;`

Reads and returns a string from the stream until the specified character is found or the maximum string length is reached. Useful for reading null-terminated strings.

---
`function readln: string;`

Reads from the current stream position a line of text ending in a CRLF sequence

---
`function readpchar: string;`

Reads a null-terminated string from the current position of the stream and returns it as a Pascal string

---
`function getChecksum: longint;`

Returns a 32-bit checksum based on the contents of the stream
