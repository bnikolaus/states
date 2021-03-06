{#- Usage of this is governed by a license that can be found in doc/license.rst -#}

{%- from 'nrpe/passive.jinja2' import passive_check with context %}
include:
  - apt.nrpe
  - nrpe
  - rsyslog.nrpe
  - ssl.nrpe

{%- if not salt['pillar.get']('__test__', False) %}
{{ passive_check('openvpn.client') }}
{%- endif %}
