Introduction to this repository
===============================

Welcome to **Common** repository.

This repository target Linux only. It actually only support Ubuntu 12.04 Precise
LTS. But support for other release of Ubuntu or Debian based distribution can
be easily added.

It hold the low-level salt states for various operating-system services, such
as:

- logging daemon
- package manager
- SSH server
- cron
- logging rotation
- Network time synchronization client and server
- DNS cache server
- sudo
- Simple SMTP client
- screen

Also numerous states for tools used by itself to deploy applications, such as:

- Git
- Mercurial
- SSH client
- sudo
- Python PIP
- Python virtualenv
- SSL keys
- Python
- Ruby

It also contains less generic services that might be used by other applications,
such as:

- RabbitMQ ActiveMQ bus
- Nginx web server
- Memcache daemon
- NodeJS
- uWSGI application server
- Django

Databases SQL or NoSQL, such as:

- Postgresql
- Elasticsearch
- MongoDB

States that protect the server, such as:

- Denyhosts to block bruteforce SSH attacks
- Firewall
- Clamav anti-virus
- OpenVPN to secure communication

States to deploy complex tools that is used to support the Infrastructure in
various ways, such as:

- Graylog2 centralized logging
- Statistic and graphics using Graphite
- Shinken distributed monitoring
- Configuration management using Saltstack
- Sentry for error notification and reporting
- Backup

Standalone daemon state, such as:

- ProFTPd
- Git server

States for integration between operating system:

- Diamond, a daemon that gather statistics on thousands of metrics and send it
  to Graphite server.
- NRPE (Nagios Remote Plugin Executor), the only Nagios component in a state.
  It's called by Shinken server to perform checks.
- Raven client to report error to Sentry
- StatsD, a daemon that receive stats from some application and periodically
  send them to Graphite server.

Others states, such as:

- Salt web UI
- Salt REST API
- Reprepro an APT repository server

States for testing and it's requirements.
More details on this topic in file testing document.

Philosophy
----------

This repository deploy only Open-Source software (OSS), so far. By building a
complete infrastructure on top of OSS guarantee that these states don't
depends on a specific individual or company. The deployed software can be
troubleshoot and fixed internally. If an OSS community still exists around any
software that cause an issue, the community can fix the bug and help to improve
the running infrastructure for free.

If the authors and/or maintainers of that repository aren't available anymore
to support it, anybody can take over it.

All the states had been designed to configure themselves from Salt Pillars data.
Some configuration are hardcoded because they're linked to a specific release of
the component it deploy, as it's still unknown what the upcoming new release
will requires.

The limitation of those states are the limit of the deployed software. Example:
If a component is known to not scale on more than 100 servers. The state will
only be able to achieve a scalable deployment to 100 servers.
If an OSS application contains a bug that affect the infrastructure, the state
can't be blame for it. It's just a recipe that deploy and infrastructure and
manage the configurations.

The states come with highly polished integration between themselves and the
infrastructure support tools. The integration is optional but highly
recommended.

The states and pillars are the documentation! These states try to do everything
requires to have a fully working application. Human intervention is avoided at
all costs.
This allow to only backup the data that is produced by the application, example:
In PostgreSQL it's the dump of all databases. As the configuration files are
managed by the states and pillars, they don't need to be backup. Nor the
binaries, as they're available trough the package manager.
So, well documented states and pillars, can document what the infrastructure is
and how global pieces are plugged together. Thus eliminate most of the documents
requirements and make it very easy to plan a disaster recovery plan.
By eliminating all human intervention on the servers themselves, except for
the data, you remove the "surprise" element of an expected configuration in a
server.

This repository contains only low-levels states. Low-level means that they only
perform changes on the server itself on specific applications or the operating
system itself. This repository alone with pillars, can't even execute salt
``state.highstate`` function. But, each states can be executed trough ``state.sls``.
This repository don't contains business logic, orchestration or integration. It
need to be into an other repository. This allow this **common** repository to
never contains client's specific changes and stays generic and usuable by
everyone. No need to merge changes from one repo to an other one. These states
don't contains undisclosable information.
If a low-level state requires a client's change that can't be shared to everyone
it's kept in the client's specific repository (or repositories).
GitFS feature of Salt allow to have multiple repositories plugged together
without causing any potential conflicts. All repositories content are then,
considered as a single flat merged file-system.

Infrastructure Support
----------------------

Most of the states of that repository are there to fill the requirements to
deploy web application, internal developed software or any commercial closed
source application.

But some of them exists only to support the other components:

- Monitoring:
  - Check that components run as expected.
  - Perform additional validation that are mostly useful when a component don't
    work as expected and someone try to troubleshoot the issue.
  - Notification by email of any problem and their recovery.
  - Web interface to see the actuals problems, check history of a service or an
    host. Or a dashboard that show the status of various system.
  - Business health status, example: a cluster is working as expected if at
    least 2 out of 3 nodes are working. If 2 nodes don't work and only 1 do,
    the status is at Warning and only support team get notification.
    If 3 nodes are down, every one get a notification that the status is Error.
