{#- Usage of this is governed by a license that can be found in doc/license.rst -#}

{%- from 'nrpe/passive.jinja2' import passive_check with context %}

include:
  - apt.nrpe
  - openssl.nrpe

{{ passive_check('strongswan.server') }}
