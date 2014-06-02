.. Copyright (c) 2013, Luan Vo Ngoc
.. All rights reserved.
..
.. Redistribution and use in source and binary forms, with or without
.. modification, are permitted provided that the following conditions are met:
..
..     1. Redistributions of source code must retain the above copyright notice,
..        this list of conditions and the following disclaimer.
..     2. Redistributions in binary form must reproduce the above copyright
..        notice, this list of conditions and the following disclaimer in the
..        documentation and/or other materials provided with the distribution.
..
.. Neither the name of Luan Vo Ngoc nor the names of its contributors may be used
.. to endorse or promote products derived from this software without specific
.. prior written permission.
..
.. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
.. AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
.. THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
.. PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
.. BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
.. CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
.. SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
.. INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
.. CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
.. ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
.. POSSIBILITY OF SUCH DAMAGE.

.. include:: /doc/include/add_firewall.inc

- :doc:`/nginx/doc/index` :doc:`/nginx/doc/firewall`
- :doc:`/rsync/doc/index` :doc:`/rsync/doc/firewall`
- :doc:`/ssh/server/doc/index` :doc:`/ssh/server/doc/firewall`

There is 3 ways to communicate to a terracotta server:

dso-port: Port listens for connections from DSO clients.

jmx-port: Port listens for connections from the Terracotta administration 
console.

l2-group-port: Port listens for communication from other servers participating 
in an networked-active-passive setup.

- ``TCP`` ``9510``: dso-port
- ``TCP`` ``9520``: jmx-port
- ``TCP`` ``9530``: l2-group-port