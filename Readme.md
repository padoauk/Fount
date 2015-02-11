What is Fount ?
============================================================
Fount is a TCP packet generating application framework. The motivation of design and development of Fount is
testing communication software for custom packet format.

Features
============================================================
- When a client program connects to defined TCP port, Fount application generates and sends packets periodically to the client.
If many clients connects to a Fount application, all of them receives same packets.
- Formats of packet to be generated can be defined in csv files. Syntax and semantics of the csv is described in DefiningPacketFormat.md.
- Values of packets can be modified at runtime by using Web GUI on Ruby on Rails.
- It is possible to have, for example, time of packet generation or sequence counter in certain part of packets. In general, following
the Custom Type Cell definition of Fount, values of specific parts can be defined by program.
- Length (or size) of Custom Type Cell can change at runtime.

Examples
============================================================
Fount applications are customized by `fount.yml` and packet format definition csv files. See the one in the source tree for detail.


Author
============================================================
Fount is created by Toshinao Ishii <padoauk@google.com>.

License
============================================================
Redistribution and use of Fount can be done following the FreeBSD Copyright.

Copyright
============================================================
Copyright (C) 2015 Toshinao Ishii. All Rights Reserved.
