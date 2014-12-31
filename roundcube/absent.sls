{#-
Use of this source code is governed by a BSD license that can be found
in the doc/license.rst file.

Author: Viet Hung Nguyen <hvn@robotinfra.com>
Maintainer: Viet Hung Nguyen <hvn@robotinfra.com>
-#}
{%- set version = "1.0.1" %}
{% set roundcubedir = "/usr/local/roundcubemail-" + version %}

{#-
  Can't uninstall the following as they're used elsewhere
php5-pgsql:
  pkg:
    - purged

roundcube_password_plugin_ldap_driver_dependency:
  pkg:
    - purged
    - name: php-net-ldap2
#}

{{ roundcubedir }}:
  file:
    - absent

/etc/nginx/conf.d/roundcube.conf:
  file:
    - absent

roundcube-uwsgi:
  file:
    - absent
    - name: /etc/uwsgi/roundcube.yml

roundcube:
  user:
    - absent
    - require:
      - file: roundcube-uwsgi
  file:
    - absent
    - name: /var/lib/roundcube
    - require:
      - user: roundcube

{%- for suffix in ('', '-stats') %}
/var/lib/uwsgi/roundcube{{ suffix }}.sock:
  file:
    - absent
    - require:
      - file: roundcube-uwsgi
{%- endfor -%}
