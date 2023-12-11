#!/bin/bash

is_bin_in_path() {
  echo "started is_bin_in_path()"
  builtin type -P "${1}" &> /dev/null
  echo "ended is_bin_in_path()"
}

is_root() {
  echo "started is_root()"
  if [ "${EUID}" -ne 0 ]; then
    error_message "This util need to run as root"
  fi
  echo "ended is_root()"
}

error_message() {
  echo "started error_message()"
  echo "Error: ${1}"
  exit 1
  echo "started error_message()"
}

warning_message() {
  echo "started warning_message()"
  echo "Warning: $1"
  echo "ended warning_message()"
}

load_config_from_env() {
  echo "started load_config_from_env()"
  CONFIG_FILE="/etc/conf/khulnasoftvmenforcer.json"
  if [ ! -f ${CONFIG_FILE} ]; then
    echo "Info: Config File not found, Setting Default Configuration!"
    GATEWAY_ENDPOINT=""
    KHULNASOFT_TOKEN=""
    KHULNASOFT_TLS_VERIFY=false
    KHULNASOFT_ROOT_CA=""
    KHULNASOFT_PUBLIC_KEY=""
    KHULNASOFT_PRIVATE_KEY=""  
  else
    echo "Info: Config File found, loading configuration"
    KHULNASOFT_CONFIG=$(cat ${CONFIG_FILE})
    GATEWAY_ENDPOINT=$(echo ${KHULNASOFT_CONFIG} | jq '.KHULNASOFT_GATEWAY // empty' | sed -e 's/^"//' -e 's/"$//')
    KHULNASOFT_TOKEN=$(echo ${KHULNASOFT_CONFIG} | jq '.KHULNASOFT_TOKEN // empty' | sed -e 's/^"//' -e 's/"$//')
    KHULNASOFT_TLS_VERIFY=$(echo ${KHULNASOFT_CONFIG} | jq '.KHULNASOFT_TLS_VERIFY // empty' | sed -e 's/^"//' -e 's/"$//')
    echo $KHULNASOFT_TLS_VERIFY "---------------------"

    KHULNASOFT_ROOT_CA_PATH=$(echo ${KHULNASOFT_CONFIG} | jq '.KHULNASOFT_ROOT_CA // empty' | sed -e 's/^"//' -e 's/"$//')
    KHULNASOFT_PUBLIC_KEY_PATH=$(echo ${KHULNASOFT_CONFIG} | jq '.KHULNASOFT_PUBLIC_KEY // empty' | sed -e 's/^"//' -e 's/"$//')
    KHULNASOFT_PRIVATE_KEY_PATH=$(echo ${KHULNASOFT_CONFIG} | jq '.KHULNASOFT_PRIVATE_KEY // empty' | sed -e 's/^"//' -e 's/"$//')
    CPU_LIMIT=$(echo ${KHULNASOFT_CONFIG} | jq '.KHULNASOFT_CPU_LIMIT // empty' | sed -e 's/^"//' -e 's/"$//')
    MEMORY_LIMIT=$(echo ${KHULNASOFT_CONFIG} | jq '.KHULNASOFT_MEMORY_LIMIT // empty' | sed -e 's/^"//' -e 's/"$//')
    if ([ -z "${KHULNASOFT_PUBLIC_KEY_PATH}" ] && [ -n "${KHULNASOFT_PRIVATE_KEY_PATH}" ]) || ([ -n "${KHULNASOFT_PUBLIC_KEY_PATH}" ] && [ -z "${KHULNASOFT_PRIVATE_KEY_PATH}" ]); then
      echo "KHULNASOFT_PUBLIC_KEY KHULNASOFT_PRIVATE_KEY values are missing from ${KHULNASOFT_CONFIG}, incase of self-signed certificates KHULNASOFT_ROOT_CA is required"
      exit 1
    fi
    if [ -n "${KHULNASOFT_PUBLIC_KEY_PATH}" ] && [ -n "${KHULNASOFT_PRIVATE_KEY_PATH}" ]; then
      if [ -n "${KHULNASOFT_ROOT_CA_PATH}" ] && [ -e "${KHULNASOFT_ROOT_CA_PATH}" ]; then
        ROOT_CA_FILENAME=$(basename "$KHULNASOFT_ROOT_CA_PATH")
        KHULNASOFT_ROOT_CA="/opt/khulnasoft/ssl/$ROOT_CA_FILENAME"
      fi  
      PUBLIC_KEY_FILENAME=$(basename "$KHULNASOFT_PUBLIC_KEY_PATH")
      PRIVATE_KEY_FILENAME=$(basename "$KHULNASOFT_PRIVATE_KEY_PATH")
      KHULNASOFT_PUBLIC_KEY="/opt/khulnasoft/ssl/$PUBLIC_KEY_FILENAME"
      KHULNASOFT_PRIVATE_KEY="/opt/khulnasoft/ssl/$PRIVATE_KEY_FILENAME"
    fi
    
    if [ -z "${KHULNASOFT_TLS_VERIFY}" ]; then
      echo "Info: KHULNASOFT_TLS_VERIFY var is missing, Setting it to 'false'"
      KHULNASOFT_TLS_VERIFY=false
      KHULNASOFT_ROOT_CA=""
      KHULNASOFT_PUBLIC_KEY=""
      KHULNASOFT_PRIVATE_KEY=""
    fi
    if [ -z "${KHULNASOFT_PUBLIC_KEY_PATH}" ] && [ -z "${KHULNASOFT_PRIVATE_KEY_PATH}" ]; then
      echo "Info: KHULNASOFT_ROOT_CA, KHULNASOFT_PUBLIC_KEY, KHULNASOFT_PRIVATE_KEY  var is missing, Setting it to blank "
      KHULNASOFT_ROOT_CA=""
      KHULNASOFT_PUBLIC_KEY=""
      KHULNASOFT_PRIVATE_KEY=""
    fi    
    if [ -z "${GATEWAY_ENDPOINT}" ] || [ -z "${KHULNASOFT_TOKEN}" ]; then
      echo "Error: Requires \$GATEWAY_ENDPOINT && \$KHULNASOFT_TOKEN to be exposed an ENV variables."
      exit 1
    fi
    if [ -n "${MEMORY_LIMIT}" ]; then
      KHULNASOFT_MEMORY_LIMIT=$(echo `echo "1024*1024*1024*${MEMORY_LIMIT}" | bc -l` | cut -d. -f1)
    fi
    if [ -n "${CPU_LIMIT}" ]; then
      KHULNASOFT_QUOTA_CPU_LIMIT=$(echo `echo 100000*${CPU_LIMIT} | bc -l` | cut -d. -f1)
    fi
  fi
  echo "ended load_config_from_env()"
}

