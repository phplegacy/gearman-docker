#!/bin/bash
set -eo pipefail

# Set the number of cpu cores
export NUM_CPUS=`nproc`

CONFIG_FILE='/etc/gearmand.conf'

VERBOSE=${VERBOSE:-INFO}
QUEUE_TYPE=${QUEUE_TYPE:-builtin}

THREADS=${THREADS:-${NUM_CPUS}}
BACKLOG=${BACKLOG:-32}
FILE_DESCRIPTORS=${FILE_DESCRIPTORS:-0}

JOB_RETRIES=${JOB_RETRIES:-0}
ROUND_ROBIN=${ROUND_ROBIN:-0}
WORKER_WAKEUP=${WORKER_WAKEUP:-0}

KEEPALIVE=${KEEPALIVE:-0}
KEEPALIVE_IDLE=${KEEPALIVE_IDLE:-30}
KEEPALIVE_INTERVAL=${KEEPALIVE_INTERVAL:-10}
KEEPALIVE_COUNT=${KEEPALIVE_COUNT:-5}

#String Colors
NC='\033[0;m'      # Default Color
GRN='\033[32;1m'
RED='\033[31;1m'
BLK='\033[30;1m'

# Run custom script before the main docker process gets started
for f in /etc/docker-entrypoint.init.d/*; do
    case "$f" in
        *.sh) # this should match the set of files we check for below
            echo "⚙️ Executing entrypoint.init file: ${f}"
            . $f
            break
            ;;
    esac
done

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

function generate_config() {
	cat <<-__CONFIG_CONTENT__ > "${CONFIG_FILE}"
		--listen=0.0.0.0
		--port=4730
		--log-file=stderr
		--verbose=${VERBOSE}
		--queue-type=${QUEUE_TYPE}
		--threads=${THREADS}
		--backlog=${BACKLOG}
		--job-retries=${JOB_RETRIES}
		--worker-wakeup=${WORKER_WAKEUP}
	__CONFIG_CONTENT__

	if [[ "${FILE_DESCRIPTORS}" != '0' ]]; then
		cat <<-__CONFIG_CONTENT__ >> "${CONFIG_FILE}"
			--file-descriptors=${FILE_DESCRIPTORS}
		__CONFIG_CONTENT__
	fi

	if [[ "${ROUND_ROBIN}" != '0' ]]; then
		cat <<-__CONFIG_CONTENT__ >> "${CONFIG_FILE}"
			--round-robin
		__CONFIG_CONTENT__
	fi

	if [[ ${KEEPALIVE} != '0' ]]; then
		cat <<-__CONFIG_CONTENT__ >> "${CONFIG_FILE}"
			--keepalive
			--keepalive-idle=${KEEPALIVE_IDLE}
			--keepalive-interval=${KEEPALIVE_INTERVAL}
			--keepalive-count=${KEEPALIVE_COUNT}
		__CONFIG_CONTENT__
	fi

	if [[ "$QUEUE_TYPE" == 'mysql' ]]; then
		file_env 'MYSQL_PASSWORD'
		cat <<-__CONFIG_CONTENT__ >> "${CONFIG_FILE}"
			--mysql-host=${MYSQL_HOST:-localhost}
			--mysql-port=${MYSQL_PORT:-3306}
			--mysql-user=${MYSQL_USER:-root}
			--mysql-password=${MYSQL_PASSWORD}
			--mysql-db=${MYSQL_DB:-Gearmand}
			--mysql-table=${MYSQL_TABLE:-gearman_queue}
		__CONFIG_CONTENT__
	fi
}

printf "\n${GRN}--->${NC} 	🚀️️	 Welcome to ${GRN}phplegacy Gearman v.${GEARMAN_VERSION}${NC} container..."
printf "\n${GRN}--->${NC} Docker image build date: ${GRN}${BUILD_DATE}${NC}, fingerprint: ${GRN}${BUILD_FINGERPRINT}${NC}"
printf "\n${GRN}--->${NC} Subscribe to project updates: ${GRN}https://github.com/phplegacy/gearman-docker${NC}\n\n"

gearmand --version
printf "\n"

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- gearmand "$@"
fi

if ! [ -s "${CONFIG_FILE}" ]; then # dont genarate config if current config file is not empty
    generate_config
fi

exec "$@"
