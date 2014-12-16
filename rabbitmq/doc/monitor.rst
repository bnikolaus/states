Monitor
=======

.. |deployment| replace:: rabbitmq

.. warning::

   In this document, when refer to a pillar key ``pillar_prefix``
   means ``rabbitmq``

Mandatory
---------

rabbitmq_procs
~~~~~~~~~~~~~~

:doc:`/rabbitmq/doc/index` daemon is an
`AMQP <http://en.wikipedia.org/wiki/Advanced_Message_Queuing_Protocol>`__ broker.

.. include:: /nrpe/doc/check_procs.inc

.. _monitor-rabbitmq_management_port:

rabbitmq_management_port
~~~~~~~~~~~~~~~~~~~~~~~~

:doc:`/rabbitmq/doc/index` `Management Port <http://previous.rabbitmq.com/v3_1_x/management.html>`__ is open.

.. _monitor-rabbitmq_amqp_port:

rabbitmq_amqp_port
~~~~~~~~~~~~~~~~~~

:doc:`/rabbitmq/doc/index` AMQP Port is open and can be accessed locally.

.. _monitor-rabbitmq_amqp_port_remote:

rabbitmq_amqp_port_remote
~~~~~~~~~~~~~~~~~~~~~~~~~

:doc:`/rabbitmq/doc/index` AMQP Port is open and can be reached from
Internet.

.. include:: /nginx/doc/monitor.inc

Optional
--------

.. include:: /nginx/doc/monitor_ssl.inc