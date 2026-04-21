#! /bin/sh

if [ $(uname -m) = "armv7l" ]; then
	ARCH="ARM32"; 
else 
	ARCH="AMDx64"; 
fi

if [ "${AUTO_UPDATE}" = true ]; then
	
	echo "UPDATE JACKETT"

	JACKETT_VERSION=$(cat /etc/jackett/jackett_version)
	JACKETT_VERSION_NEW=$(curl -k -sX GET "https://api.github.com/repos/Jackett/Jackett/releases/latest" | tac | awk '/tag_name/{print $4;exit}' FS='[""]')
	RESULT=$?
	
	if [[ ${RESULT} = 0 ]] && [ -n "$JACKETT_VERSION_NEW" ] && [[ "${JACKETT_VERSION_NEW}" != *"error"* ]] && [[ "${JACKETT_VERSION_NEW}" != "${JACKETT_VERSION}" ]] ; then
		echo "NEW VERSION AVAILABLE: ${JACKETT_VERSION_NEW}"
		
		rm -rf /opt/jackett
		mkdir -p /opt/jackett
		curl -k -o /tmp/jackett.tar.gz -L https://github.com/Jackett/Jackett/releases/download/$JACKETT_VERSION_NEW/Jackett.Binaries.LinuxMusl$ARCH.tar.gz
		tar xf /tmp/jackett.tar.gz -C /opt/jackett --strip-components=1
		
		export JACKETT_VERSION_NEW
		
		echo $JACKETT_VERSION_NEW > /etc/jackett/jackett_version
	else
		echo "NO NEW VERSION AVAILABLE"
	fi
	
	#touch ${JACKETT_UPDATED_FILE}
fi
