{#-
Use of this source code is governed by a BSD license that can be found
in the doc/license.rst file.

Author: Bruno Clermont <bruno@robotinfra.com>
Maintainer: Quan Tong Anh <quanta@robotinfra.com>
-#}
nginx_diamond_collector:
  file:
    - absent
    - name: /etc/diamond/collectors/NginxCollector.conf
