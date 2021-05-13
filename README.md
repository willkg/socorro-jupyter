# socorro-jupyter

This is a Jupyter Lab environment that includes some convenience bits for
working with Crash Stats.

# Requirements

1. docker
2. docker-compose
3. GNU make

# Usage

To run Jupyter locally and store notebook data in the current directory
(it's in `work/` in the container):

```
$ make run
```

To run a shell in the Jupyter Docker container:

```
$ make shell
```

# References

https://jupyter-docker-stacks.readthedocs.io/en/latest/

https://crash-stats.mozilla.org/api/
