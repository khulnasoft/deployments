#!/usr/bin/env bash

usage() {
  cat <<EOF

Usage:
    sudo ./install_vme.sh [flags]

Flags:
    -v, --version string         Khulnasoft Enforcer version
    -g, --gateway string         Khulnasoft Gateway address
    -t, --token string           Khulnasoft Enforcer token

Download Mode Flags (Optional):
    -d, --download	download artifacts from khulnasoft
    -u, --khulnasoft-username string	Khulnasoft username
    -p, --khulnasoft-password string	Khulnasoft password
TLS verify Flag (Optional):
    -tls, --khulnasoft-tls-verify  khulnasoft_tls_verify
    --rootca-file                 path to root CA certififate (Incase of self-signed certificate otherwise --rootca-file is optional )
    NOTE: --rootca-file certificate value must be same as that is used to generate Gateway certificates
    --publiccert-file             path to Client public certififate
    --privatekey-file             path to Client private key
CPU & memory limits (Optional):
    --memory-limit                enforcer memory limit in Gb. default: 2.6
    --cpu-limit                   enforcer cpu limit in cores. default: 2

EOF

}

is_bin_in_path() {
  builtin type -P "${1}" &>/dev/null
}

is_root() {
  if [ "${EUID}" -ne 0 ]; then
    error_message "This util need to run as root"
  fi
}

error_message() {
  echo "Error: ${1}"
  exit 1
}

warning_message() {
  echo "Warning: $1"
}

load_config_from_env() {
  if [ -z "${ENFORCER_VERSION}" ] || [ -z "${GATEWAY_ENDPOINT}" ] || [ -z "${TOKEN}" ]; then
    usage
    exit 1
  fi
  if [ -z "${KHULNASOFT_TLS_VERIFY}" ]; then
    echo "Info: KHULNASOFT_TLS_VERIFY var is missing, Setting it to 'false'"
    KHULNASOFT_TLS_VERIFY=false
  fi
  if [ -z "${KHULNASOFT_PUBLIC_KEY_PATH}" ] && [ -z "${KHULNASOFT_PRIVATE_KEY_PATH}" ]; then
    echo "Info: KHULNASOFT_ROOT_CA, KHULNASOFT_PUBLIC_KEY, KHULNASOFT_PRIVATE_KEY  var is missing, Setting it to blank "
    KHULNASOFT_ROOT_CA=""
    KHULNASOFT_PUBLIC_KEY=""
    KHULNASOFT_PRIVATE_KEY=""
  fi
  if ([ -z "${KHULNASOFT_PUBLIC_KEY_PATH}" ] && [ -n "${KHULNASOFT_PRIVATE_KEY_PATH}" ]) || ([ -n "${KHULNASOFT_PUBLIC_KEY_PATH}" ] && [ -z "${KHULNASOFT_PRIVATE_KEY_PATH}" ]); then
    echo "tls options values missing, required options: --publiccert-file <value> --privatekey-file <value>  --khulnasoft-tls-verify <value>, incase of self-signed certificates  --rootca-file <value> is required "
    usage
    exit
  fi    
  if [ "${DOWNLOAD_MODE}" == "true" ]; then
    if [ -z "${KHULNASOFT_USERNAME}" ] || [ -z "${KHULNASOFT_PWD}" ]; then
      usage
      exit 1
    fi
    is_bin_in_path curl || error_message "curl is not installed on this host"
  fi
  if [ -n "${KHULNASOFT_MEMORY_LIMIT}" ]; then
    KHULNASOFT_MEMORY_LIMIT=$(echo `echo "1024*1024*1024*${KHULNASOFT_MEMORY_LIMIT}" | bc -l` | cut -d. -f1)
  fi
  if [ -n "${KHULNASOFT_CPU_LIMIT}" ]; then
    KHULNASOFT_QUOTA_CPU_LIMIT=$(echo `echo 100000*${KHULNASOFT_CPU_LIMIT} | bc -l` | cut -d. -f1)
  fi
}

