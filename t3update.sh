#!/bin/bash

# (c) Copyright
# der-berni

__PROGNAME=$(basename $0)
__SCRIPT_VERSION=13.269

__DATE=`date +"%Y-%m-%d %H:%M"`
__CURDIR=$(dirname $0)
cd ${__CURDIR}

__CONFIG_FILE=
__TYPO_VERSION=
__TYPO_BRANCH=
__TYPO_DIR=

function __newSymlink {
	__LINK=$1
	__POINT=$2
	__TYPE=$3
	if [[ "${__TYPE}" == "ln" ]]; then 
		unlink "${__LINK}" 1>/dev/null 2>&1
	elif [[ "${__TYPE}" == "rm" ]]; then 
		rm -rf "${__LINK}" 1>/dev/null 2>&1
	fi
	
	ln -s ${__POINT} ${__LINK} 1>/dev/null 2>&1
}

while :
do
    case "$1" in
      -p)
	  __TYPO_DIR="$2"
	  shift 2
	  ;;
      -s)
	  __FORCE_VERSION="$2"
	  shift 2
	  ;;
      -h | --help)
	  echo "COMMAND [options] <parameters>"
	  echo "Parameter are mandatory:"
	  echo "-p <path>                     : path of the site root directory"
	  echo "Parameter are optional :"
	  echo "-s <specific version>         : force update to specific version"
	  echo "-h                            : show this help"
	  exit 0
	  ;;
      *)
	  break
	  ;;
    esac
done

echo "**********************************************************************"
echo "TYPO3 Update v.${__SCRIPT_VERSION}"
echo "**********************************************************************"

if [[ -z "${__TYPO_DIR}" ]]; then
	./${__PROGNAME} -h
	exit 0
fi

echo "date                          : ${__DATE}"

if [ -f "${__TYPO_DIR}/t3lib/config_default.php" ]; then
	__CONFIG_FILE="${__TYPO_DIR}/t3lib/config_default.php"
	__TYPO_VERSION=$(cat ${__CONFIG_FILE} | grep "\$TYPO_VERSION =*" | cut -d "'" -f 2);
	__TYPO_BRANCH=$(cat ${__CONFIG_FILE} | grep "'TYPO3_branch'," | cut -d "'" -f 4);
elif [ -f "${__TYPO_DIR}/typo3/sysext/core/Classes/Core/SystemEnvironmentBuilder.php" ]; then
	__CONFIG_FILE="${__TYPO_DIR}/typo3/sysext/core/Classes/Core/SystemEnvironmentBuilder.php"
	__TYPO_VERSION=$(cat ${__CONFIG_FILE} | grep "'TYPO3_version'," | cut -d "'" -f 4);
	__TYPO_BRANCH=$(cat ${__CONFIG_FILE} | grep "'TYPO3_branch'," | cut -d "'" -f 4);
fi

if [ -z "${__CONFIG_FILE}" ]; then
	echo "ERROR                         : TYPO3 configuration not found"
	exit 1
fi

__TYPO3_LATEST=$(wget -qO- http://get.typo3.org/json | grep -Po '"'${__TYPO_BRANCH}'":.*?[^\\]",' | grep -Po '"releases":.*?[^\\]":' | awk -F\" '{print $4}')
__TYPO3_SRC_FILE=typo3_src-${__TYPO3_LATEST}.tar.gz


echo "TYPO3 path                    : ${__TYPO_DIR}"
echo "TYPO3 branch                  : ${__TYPO_BRANCH}"
echo "current TYPO3 release         : ${__TYPO_VERSION}"
echo "latest TYPO3 release          : ${__TYPO3_LATEST}"
if [[ ! -z "${__FORCE_VERSION}" ]]; then
	echo "force update to TYPO3 release : ${__FORCE_VERSION}"
	__TYPO3_LATEST=${__FORCE_VERSION}
	__TYPO3_SRC_FILE=typo3_src-${__TYPO3_LATEST}.tar.gz
fi

if [[ "${__TYPO_VERSION}" != "${__TYPO3_LATEST}" ]]; then
	
	if [[ -z "${__FORCE_VERSION}" ]]; then
		echo "update to TYPO3 release       : ${__TYPO3_LATEST}"
	fi
	
	if [[ ! -d "typo3_src-${__TYPO3_LATEST}" ]]; then
		echo "downloading latest release    : ${__TYPO3_LATEST}"
		wget get.typo3.org/${__TYPO3_LATEST} -O ${__TYPO3_SRC_FILE} 1>/dev/null 2>&1
		
		echo "extracting release            : ${__TYPO3_SRC_FILE}"
		tar xzf ${__TYPO3_SRC_FILE} 1>/dev/null 2>&1 && rm -rf ${__TYPO3_SRC_FILE} 1>/dev/null 2>&1
	fi
	
	echo "checking symlink"

	cd "${__TYPO_DIR}"
	if [[ ! -e "typo3_src" ]]; then 
		__newSymlink "typo3_src" "${__CURDIR}/typo3_src-${__TYPO3_LATEST}"
	else
		if [[ -L "typo3_src" && ! "typo3_src" -ef "${__CURDIR}/typo3_src-${__TYPO3_LATEST}" ]]; then
			__newSymlink "typo3_src" "${__CURDIR}/typo3_src-${__TYPO3_LATEST}" "ln"
		elif [[ -d "typo3_src" ]]; then
			__newSymlink "typo3_src" "${__CURDIR}/typo3_src-${__TYPO3_LATEST}" "rm"
		fi
	fi

	if [[ -L "t3lib" && ! "t3lib" -ef "typo3_src/t3lib" ]]; then
		__newSymlink "t3lib" "typo3_src/t3lib" "ln"
	elif [[ -d "t3lib" ]]; then
		__newSymlink "t3lib" "typo3_src/t3lib" "rm"
	fi

	if [[ -L "typo3" && ! "typo3" -ef "typo3_src/typo3" ]]; then
		__newSymlink "typo3" "typo3_src/typo3" "ln"
	elif [[ -d "typo3" ]]; then
		__newSymlink "typo3" "typo3_src/typo3" "rm"
	fi

	if [[ -L "index.php" && ! "index.php" -ef "typo3_src/index.php" ]]; then
		__newSymlink "index.php" "typo3_src/index.php" "ln"
	elif [[ -f "index.php" ]]; then
		__newSymlink "index.php" "typo3_src/index.php" "rm"
	fi

	echo "TYPO3 update success"
fi

exit 0