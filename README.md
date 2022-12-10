# Configuration utility for Syncthing

[![Latest release](https://img.shields.io/github/v/release/hansmi/stsetup)][releases]
[![Release workflow](https://github.com/hansmi/stsetup/actions/workflows/release.yaml/badge.svg)](https://github.com/hansmi/stsetup/actions/workflows/release.yaml)

Manipulate [Syncthing](https://syncthing.net/)'s configuration structure from
the command line using a [jq](https://stedolan.github.io/jq/) filter.

Syncthing provides the `syncthing cli config` subcommand for making
configuration changes (e.g.
`syncthing cli config options start-browser set false`). It works well for most
options. Modifying lists of items, e.g. the relay addresses, is more
complicated: items can be added or removed one at a time and there's no command
to replace or clear the list at once.

This is where `stsetup` steps in. It fetches the whole configuration using the
[`/rest/config` API endpoint](https://docs.syncthing.net/rest/config.html),
also used by the aforementioned `cli config` subcommand, applies the `jq`
filter, and then uploads the configuration again. If a restart is required to
apply the changes made it's also triggered and waited for.


## Usage

Syncthing must be installed and configured to be automatically restarted by
a daemon or process control system (e.g. [systemd](https://systemd.io/) or
[supervisord](http://supervisord.org/)) upon exit.

```shell
$ cat >myconfig.jq <<'EOF'
.options += {
  alwaysLocalNets: ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"],
  keepTemporariesH: (3 * 24),
}
EOF

$ stsetup -v myconfig.jq
```

See the `-h` output for more options.

Variables provided to the `jq` filter:

| Name | Description |
| --- | --- |
| `local_device_id` | Device ID of the local instance. |

Example filter using `local_device_id` to set the device name from an
environment variable:

```jq
.devices += [] |
(.devices[] | select(.deviceID == $local_device_id)) += {
  name: env.SYNCTHING_NAME,
  paused: false,
}
```

`stsetup` can be invoked automatically using a systemd service override (e.g.
`/etc/systemd/user/syncthing.service.d/override.conf`):

```dosini
[Service]
ExecStartPost=/usr/bin/stsetup /usr/local/share/syncthing/config.jq
```


## Installation

The code is written as a [Bash](https://www.gnu.org/software/bash/) script
using the `jq`, `curl` and `xmllint` programs. The auxiliary `find_unused_port`
program requires Python 3.x.

Pre-built packages are provided for [all releases][releases]:

* Debian/Ubuntu (`.deb`)
* Alpine Linux (`*.apk`)


[releases]: https://github.com/hansmi/stsetup/releases/latest

<!-- vim: set sw=2 sts=2 et : -->