- Centralize into a single place all the logs from all hosts:
  - To provide a single place to look for the information.
  - Create alert based on some rules, such as Linux OOM (Out of Memory).
  - Give access to developers or tester to logs of some hosts.
  - Limit human requirements to log in a server to read the logs, which limit
    the risks for someone to perform live changes on the server that aren't
    tracked by configuration management system.
- Metrics Statistics and graphics:
  - A central dashboard that show graphics on thousands of metrics generated by
    each components of the infrastructure. The most basics one are CPU usage of
    an host. Or individual process memory usage.
  - This complete the monitoring. Monitoring server even use the stats and
    graphs component to store and display it's own performance data.
  - Any internally developed application can be changed to send internal metrics
    too and embedded graphics into it.
- Error reporting:
  - Many states come with integration to an error reporting server, if the
    application allows it. If an internal error happens, the error is reported
    immediately instead of silently lost in the logs.
  - A Linux based infrastructure with a lot of OSS components often come with
    multiple ways to get notification if something goes wrong, such as logs in
    it's own file, logs trough syslog, local email, email trough a remote SMTP
    server, etc. The states in this repository are built to limit those
    communications channels and send them to the error report server to make
    sure that multiple persons can all receive the same error message.
    If an error happens 1000 times in a row, only a single notification is sent
    The error can be acknowledge.
- Configuration Management:
  - Everything is done trough states,
    **even the first salt-master installation!**. No surprise, no undocumented
    installation steps, no results that can't be reproduce.
  - States life-cycles: this repository support multiple version of the states
    to be usable at the same time. A single host can execute the stable version
    of the states, while an testing host can execute an other version that just
    went out of development.

Integration
-----------

Most of the states come with a sub-state that integrate themselves with other
components, such as monitoring (trough Nagios NRPE), statistics and graphs
(trough Diamond) and logging (to filter noise out of logs).

Those sub-states with integration aren't required to install the parent state.
Such as PostgreSQL server state can be deployed without NRPE monitoring checks,
Diamond plugin configuration or client-side backup script.

A lot of other states also directly integrate themselves when they have
native support for technologies, such as built-in Graylog2 support in uWSGI
trough it's GELF plugin. Or trough third party library, such as GrayPY for
Python based application. In those cases, the integration is turned on only
when Salt pillars data contains an expected value.

High-Availability and High-Performance
--------------------------------------

Many states support clustering and the support infrastructure components had
been chosen because they support some form or an other of high-availability
(HA) or high-performance (HP).

Actually, thee HA and/or HP features aren't all turned on in current version of
the states in that repository.

Only the following support both HA and HP:

- Elasticsearch
- RabbitMQ ActiveMQ bus
- Shinken monitoring

The following states will soon have HA support:

- PostgreSQL server

The following states will soon have HA and HP support:

- Graphite: Statistic and graphics
- Graylog2 centralized logging
- MongoDB NoSQL database
- Sentry: error notification and reporting

Once Salt Master will support properly multi-master, the state will support it.

Evolution
---------

The states in this repository are continously improved, fixed, updated (to catch
new version of OSS release). Each states regularly gains additional monitor
checks to verify the health of the application.

The list of states increase as well.

Uninstallation of components
----------------------------

All the states come with it's uninstall equivalent. These are required for
testing purpose. But they're also useful to undo some changes. They're called
"absent" states and they have the standard absent name. Example: PostgreSQL
database server state is ``postgresql.server`` and the uninstallation state is
``postgresql.server.absent``.

Unlike the states that install or create something that often include and
requires other state, the absent only remove itself. I don't try to uninstall
it's dependencies. To revert entirely a server into it's original form before
a component had been installed might requires to run a lot of other absent
states.

Roles
-----

As explained in the philosophy section, the states of that repository don't
hold any business specifics logic.

Who's in charge of integrate that states repository need todefine it's own
*roles* list in it's own state repository.

Roles are simple human understandable definition of what servers can do in,
here is an example list:

- ``monitoring`` server
- ``database`` server
- ``webapp`` (server)
- ``frontend``
- ``backend``
- Developer ``sandbox``
- ``infra`` server that run all the infrastructure support tools

Or simply borrow the name of the low-level state:

- ``shinken`` monitoring host
- ``elasticsearch`` node

Then, for each roles, who's responsible to integration this repository states
to the business requirements need to create one state file per role.
And they need to be under the ``roles`` folder, so the ``frontend`` role will be
in ``roles/frontend/init.sls`` file.
Why not ``roles/frontend.sls`` file? Because it might need additional
configuration files and all roles need to have it's ``absent.sls`` file too. So,
there will be a ``roles/frontend/absent.sls`` file as well.

The role state file contains the specific such as: change DNS value of
``www.example.com`` to point to this server IP address if all the lower-level
states had been applied succesfully.
Or use this other config file instead of the one that was in **common**
repository.