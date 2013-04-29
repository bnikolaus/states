{#
 Remove Nagios NRPE check for Nginx
#}
{% if 'shinken_pollers' in pillar %}
include:
  - nrpe

extend:
  nagios-nrpe-server:
    service:
      - watch:
        - file: /etc/nagios/nrpe.d/nginx.cfg
{% endif %}

/etc/nagios/nrpe.d/nginx.cfg:
  file:
    - absent
