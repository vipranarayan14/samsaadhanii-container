# Notes

### Why `apt-get` instead of `apt`?

- `apt` is meant for terminal.
- For script installation, `apt-get` is recommended.
- Ref: [Askubuntu](https://askubuntu.com/a/990838) & [apt(8) manpage](http://man.he.net/?topic=apt&section=8)

### Why `--no-install-recommends` in `apt`?

- To avoid installing unnecessary pkgs and thereby, reduce image build time.
- Reduces build image size by ~260MB.

### Why `default-jdk-headless` instead of `default-jdk`?

- To avoid installing unnecessary GUI dependencies by latter and thereby, reduce image build time.
- The former is ~140MB smaller than latter.

### Why install `libfl-dev`?

- `--no-install-recommends` skips it.
- flex needs it.
- Otherwise, throws error `/usr/bin/ld: cannot find -ll` during `make` in scl.

### Why remove `/var/lib/apt/lists/*` files?

- To reduce image size.
- Done by official Dockerfiles:
    - [Dockerfile for Go](https://github.com/docker-library/golang/blob/30403f1c144bf7773508cfbab5de09ecf4dbddf9/1.19/bullseye/Dockerfile)
    - [Dockerfile for Python](https://github.com/docker-library/python/blob/4819fb8174cf33a168868720a6445b0d36f743f9/3.12-rc/bullseye/Dockerfile)

### Why remove git folders?

To reduce image size (scl git folder size is 250M)

