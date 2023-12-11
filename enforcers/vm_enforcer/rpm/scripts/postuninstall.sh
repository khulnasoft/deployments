#!/usr/bin/env bash

ENFORCER_SERVICE_FILE_NAME="khulnasoft-enforcer.service"
SELINUX_POLICY_MODULE="khulnasoftvme"


error_message(){
    echo "Error: ${1}"
    exit 1
}


remove_service() {
    rm -f /etc/systemd/system/${ENFORCER_SERVICE_FILE_NAME}
    rm -f /usr/lib/systemd/system/${ENFORCER_SERVICE_FILE_NAME}
    rm -f /etc/init.d/${ENFORCER_SERVICE_FILE_NAME}
    systemctl daemon-reload
    systemctl reset-failed
    if [ $? -eq 0 ]; then
        echo "Info: VM Enforcer service was successfully removed."
    else
        error_message "Unable to remove the service. please check the logs."
    fi
}

remove_policy_module() {
    rm -rf /usr/share/selinux/targeted/${SELINUX_POLICY_MODULE}.pp
    /usr/sbin/semodule -s targeted -X 300 -r ${SELINUX_POLICY_MODULE} &> /dev/null || :
    echo "Info: Removed Selinux Policy module ${SELINUX_POLICY_MODULE}"

}

remove_dirs() {
    rm -rf /opt/khulnasoft
    rm -rf /opt/khulnasoft-runc
    rm -rf /tmp/khulnasoft
}

remove_logs() {
    rm -f /opt/khulnasoft/tmp/khulnasoft.log
}

remove() {
    remove_service
    remove_policy_module
    remove_dirs
    remove_logs
}

restart_service() {
    systemctl daemon-reload
    systemctl try-restart ${ENFORCER_SERVICE_FILE_NAME}
    if [ $? -eq 0 ]; then
        echo "Info: VM Enforcer was successfully re-deployed and started."
    else
        error_message "Unable to re-start service. please check the logs."
    fi
}


action="$1"

case "$action" in
"0" | "remove")
    remove
    ;;
"1" | "upgrade")
    restart_service
    ;;
esac