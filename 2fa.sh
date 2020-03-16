#!/bin/bash

CONFIG=~/.2fa/config.sh

function bail () {
	echo ${*}
	exit -1
}

# Test if configuration file is present - if not, write one
test -f ${CONFIG} || {
	cat > ${CONFIG} << EOF
EMAIL=your@email
KEYID=your_key_id
REMOVE_THIS_LINE=please
EOF
	bail "Config file missing, we written a template for you here: ${CONFIG}"
}

# Read configuration
source ${CONFIG}

# Test if configuration is edited
test -z "${REMOVE_THIS_LINE+x}" || bail "Please edit your configuration file (${CONFIG}) and try again..."

# Arguments
NAME=${1}
COMMAND=${2:-view}

test -z "${NAME}" && bail "Usage: ${0} name [view|edit]"

case "${COMMAND}" in
	view)
		FILE=~/.2fa/${NAME}/.key.gpg
		test -f ${FILE} || bail "2FA Missing for ${NAME}"

		# Decrypt token
		TOTP=$(cat ${FILE} |gpg --quiet -u ${KEYID} -r ${EMAIL} -d)

		# Find 2FA code
		echo "2FA code for ${NAME} is:"
		oathtool -b --totp ${TOTP}
		;;
	edit)
		bail "TODO"
		;;
	list)
		find ~/.2fa/ -name \.key.gpg|rev|cut -d"/" -f2|rev
		;;
	*)
		bail "Command not implemented"
		;;
esac
