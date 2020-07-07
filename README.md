# Vertiv™ Professional Services - Rack PDU Utility Scripts

## Introduction

This project contains scripts to assist in configuration of various rack PDUs over Telnet or SSH using Expect to interact with the device's CLI.

## Content

```bash
├── Level 1
│   ├── Level 2
│   │   ├── Level 3 - 1
│   │   └── Level 3 - 2
├── README.md
├── LICENSE.txt
└── .gitignore
```

#### Authors & Contributors
| Name                 | Organization      | Contact                                                          |
|----------------------|-------------------|------------------------------------------------------------------|
| Richard Hills     | Vertiv             | richard.hills@vertiv.com                |
| Scott Donaldson      | Vertiv            | scott.donaldson@vertiv.com                |
| Philip Cotineau     | Vertiv (Formerly)            | DEFUNCT                |

#### Maintainers

Feedback on function, errata and enhancements is welcome, this can be sent to the following mailbox.

| Name                 | Organization      | Contact                                                          |
|----------------------|-------------------|------------------------------------------------------------------|
| Professional Services     | Vertiv            | global.services.delivery.development@vertiv.com                |

### Instructions

TODO

#### Run

```shell
./rpdu-utility.sh
```

#### Requirements

##### RHEL/CentOS 6.x, 7.x
The following packages are required on RHEL/CentOS/OEL 6.x - 7.x or similar distributions.

```shell
dialog
iputls
expect
```

The packages can be installed with the following command.

```shell
yum install -y dialog iputils expect
```

##### RHEL/CentOS 8.x, Fedora 30+
The following packages are required on RHEL/CentOS/OEL 8.x, Fedora 30+ or similar distributions.

```shell
dialog
iputls
expect
```

The packages can be installed with the following command.

```shell
dnf install -y dialog iputils expect
```

##### Windows

TODO

##### Avocent© Universal Management Gateway

TODO 

