{#
 Remove Nagios NRPE check for Shinken arbiter
#}
/etc/nagios/nrpe.d/shinken-nginx.cfg:
  file:
    - absent