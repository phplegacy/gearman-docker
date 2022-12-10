# Gearman

<p align="center"><a href="https://github.com/phplegacy/gearman-docker"><img src="https://github.com/phplegacy/gearman-docker/raw/master/docs/gearman.png"></a></p>

## Supported gearmand backends

- `builtin` (default)
- `libmemcached`
- `mysql` (using `mariadb-dev`)
- `redis`

## Docker repository
[Docker Hub](https://hub.docker.com/r/legacyphp/gearman)  
`docker pull legacyphp/gearman:latest`

[GitHub Packages](https://github.com/phplegacy/gearman-docker/pkgs/container/gearman-docker)  
`docker pull ghcr.io/phplegacy/gearman-docker:latest`

## Usage

Example: [`docker-compose.yml`](https://github.com/phplegacy/gearman-docker/blob/master/docker-compose.yml)

```bash
docker run --rm -i legacyphp/gearman:latest --help
```

Use `redis` backend and set verbose level to `DEBUG`.

```bash
docker run --rm -i legacyphp/gearman:latest --queue-type=redis --redis-server=192.168.1.1 --redis-port=6379 --verbose=DEBUG
```

## Environment variables

This image includes an entry point that translates environment strings into configuration attributes.  
The following is a list of the strings currently supported:

| Name                | Description                                                                                                                              | Default                         |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------|
| VERBOSE             | Logging level                                                                                                                            | INFO                            |
| QUEUE_TYPE          | Persistent queue type to use                                                                                                             | builtin                         |
| THREADS             | Number of I/O threads to use                                                                                                             | 4                               |
| BACKLOG             | Number of backlog connections for listen                                                                                                 | 32                              |
| FILE_DESCRIPTORS    | Number of file descriptors to allow for the process                                                                                      | Default is max allowed for user |
| JOB_RETRIES         | Number of attempts to run the job before the job server removes it. Default is no limit.                                                 | 0                               |
| ROUND_ROBIN         | Assign work in round-robin order per worker connection                                                                                   | 0                               |
| WORKER_WAKEUP       | Number of workers to wakeup for each job received                                                                                        | 0                               |
| KEEPALIVE           | Enable keepalive on sockets                                                                                                              | 0                               |
| KEEPALIVE_IDLE      | The duration between two keepalive transmissions in idle condition                                                                       | 30                              |
| KEEPALIVE_INTERVAL  | The duration between two successive keepalive retransmissions, if acknowledgement to the previous keepalive transmission is not received | 10                              |
| KEEPALIVE_COUNT     | The number of retransmissions to be carried out before declaring that remote end is not available                                        | 5                               |
| MYSQL_HOST          | Mysql server host                                                                                                                        | localhost                       |
| MYSQL_PORT          | Mysql server port                                                                                                                        | 3306                            |
| MYSQL_USER          | Mysql server user                                                                                                                        | root                            |
| MYSQL_PASSWORD      | Mysql password                                                                                                                           |                                 |
| MYSQL_PASSWORD_FILE | Path to file with mysql password(Docker secrets)                                                                                         |                                 |
| MYSQL_DB            | Database to use by Gearman                                                                                                               | Gearmand                        |
| MYSQL_TABLE         | Table to use by Gearman                                                                                                                  | gearman_queue                   |

You can also inject your version of config file to `/etc/gearmand.conf` as needed.

## Credits

 - [artefactual-labs](https://github.com/artefactual-labs/docker-gearmand) For the original docker image implementation.

## License

The MIT License (MIT). Please see [License File](https://github.com/phplegacy/gearman-docker/blob/master/LICENSE) for more information.

---
If you like this project, please consider giving me a ⭐
