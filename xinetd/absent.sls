{#-
Use of this source code is governed by a BSD license that can be found
in the doc/license.rst file.

Author: Van Diep Pham <favadi@robotinfra.com>
Maintainer: Van Diep Pham <favadi@robotinfra.com>
-#}

xinetd:
  service:
    - dead
  pkg:
    - purged
    - require:
      - service: xinetd
  file:
    - absent
    - name: /etc/xinetd.conf
    - require:
      - pkg: xinetd

/etc/xinetd.d:
  file:
    - absent
    - require:
      - pkg: xinetd