is_it_rhel() {
  cat /etc/*release | grep PLATFORM_ID | grep "platform:el8\|platform:el9" &>/dev/null

  if [ $? -eq 0 ]; then
    echo "Info: This is RHEL 8\9 system. Going to download and apply SELinux policy module"
    echo "Info: Downloading SELinux policy module"
    curl -s -o khulnasoftvme.te https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/enforcers/vm_enforcer/rpm/selinux/khulnasoftvme/khulnasoftvme.te
    curl -s -L -o khulnasoftvme.pp https://github.com/khulnasoft/deployments/raw/2022.4/enforcers/vm_enforcer/rpm/selinux/khulnasoftvme/khulnasoftvme.pp
    if [ ! -f "${ENFORCER_SELINUX_POLICY_FILE_NAME}" ]; then
      error_message "Unable to locate ${ENFORCER_SELINUX_POLICY_FILE_NAME} on current directory"
    fi
    echo "Info: Applying SELinux policy module"
    semodule -i ${ENFORCER_SELINUX_POLICY_FILE_NAME}
  fi
}

is_it_fedora() {
  cat /etc/*release | grep PLATFORM_ID | grep "platform:f3" &>/dev/null
  if [ $? -eq 0 ]; then
    echo "Info: This is Fedora system. Going to download and apply SELinux policy module"
    echo "Info: Downloading SELinux policy module"
    curl -s -o fcos_khulnasoftvme.te https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/enforcers/vm_enforcer/rpm/selinux/khulnasoftvme/fcos_khulnasoftvme.te
    curl -s -L -o fcos_khulnasoftvme.pp https://github.com/khulnasoft/deployments/raw/2022.4/enforcers/vm_enforcer/rpm/selinux/khulnasoftvme/fcos_khulnasoftvme.pp

    if [ ! -f "fcos_khulnasoftvme.pp" ]; then
      error_message "Unable to locate fcos_khulnasoftvme.pp on current directory"
    fi
    echo "Info: Applying SELinux policy module"
    semodule -i fcos_khulnasoftvme.pp
  fi
}

check_arch() {
  # In internal storage artifact stored per architecture
  arch_suffix=""
  if [ "${DEV_INSTALL}" != "true" ]; then
    arch=$(uname -m)
    arch_suffix=".$arch"
  fi
  ENFORCER_VERSION_FILE="$ENFORCER_VERSION$arch_suffix"
}


prerequisites_check() {
  load_config_from_env
  check_arch
  is_root

  is_it_rhel "$@"
  is_it_fedora "$@"


  if is_bin_in_path runc; then
    RUNC_LOCATION=$(which runc)
  elif is_bin_in_path docker-runc; then
    RUNC_LOCATION=$(which docker-runc)
  elif is_bin_in_path docker-runc-current; then
    RUNC_LOCATION=$(which docker-runc-current)
  else
    error_message "runc is not installed on this host"
  fi
  RUNC_VERSION=$(${RUNC_LOCATION} -v | grep runc | awk '{print $3}')
  echo "Detected RunC Version ${RUNC_VERSION}"

  is_bin_in_path docker && warning_message "docker is installed on this host"
  is_bin_in_path crio && warning_message "crio is installed on this host"
  is_bin_in_path containerd && warning_message "containerd is installed on this host"

  is_bin_in_path systemd-run || error_message "systemd is not installed on this host"
  SYSTEMD_VERSION=$(systemd-run --version | grep systemd | awk '{print $2}')
  echo "Detected Systemd Version ${SYSTEMD_VERSION}"

  is_bin_in_path awk || error_message "awk is not installed on this host"
  is_bin_in_path tar || error_message "tar is not installed on this host"
  is_bin_in_path bc || error_message "bc is not installed on this host"
}

is_flag_value_valid() {
  [ -z "$2" ] && error_message "Value is missing. please set $1 [value]"
  flags=("-v" "--version" "-u" "--khulnasoft-username" "-p" "--khulnasoft-password" "-t" "--token" "-g" "--gateway" "-tls" "--khulnasoft-tls-verify" "--rootca-file" "--publiccert-file" "--privatekey-file" "-f" "--tar-file" "-c" "--config-file" "-i" "--install-path" "--memory-limit" "--cpu-limit")
  for flag in "${flags[@]}"; do
    if [ "${flag}" == "$2" ]; then
      error_message "Value is missing. please set $1 [value]"
    fi
  done
}

get_templates_online() {

  curl -s -o ${ENFORCER_SERVICE_TEMPLATE_FILE_NAME} https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/enforcers/vm_enforcer/templates/khulnasoft-enforcer.template.service
  curl -s -o ${ENFORCER_SERVICE_TEMPLATE_FILE_NAME_OLD} https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/enforcers/vm_enforcer/templates/khulnasoft-enforcer.template.old.service
  curl -s -o ${RUN_SCRIPT_TEMPLATE_FILE_NAME} https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/enforcers/vm_enforcer/templates/run.template.sh
  curl -s -o ${ENFORCER_RUNC_CONFIG_TEMPLATE} https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/enforcers/vm_enforcer/templates/khulnasoft-enforcer-runc-config.json
  
}

get_templates_local() {
  if [ ! -f "${ENFORCER_SERVICE_TEMPLATE_FILE_NAME}" ]; then
    error_message "Unable to locate ${ENFORCER_SERVICE_TEMPLATE_FILE_NAME} on current directory"
  fi
  if [ ! -f "${ENFORCER_SERVICE_TEMPLATE_FILE_NAME_OLD}" ]; then
    error_message "Unable to locate ${ENFORCER_SERVICE_TEMPLATE_FILE_NAME_OLD} on current directory"
  fi
  if [ ! -f "${RUN_SCRIPT_TEMPLATE_FILE_NAME}" ]; then
    error_message "Unable to locate ${RUN_SCRIPT_TEMPLATE_FILE_NAME} on current directory"
  fi
}

get_app_online() {

  ENFORCER_RUNC_TAR_FILE_URL="https://download.khulnasoft.com/host-enforcer/${ENFORCER_VERSION}/${ENFORCER_RUNC_TAR_FILE_NAME}"
  if [ "${DEV_INSTALL}" == "true" ]; then
  	ENFORCER_RUNC_TAR_FILE_URL="https://download.khulnasoft.com/internal/host-enforcer/${ENFORCER_VERSION}/${ENFORCER_RUNC_TAR_FILE_NAME}"	
  fi
  
  ENFORCER_RUNC_CONFIG_URL="https://download.khulnasoft.com/host-enforcer/${ENFORCER_VERSION}/${ENFORCER_RUNC_CONFIG_TEMPLATE}"
  ENFORCER_RUNC_CONFIG_URL_DEV="https://download.khulnasoft.com/internal/host-enforcer/${ENFORCER_VERSION}/khulnasoft-enforcer-runc-config.json"
  ENFORCER_RUNC_OLD_CONFIG_URL_DEV="https://download.khulnasoft.com/internal/host-enforcer/${ENFORCER_VERSION}/khulnasoft-enforcer-v1.0.0-rc2-runc-config.json"

  if ! curl --output /dev/null --silent --head --fail -u ${KHULNASOFT_USERNAME}:${KHULNASOFT_PWD} ${ENFORCER_RUNC_TAR_FILE_URL}; then
    error_message "Unable to download package. please check credentials or the version"
  fi

  echo "Info: Downloading enforcer filesystem version ${ENFORCER_VERSION}."
  curl -u ${KHULNASOFT_USERNAME}:${KHULNASOFT_PWD} -s -o ${ENFORCER_RUNC_TAR_FILE_NAME} ${ENFORCER_RUNC_TAR_FILE_URL}

}

get_app_local() {

  if [ ! -f "$ENFORCER_RUNC_TAR_FILE_NAME" ]; then
    error_message "Unable to locate $ENFORCER_RUNC_TAR_FILE_NAME on current directory"
  fi
  if [ ! -f "$ENFORCER_RUNC_CONFIG_TEMPLATE" ]; then
    error_message "Unable to locate $ENFORCER_RUNC_CONFIG_TEMPLATE on current directory"
  fi
}

get_app() {
  ENFORCER_RUNC_TAR_FILE_NAME="khulnasoft-host-enforcer.${ENFORCER_VERSION_FILE}.tar"
  if [ "${DOWNLOAD_MODE}" == "true" ]; then
    get_app_online
    get_templates_online
  else
    get_app_local
    get_templates_local
  fi
}

edit_templates_sh() {
  echo "Info: Creating ${ENFORCER_RUNC_DIRECTORY}/${ENFORCER_RUNC_CONFIG_FILE_NAME} file."

  sed "s|HOSTNAME=.*\"|HOSTNAME=$(hostname)\"|;
		s|KHULNASOFT_PRODUCT_PATH=.*\"|KHULNASOFT_PRODUCT_PATH=${INSTALL_PATH}/khulnasoft\"|;
		s|KHULNASOFT_INSTALL_PATH=.*\"|KHULNASOFT_INSTALL_PATH=${INSTALL_PATH}/khulnasoft\"|;
		s|KHULNASOFT_SERVER=.*\"|KHULNASOFT_SERVER=${GATEWAY_ENDPOINT}\"|;
		s|KHULNASOFT_TOKEN=.*\"|KHULNASOFT_TOKEN=${TOKEN}\"|;    
		s|LD_LIBRARY_PATH=.*\"|LD_LIBRARY_PATH=/opt/khulnasoft\"|;
  	s|KHULNASOFT_TLS_VERIFY=.*\"|KHULNASOFT_TLS_VERIFY=${KHULNASOFT_TLS_VERIFY}\"|;
    s|KHULNASOFT_ROOT_CA=.*\"|KHULNASOFT_ROOT_CA=${KHULNASOFT_ROOT_CA}\"|;
    s|KHULNASOFT_PUBLIC_KEY=.*\"|KHULNASOFT_PUBLIC_KEY=${KHULNASOFT_PUBLIC_KEY}\"|;
    s|KHULNASOFT_PRIVATE_KEY=.*\"|KHULNASOFT_PRIVATE_KEY=${KHULNASOFT_PRIVATE_KEY}\"|;
    s|\"limit\"\:.*|\"limit\"\: ${KHULNASOFT_MEMORY_LIMIT}|;
    s|KHULNASOFT_QUOTA_CPU_LIMIT=.*|KHULNASOFT_QUOTA_CPU_LIMIT=${KHULNASOFT_QUOTA_CPU_LIMIT}\",\"KHULNASOFT_ENFORCER_TYPE=host\"|" ${ENFORCER_RUNC_CONFIG_TEMPLATE} >${ENFORCER_RUNC_DIRECTORY}/${ENFORCER_RUNC_CONFIG_FILE_NAME}

  echo "Info: Creating ${ENFORCER_RUNC_DIRECTORY}/${RUN_SCRIPT_FILE_NAME} file."
  sed "s_{{ .Values.RuncPath }}_${RUNC_LOCATION}_" ${RUN_SCRIPT_TEMPLATE_FILE_NAME} >${ENFORCER_RUNC_DIRECTORY}/${RUN_SCRIPT_FILE_NAME} && chmod +x ${ENFORCER_RUNC_DIRECTORY}/${RUN_SCRIPT_FILE_NAME}

  echo "Info: Creating ${ENFORCER_SERVICE_FILE_NAME_PATH} file."
  sed "s_{{ .Values.RuncPath }}_${RUNC_LOCATION}_;s_{{ .Values.WorkingDirectory }}_${ENFORCER_RUNC_DIRECTORY}_" ${SYSTEMD_TEMPLATE_TO_USE} >${ENFORCER_SERVICE_FILE_NAME_PATH}

}

systemd_type() {
  SYSTEMD_IS_OLD=false

  SYSTEMD_TEMPLATE_TO_USE=${ENFORCER_SERVICE_TEMPLATE_FILE_NAME}
  if [ "${SYSTEMD_VERSION}" -lt "236" ]; then
    SYSTEMD_IS_OLD=true
    SYSTEMD_TEMPLATE_TO_USE=${ENFORCER_SERVICE_TEMPLATE_FILE_NAME_OLD}
  fi
}

untar() {
  echo "Info: Unpacking enforcer filesystem to ${ENFORCER_RUNC_FS_DIRECTORY}."
  tar -xf ${ENFORCER_RUNC_TAR_FILE_NAME} -C ${ENFORCER_RUNC_FS_DIRECTORY}
}

runc_type() {
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
}

setup_sh_env() {
  if [ -z "${INSTALL_PATH}" ]; then
    INSTALL_PATH="/opt"
  fi
  if [ -z "${DOWNLOAD_MODE}" ]; then
    DOWNLOAD_MODE=true
  fi
  if [ -z "${KHULNASOFT_TLS_VERIFY}" ]; then
    KHULNASOFT_TLS_VERIFY=false
  fi
  if [ -z "${KHULNASOFT_PUBLIC_KEY_PATH}" ] && [ -z "${KHULNASOFT_PRIVATE_KEY_PATH}" ]; then
    echo "Info: KHULNASOFT_ROOT_CA, KHULNASOFT_PUBLIC_KEY, KHULNASOFT_PRIVATE_KEY  var is missing, Setting it to blank "
    KHULNASOFT_ROOT_CA=""
    KHULNASOFT_PUBLIC_KEY=""
    KHULNASOFT_PRIVATE_KEY=""
  fi  

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
  KHULNASOFT_CPU_LIMIT=${KHULNASOFT_CPU_LIMIT:-2}
  KHULNASOFT_MEMORY_LIMIT=${KHULNASOFT_MEMORY_LIMIT:-2.6}
}

cp_files_rpm() {
  cp --remove-destination -r ${RUNC_TMP_DIRECTORY}/. ${ENFORCER_RUNC_DIRECTORY}/
  cp --remove-destination ${SYSTEMD_TMP_DIR}/${ENFORCER_SERVICE_FILE_NAME} ${ENFORCER_SERVICE_FILE_NAME_PATH}
  cp --remove-destination -r ${RUNC_FS_TMP_DIRECTORY}/. ${ENFORCER_RUNC_FS_DIRECTORY}/
}

create_folder_sh() {
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
}

start_service() {
  echo "Info: Enabling the ${ENFORCER_SERVICE_FILE_NAME} service."
  systemctl enable ${ENFORCER_SERVICE_FILE_NAME}
  echo "Info: Starting the ${ENFORCER_SERVICE_FILE_NAME} service."
  systemctl start ${ENFORCER_SERVICE_FILE_NAME}
  if [ $? -eq 0 ]; then
    echo "Info: VM Enforcer was successfully deployed and started."
  else
    error_message "Unable to start service. please check the logs."
  fi
}

init_common() {
  setup_sh_env
  prerequisites_check "$@"
  systemd_type
  runc_type
  create_folder_sh
}

main() {
  init_common "$@"
  get_app

  edit_templates_sh
  untar

  start_service
}

bootstrap_args_sh() {
  for arg in "$@"; do
    case $arg in
    -v | --version)
      is_flag_value_valid "-v|--version" "$2"
      ENFORCER_VERSION="$2"
      shift
      shift
      ;;
    -u | --khulnasoft-username)
      is_flag_value_valid "-u|--khulnasoft-username" "$2"
      KHULNASOFT_USERNAME="$2"
      shift
      shift
      ;;
    -p | --khulnasoft-password)
      is_flag_value_valid "-p|--khulnasoft-password" "$2"
      KHULNASOFT_PWD="$2"
      shift
      shift
      ;;
    -t | --token)
      is_flag_value_valid "-t|--token" "$2"
      TOKEN="$2"
      shift
      shift
      ;;
    -g | --gateway)
      is_flag_value_valid "-g|--gateway" "$2"
      GATEWAY_ENDPOINT="$2"
      shift
      shift
      ;;
    -tls | --khulnasoft-tls-verify)
      is_flag_value_valid "-tls|--khulnasoft-tls-verify" "$2"
      KHULNASOFT_TLS_VERIFY=$2
      echo $KHULNASOFT_TLS_VERIFY "------------"
      shift
      ;;
    --rootca-file)
      is_flag_value_valid "--rootca-file" "$2"
      KHULNASOFT_ROOT_CA_PATH="$2"
      ROOT_CA_FILENAME=$(basename "$2")
      KHULNASOFT_ROOT_CA="/opt/khulnasoft/ssl/$ROOT_CA_FILENAME"
      shift
      shift
      ;;
    --publiccert-file)
      is_flag_value_valid "--publiccert-file" "$2"
      KHULNASOFT_PUBLIC_KEY_PATH="$2"
      PUBLIC_KEY_FILENAME=$(basename "$2")
      KHULNASOFT_PUBLIC_KEY="/opt/khulnasoft/ssl/$PUBLIC_KEY_FILENAME"  
      shift
      shift
      ;;
    --privatekey-file)
      is_flag_value_valid "--privatekey-file" "$2"
      KHULNASOFT_PRIVATE_KEY_PATH="$2"
      PRIVATE_KEY_FILENAME=$(basename "$2")
      KHULNASOFT_PRIVATE_KEY="/opt/khulnasoft/ssl/$PRIVATE_KEY_FILENAME"  
      shift
      shift
      ;;            
    -d | --download)
      DOWNLOAD_MODE=true
      shift
      ;;                 
    -f | --tar-file)
      is_flag_value_valid "-f|--tar-file" "$2"
      TAR_FILE="$2"
      shift
      shift
      ;;
    -c | --config-file)
      is_flag_value_valid "-c|--config-file" "$2"
      CONFIG_FILE="$2"
      shift
      shift
      ;;
    -i | --install-path)
      is_flag_value_valid "-i|--install-path" "$2"
      INSTALL_PATH="$2"
      shift
      shift
      ;;
    --custom-envs)
      CUSTOM_ENVS="$2"
      shift
      shift
      ;;
    --cpu-limit)
      is_flag_value_valid "--cpu-limit" "$2"
      KHULNASOFT_CPU_LIMIT="$2"
      shift
      shift
      ;;
    --memory-limit)
      is_flag_value_valid "--memory-limit" "$2"
      KHULNASOFT_MEMORY_LIMIT="$2"
      shift
      shift
      ;;
    esac
  done
}

execute_by_env() {
  echo "Starting Khulnasoft VM Enforcer Deployment".
  bootstrap_args_sh "$@"
  main "$@"
}

execute_by_env "$@"
