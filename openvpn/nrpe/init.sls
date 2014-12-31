{#-
Use of this source code is governed by a BSD license that can be found
in the doc/license.rst file.

Author: Bruno Clermont <bruno@robotinfra.com>
Maintainer: Viet Hung Nguyen <hvn@robotinfra.com>
-#}
{%- from 'nrpe/passive.jinja2' import passive_check with context %}
include:
  - apt.nrpe
  - nrpe
  - rsyslog.nrpe

{{ passive_check('openvpn') }}
