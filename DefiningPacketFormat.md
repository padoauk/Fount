Packet definition in fount.yml
=====================================================================

Example
---------------------------------------------------------------------

```
init_db: true
period: 3
port: 7788
packet_name_space: TestPacketNameSpace
packets:
  1:
    name:     Status
    version:  1.0
    cell_csv: public/files/cells00.csv
  2:
    name:     Health
    version:  1.0
    cell_csv: public/files/cells01.csv
```

Syntax
---------------------------------------------------------------------
Rather trivial.
A set of name: version: and cell_csv: , which locates on level 3 of yaml,
is called packet declaration. Each packet declaration is tagged, which locates
on level 2, by an unique number.

Model
---------------------------------------------------------------------
It is assumed, in the above syntax, that a port has 1 to 1 association to
packet name space in which streams of multiple packet formats can be sent.


Cell definition csv
=====================================================================

Example
---------------------------------------------------------------------

```
! Status
# beginning of Header part
version,	B, 1, 0, 0, ,
packet_type,	B, 1, 1, 0, ,     # request or reply
subheader_size,	n, 2, 2, 0, 0x18, # sizeof(sub_header)
```

Syntax
--------------------------------------------------------------------

```
PacketFormat ::= PacketLine Line+
Line ::= ValueLine | Comment 

PacketLine ::= '!' PacketID EOL
PacketID ::= String

Comment ::= ['#' String] EOL

ValueLine ::= Name ',' Type ',' Size ',' BytePos ',' BitPos, [Constant] [',' Comment] EOL |
              '<' INC_FILE_NAME EOL
Name ::= [a-zA-Z] [a-zA-Z0-9_@.:]+
INC_FILE_NAME ::= String
Type ::= 'B' | 'C' | 'n' | 'N' | 's>' | 'l>' | 'q>' | 'g' | 'G' | TypeID
TypeID ::= UInt
Size ::= BitLiteral | ByteLiteral
BitLiteral  ::= UInt  
ByteLiteral ::= UInt ByteUnitSymbol 
ByteUnitSymbol ::= 'B' | 'Byte' | 'Bytes'
BytePos ::= UInt
BitPos ::= 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7
Constant ::= '' | '0b'[0-1]+ | [0-9]+ | '0x'[0-f]+
EOL ::= '\n'
```

Semantics
--------------------------------------------------------------------

### Type
    **B**: bit  array (MSB first)
    **C**: Byte array
    **n**: 16bit unsigned, network byte order
    **N**: 32bit unsigned, network byte order
    **s>**: 16bit signed,  network byte order
    **l>**: 32bit signed,  network byte order
    **q>**: 64bit signed,  network byte order
    **g**:  32bit float,   network byte order
    **G**:  64bit float,   network byte order
    **TypeID**: Custom type definition ID (see Custom Type Definition csv)

### Size
Cell size of the cell in bytes (default) or bits (with suffix of `b`)  (*1)

### BytePos
Location the first byte of cell in the packet (beginning of the location is 0)
BytePos can be empty. See "order of evaluation" for detail.

### BitPos
Location of the first bit in the first byte
When empty (no definition), the default value 0 is applied.
ex) Suppose Size:2 and BitPos:4. Let c be the byte data at location of BytePos. Then following code of C gets the cell data.

```
#define b0000_0011 3  /* mask for Size */
(c >> 4) & b0000_0011 /* masking after bit shift of BitPos bits  */
```

### Constant
Every packet has the specified value. If no constant value, then empty (space only).
Prefix `0b` ''(nothing) and `0x` for binary, decimal and hexadecimal representation
respectively before the value.

### Comments
Lines whose first letter is `#'`or EOL is regarded as comment line.
In Value Lines, `,` (comma) plus text can be optionally appended for comments.

(*1)
Size must be consistent with Type except `B` and `C`.
For the Type `B`, positive integer value can be specified. For `C`, multiples of 8 (bit) can be
specified. In these cases, Size = n * sizeof(Type) for n = 2,3,..., means array of cells.



Custom Type
--------------------------------------------------------------------
Custom Types are used for cells whose value is defined by calculation. Specify class name
which has CustomCellBase as its one of super classes.


Order of evaluation
--------------------------------------------------------------------
### Evaluation of cell value
If a location is defined by more than two cells, like the example below, latter
lines overwrites former lines.

#### ex 1

```
  cellM, C, 1B, 10, 0, 0x01  # => 0x02
  cellN, C, 1B, 10, 0, 0x02  # => 0x02
```

#### ex 2

```
  cellL, C, 1B, 10, 0, 0xFF  # => 0xFA
  cellM, B,  4, 10, 0, 0xA   # => 0xFA
```

#### ex 3

```
  cellL, C, 1B, 10, 0, 0xF0  # => 0xF3
  cellM, B,  2, 10, 0, 0x1   # => 0xF3
  cellN, B,  2, 10, 1, 0x1   # => 0xF3
```

Position evaluation
---------------------------------------------------------------------
When BytePos is not defined (empty), it is the next byte of the last cell define just before.

#### ex 1

```
  cellL, C, 1B, 10, , ,   # BytePos => 10,  as specified
  cellM, C, 2B,   , , ,   # BytePos => 11,  next of cellM
  cellN, C, 1B,   , , ,   # BytePos => 13,  next of last byte that cellM occupies
```

#### ex 2

```
  CellL, C, 1B, 10, , ,   # BytePos => 10
  CellM, B,  2,   , , ,   # BytePos => 11
  CellN, B,  4,   ,6, ,   # BytePos => 12,  4bits@BytePos:12, 2bits@BytePos:13
  CellO, C, 1B,   , , ,   # BytePos => 14
```