is_it_rhel() {
  echo "started is_it_rhel()"
  cat /etc/*release | grep PLATFORM_ID | grep "platform:el8\|platform:el9" &>/dev/null
  if [ $? -eq 0 ]; then
    echo "Info: This is RHEL 8\9 system. Going to apply SELinux policy module"
    SELINUX_POLICY_MODULE="khulnasoftvme"
    SELINUX_POLICY_MODULE_FILE="${SELINUX_POLICY_MODULE}.pp"
    ## Install
    if [[ ${1} == "1" ]]; then
      SELINUX_POLICY_MODULE_PATH="/usr/share/selinux/targeted/${SELINUX_POLICY_MODULE_FILE}"
      /usr/sbin/semodule -s targeted -X 300 -i ${SELINUX_POLICY_MODULE_PATH} &>/dev/null || :
      echo "Installed policy module ${SELINUX_POLICY_MODULE}"
    ## Upgrade
    else
      /usr/sbin/semodule -l | grep ${SELINUX_POLICY_MODULE} &>/dev/null
      if [ $? -eq 0 ]; then
        echo "Info: Selinux Policy ${SELINUX_POLICY_MODULE} found on upgrade."
      else
        error_message "Unable to find ${SELINUX_POLICY_MODULE} upgrade, aborting installation."
      fi
    fi
  fi
  echo "ended is_it_rhel()"
}

prerequisites_check() {
  echo "started prerequisites_check()"
  load_config_from_env

  is_it_rhel "$@"

  is_root

  if is_bin_in_path runc; then
    echo "Info: runc"
    RUNC_LOCATION=$(which runc)
  elif is_bin_in_path docker-runc; then
    echo "Info: docker-runc"
    RUNC_LOCATION=$(which docker-runc)
  elif is_bin_in_path docker-runc-current; then
    echo "Info: docker-runc-current"
    RUNC_LOCATION=$(which docker-runc-current)
  else
    error_message "runc is not installed on this host"
  fi
  RUNC_VERSION=$(${RUNC_LOCATION} -v | grep runc | awk '{print $3}')
  echo "Info: Detected RunC Version ${RUNC_VERSION}"

  is_bin_in_path docker && warning_message "docker is installed on this host"
  is_bin_in_path crio && warning_message "crio is installed on this host"
  is_bin_in_path containerd && warning_message "containerd is installed on this host"

  is_bin_in_path systemd-run || error_message "systemd is not installed on this host"
  SYSTEMD_VERSION=$(systemd-run --version | grep systemd | awk '{print $2}')
  echo "Info: Detected Systemd Version ${SYSTEMD_VERSION}"

  is_bin_in_path awk || error_message "awk is not installed on this host"
  is_bin_in_path tar || error_message "tar is not installed on this host"
  echo "ended prerequisites_check()"
}

edit_templates_deb() {
  echo "started edit_templates_deb()"
  echo "Info: Creating ${ENFORCER_RUNC_CONFIG_FILE_NAME} file."
  sed "s|HOSTNAME=.*\"|HOSTNAME=$(hostname)\"|;
		s|KHULNASOFT_PRODUCT_PATH=.*\"|KHULNASOFT_PRODUCT_PATH=${INSTALL_PATH}/khulnasoft\"|;
		s|KHULNASOFT_INSTALL_PATH=.*\"|KHULNASOFT_INSTALL_PATH=${INSTALL_PATH}/khulnasoft\"|;
		s|KHULNASOFT_SERVER=.*\"|KHULNASOFT_SERVER=${GATEWAY_ENDPOINT}\"|;
		s|KHULNASOFT_TOKEN=.*\"|KHULNASOFT_TOKEN=${KHULNASOFT_TOKEN}\"|;    
		s|LD_LIBRARY_PATH=.*\"|LD_LIBRARY_PATH=/opt/khulnasoft\"|;
  	s|KHULNASOFT_TLS_VERIFY=.*\"|KHULNASOFT_TLS_VERIFY=${KHULNASOFT_TLS_VERIFY}\"|;
    s|KHULNASOFT_ROOT_CA=.*\"|KHULNASOFT_ROOT_CA=${KHULNASOFT_ROOT_CA}\"|;
    s|KHULNASOFT_PUBLIC_KEY=.*\"|KHULNASOFT_PUBLIC_KEY=${KHULNASOFT_PUBLIC_KEY}\"|;
    s|KHULNASOFT_PRIVATE_KEY=.*\"|KHULNASOFT_PRIVATE_KEY=${KHULNASOFT_PRIVATE_KEY}\"|;
    s|\"limit\"\:.*|\"limit\"\: ${KHULNASOFT_MEMORY_LIMIT}|;
    s|KHULNASOFT_QUOTA_CPU_LIMIT=.*|KHULNASOFT_QUOTA_CPU_LIMIT=${KHULNASOFT_QUOTA_CPU_LIMIT}\",\"KHULNASOFT_ENFORCER_TYPE=host\"|" ${TEMPLATE_DIR}/${ENFORCER_RUNC_CONFIG_TEMPLATE} >${RUNC_TMP_DIRECTORY}/${ENFORCER_RUNC_CONFIG_FILE_NAME}

  echo "Info: Creating ${RUN_SCRIPT_FILE_NAME} file."
  sed "s_{{ .Values.RuncPath }}_${RUNC_LOCATION}_" ${TEMPLATE_DIR}/${RUN_SCRIPT_TEMPLATE_FILE_NAME} >${RUNC_TMP_DIRECTORY}/${RUN_SCRIPT_FILE_NAME} && chmod +x ${RUNC_TMP_DIRECTORY}/${RUN_SCRIPT_FILE_NAME}

  echo "Info: Creating ${ENFORCER_SERVICE_FILE_NAME} file."
  sed "s_{{ .Values.RuncPath }}_${RUNC_LOCATION}_;s_{{ .Values.WorkingDirectory }}_${ENFORCER_RUNC_DIRECTORY}_" ${TEMPLATE_DIR}/${SYSTEMD_TEMPLATE_TO_USE} >${SYSTEMD_TMP_DIR}/${ENFORCER_SERVICE_FILE_NAME}
  echo "ended edit_templates_deb()"
}

systemd_type() {
  echo "started systemd_type()"
  SYSTEMD_IS_OLD=false

  SYSTEMD_TEMPLATE_TO_USE=${ENFORCER_SERVICE_TEMPLATE_FILE_NAME}
  if [ "${SYSTEMD_VERSION}" -lt "236" ]; then
    SYSTEMD_IS_OLD=true
    SYSTEMD_TEMPLATE_TO_USE=${ENFORCER_SERVICE_TEMPLATE_FILE_NAME_OLD}
  fi
  echo "ended systemd_type()"
}

untar() {
  echo "started untar()"
  ENFORCER_RUNC_TAR_FILE_NAME="khulnasoft-host-enforcer.tar"
  echo "Info: Unpacking enforcer filesystem to ${RUNC_FS_TMP_DIRECTORY}."
  tar -xf ${TMP_DIR}/${ENFORCER_RUNC_TAR_FILE_NAME} -C ${RUNC_FS_TMP_DIRECTORY}
  echo "ended untar()"
}

runc_type() {
  echo "started runc_type()"
  ENFORCER_RUNC_CONFIG_TEMPLATE="khulnasoft-enforcer-runc-config.json"
  if [[ ${RUNC_VERSION} == "1.0.0-rc1" ]] ||
    [[ ${RUNC_VERSION} == "1.0.0-rc2" ]] ||
    [[ ${RUNC_VERSION} == 1.0.0-rc2-* ]] ||
    [[ ${RUNC_VERSION} == 1.0.0-rc2_* ]] ||
    [[ ${RUNC_VERSION} == 1.0.0-rc2+* ]] ||
    [[ ${RUNC_VERSION} == 1.0.0-rc2.* ]] ||
    [[ ${RUNC_VERSION} == 1.0.0-rc1-* ]] ||
    [[ ${RUNC_VERSION} == 1.0.0-rc1_* ]] ||
    [[ ${RUNC_VERSION} == 1.0.0-rc1+* ]] ||
    [[ ${RUNC_VERSION} == 1.0.0-rc1.* ]]; then
    ENFORCER_RUNC_CONFIG_TEMPLATE="khulnasoft-enforcer-v1.0.0-rc2-runc-config.json"
  fi
  echo "ended runc_type()"
}

setup_deb_env() {
  echo "started setup_deb_env()"
  INSTALL_PATH="/opt"
  TMP_DIR="/tmp/khulnasoft"
  TEMPLATE_DIR="${TMP_DIR}/templates"
  SYSTEMD_TMP_DIR="${TMP_DIR}/systemd"
  RUNC_TMP_DIRECTORY="${TMP_DIR}/runc"
  RUNC_FS_TMP_DIRECTORY="${TMP_DIR}/fs"
  ENFORCER_RUNC_DIRECTORY="${INSTALL_PATH}/khulnasoft-runc"
  ENFORCER_RUNC_FS_DIRECTORY="${ENFORCER_RUNC_DIRECTORY}/khulnasoft-enforcer"
  SYSTEMD_FOLDER="/etc/systemd/system"
  ENFORCER_SERVICE_FILE_NAME="khulnasoft-enforcer.service"
  ENFORCER_SERVICE_TEMPLATE_FILE_NAME="khulnasoft-enforcer.template.service"
  ENFORCER_SERVICE_TEMPLATE_FILE_NAME_OLD="khulnasoft-enforcer.template.old.service"
  RUN_SCRIPT_FILE_NAME="run.sh"
  RUN_SCRIPT_TEMPLATE_FILE_NAME="run.template.sh"
  ENFORCER_SERVICE_FILE_NAME_PATH="${SYSTEMD_FOLDER}/${ENFORCER_SERVICE_FILE_NAME}"
  ENFORCER_RUNC_CONFIG_FILE_NAME="config.json"
  ENFORCER_SELINUX_POLICY_FILE_NAME="khulnasoftvme.pp"
  KHULNASOFT_QUOTA_CPU_LIMIT=200000
  KHULNASOFT_MEMORY_LIMIT=2791728742
  echo "ended setup_deb_env()"
}

cp_files_deb() {
  echo "started cp_files_deb()"
  cp --remove-destination -r ${RUNC_TMP_DIRECTORY}/. ${ENFORCER_RUNC_DIRECTORY}/
  cp --remove-destination ${SYSTEMD_TMP_DIR}/${ENFORCER_SERVICE_FILE_NAME} ${ENFORCER_SERVICE_FILE_NAME_PATH}
  cp --remove-destination -r ${RUNC_FS_TMP_DIRECTORY}/. ${ENFORCER_RUNC_FS_DIRECTORY}/
  echo "ended cp_files_deb()"
}

create_folder_deb() {
  echo "started create_folder_deb()"
  echo " creating deb folder"
  mkdir ${INSTALL_PATH}/khulnasoft 2>/dev/null
  mkdir ${INSTALL_PATH}/khulnasoft/audit 2>/dev/null
  mkdir ${INSTALL_PATH}/khulnasoft/tmp 2>/dev/null
  mkdir ${INSTALL_PATH}/khulnasoft/data 2>/dev/null
  mkdir ${INSTALL_PATH}/khulnasoft/ssl 2>/dev/null
  if [ -n "${KHULNASOFT_ROOT_CA_PATH}" ] && [ -e "${KHULNASOFT_ROOT_CA_PATH}" ]; then
    cp ${KHULNASOFT_ROOT_CA_PATH} /opt/khulnasoft/ssl
  fi  
  if [ -n "${KHULNASOFT_PUBLIC_KEY_PATH}" ] && [ -n "${KHULNASOFT_PRIVATE_KEY_PATH}" ]; then
    cp ${KHULNASOFT_PUBLIC_KEY_PATH} /opt/khulnasoft/ssl
    cp ${KHULNASOFT_PRIVATE_KEY_PATH} /opt/khulnasoft/ssl
  fi  
  rm -f /opt/khulnasoft/tmp/khulnasoft.log && touch /opt/khulnasoft/tmp/khulnasoft.log
  mkdir -p ${ENFORCER_RUNC_FS_DIRECTORY} 2>/dev/null
  mkdir -p ${TEMPLATE_DIR}
  mkdir -p ${RUNC_TMP_DIRECTORY}
  mkdir -p ${RUNC_FS_TMP_DIRECTORY}
  mkdir -p ${SYSTEMD_TMP_DIR}
  echo "ended create_folder_deb()"
}

start_service() {
  echo "started start_service()"
  echo "Info: Enabling the ${ENFORCER_SERVICE_FILE_NAME} service."
  systemctl enable ${ENFORCER_SERVICE_FILE_NAME}
  echo "Info: Starting the ${ENFORCER_SERVICE_FILE_NAME} service."
  systemctl start ${ENFORCER_SERVICE_FILE_NAME}
  if [ $? -eq 0 ]; then
    echo "Info: VM Enforcer was successfully deployed and started."
  else
    error_message "Unable to start service. please check the logs."
  fi
  echo "ended start_service()"
}

init_common() {
  echo "started init_common()"
  setup_deb_env
  prerequisites_check "$@"
  systemd_type
  runc_type
  create_folder_deb
  echo "ended init_common()"
}

init_deb() {
  echo "started init_deb()"
  # is_upgrade
  if [ "${1}" == "-u" ]; then
    systemctl stop ${ENFORCER_SERVICE_FILE_NAME} >/dev/null 2>&1
    cp_files_deb
    systemctl start ${ENFORCER_SERVICE_FILE_NAME} >/dev/null 2>&1
    return
  fi

  # is_install
  cp_files_deb
  start_service
  echo "ended init_deb()"
}

main() {
  echo "started main()"
  init_common "$@"
  edit_templates_deb
  untar

  init_deb "$@"
  echo "ended main()"
}

bootstrap_args_deb() {
  echo "started bootstrap_args_deb()"
  action="$1"
  echo "action = $action"
  case "$action" in
  "1" | "configure")
    main "$@"
    ;;
  "2" | "upgrade")
    main -u
    ;;
  esac
  echo "ended bootstrap_args_deb()"
}

# execute_by_env() {
#   if [ ! -z "${1}" ]; then
#     if [ -z "${1##*[!0-9]*}" ]; then
#       echo "Error: Invalid Input, Terminating installation."
#       exit
#     fi
#   fi
#   echo "Info: Starting Khulnasoft VM Enforcer deb installation."
#   bootstrap_args_deb "$@"
# }
execute_by_env() {
  echo "started execute_by_env()"
  echo "starting post install @{1}" 
  if [ ! -z "${1}" ]; then
      echo "it is a new install checking ${1##*[!0-9]*}" 
    #if [ -z "${1##*[!0-9]*}" ]; then
    #  echo "Error: Invalid Input, Terminating installation."
    #  exit
    # fi
  fi
  echo "Info: Starting Khulnasoft VM Enforcer deb installation."
  bootstrap_args_deb "$@"
  echo "ended execute_by_env()"
}

execute_by_env "$@"
