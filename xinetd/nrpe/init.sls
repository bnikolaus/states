{#-
Use of this source code is governed by a BSD license that can be found
in the doc/license.rst file.

Author: Van Diep Pham <favadi@robotinfra.com>
Maintainer: Van Diep Pham <favadi@robotinfra.com>
-#}

include:
  - apt.nrpe

{%- from 'nrpe/passive.jinja2' import passive_check with context %}
{{ passive_check('xinetd') }}
