{#-
Use of this source code is governed by a BSD license that can be found
in the doc/license.rst file.

Author: Bruno Clermont <bruno@robotinfra.com>
Maintainer: Viet Hung Nguyen <hvn@robotinfra.com>

Cleanup useless login prompt on virtual consoles.
-#}
ttys:
  service:
    - dead
    - names:
{% if grains['virtual'] == 'openvzve' %}
      - tty1
{% endif %}
    {% for number in [2, 3, 4, 5, 6] %}
      - tty{{ number }}
    {% endfor %}
