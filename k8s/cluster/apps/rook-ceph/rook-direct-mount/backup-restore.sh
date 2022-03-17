#!/usr/bin/env bash

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   @description    :   Manually backup/restore rook-ceph volumes
#   @usage          :
# PVC=mylar-config-v1 \
# NS=media \
# kubectl -n rook-ceph exec -it $(kubectl -n rook-ceph get po -l "app=rook-direct-mount" -o jsonpath='{.items[0].metadata.name}') -- scripts/backup-restore.sh --rbd $(kubectl get pv/$(kubectl get pv | grep "${PVC}" | awk -F ' ' '{print $1}') -n "${NS}" -o json | jq -rj '.spec.csi.volumeAttributes.imageName') --pvc "${PVC}"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# --------------------------------------------------------------------------------------------------
#   @description    :   Script Constants, Variables
# --------------------------------------------------------------------------------------------------
DEFAULT_ACTION="backup"
NFS_MOUNT_PATH="/mnt/nfsdata"
RBD_MOUNT_PATH="/mnt/data"
ROOK_POOL="ceph-blockpool"
PVC_BACKUP_PATH="${NFS_MOUNT_PATH}/backup/rook-ceph/pvc/$(date +%Y-%m-%d)"

## Define the logging variables
LOG_LEVEL="${LOG_LEVEL:-6}" # 7 = debug -> 0 = emergency
NO_COLOR="${NO_COLOR:-}"    # true = disable color, otherwise autodetected
# ==================================================================================================

# --------------------------------------------------------------------------------------------------
#   @description    :   Startup
# --------------------------------------------------------------------------------------------------
# Enable xtrace if the DEBUG environment variable is set
if [[ ${DEBUG-} =~ ^1|yes|true$ ]]; then
  set -o xtrace       # Trace the execution of the script (debug)
fi

# if not sourced
if ! (return 0 2> /dev/null); then
  set -o errexit      # Exit on most errors (see the manual)
  set -o nounset      # Disallow expansion of unset variables
  set -o pipefail     # Use last non-zero exit code in a pipeline
fi

# Enable errtrace or the error trap handler will not work as expected
set -o errtrace         # Ensure the error trap handler is inherited
# ==================================================================================================

# --------------------------------------------------------------------------------------------------
#   @description    :   Console Logging Helpers
# --------------------------------------------------------------------------------------------------
function console_log () {
  local log_level="${1}"
  shift

  # shellcheck disable=SC2034
  local color_debug="\\x1b[35m"
  # shellcheck disable=SC2034
  local color_info="\\x1b[32m"
  # shellcheck disable=SC2034
  local color_notice="\\x1b[34m"
  # shellcheck disable=SC2034
  local color_warning="\\x1b[33m"
  # shellcheck disable=SC2034
  local color_error="\\x1b[31m"
  # shellcheck disable=SC2034
  local color_critical="\\x1b[1;31m"
  # shellcheck disable=SC2034
  local color_alert="\\x1b[1;37;41m"
  # shellcheck disable=SC2034
  local color_emergency="\\x1b[1;4;5;37;41m"

  local colorvar="color_${log_level}"

  local color="${!colorvar:-${color_error}}"
  local color_reset="\\x1b[0m"

  if [[ "${NO_COLOR:-}" = "true" ]] || { [[ "${TERM:-}" != "xterm"* ]] && [[ "${TERM:-}" != "screen"* ]]; } || [[ ! -t 2 ]]; then
    if [[ "${NO_COLOR:-}" != "false" ]]; then
      # Don't use colors on pipes or non-recognized terminals
      color=""; color_reset=""
    fi
  fi

  # all remaining arguments are to be printed
  local log_line=""

  while IFS=$'\n' read -r log_line; do
    echo -e "$(date -u +"%Y-%m-%d %H:%M:%S UTC") ${color}$(printf "[%9s]" "${log_level}")${color_reset} ${log_line}" 1>&2
  done <<< "${@:-}"
}

function debug ()     { [[ "${LOG_LEVEL:-0}" -ge 7 ]] && console_log debug "${@}"; true; }
function info ()      { [[ "${LOG_LEVEL:-0}" -ge 6 ]] && console_log info "${@}"; true; }
function notice ()    { [[ "${LOG_LEVEL:-0}" -ge 5 ]] && console_log notice "${@}"; true; }
function warning ()   { [[ "${LOG_LEVEL:-0}" -ge 4 ]] && console_log warning "${@}"; true; }
function error ()     { [[ "${LOG_LEVEL:-0}" -ge 3 ]] && console_log error "${@}"; true; }
function critical ()  { [[ "${LOG_LEVEL:-0}" -ge 2 ]] && console_log critical "${@}"; true; }
function alert ()     { [[ "${LOG_LEVEL:-0}" -ge 1 ]] && console_log alert "${@}"; true; }
function emergency () {                                  console_log emergency "${@}"; exit 1; }
# ==================================================================================================

# --------------------------------------------------------------------------------------------------
#   @description    :   Script init
# --------------------------------------------------------------------------------------------------
function init() {
  readonly __dir_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  readonly __file_path="${__dir_path}/$(basename "${BASH_SOURCE[0]}")"
  readonly __file="${__file_path##*/}"
  readonly __base="${__file%%.*}"
  readonly __params="$*"
}
# ==================================================================================================

# --------------------------------------------------------------------------------------------------
#   @description    :   Collect command line parameters
#   @details        :   Command line parameters in the form of --<key> <value> will be converted
#                       into script variables. Parameteters without a value are assumed to be script
#                       options.
# --------------------------------------------------------------------------------------------------
function parse_params() {
  local param

  while [[ $# -gt 0 ]]; do
    if [[ "$#" -gt 1 ]]; then
      if [[ "${1}" == "--"* && "${2}" == "--"* ]]; then
        param="${1}"
      elif [[ "${1}" == "--"* && "${2}" != "--"* ]]; then
        eval "${1/--/}"="${2}"
        debug $( set -o posix ; set )
        shift
      fi
    else
      param="${1}"
    fi

    if [[ -n "${param-}" ]]; then
      case "${param}" in
        -h | --help)
          usage
          exit 0
          ;;
        -b | --backup)
          ACTION=backup
          ;;
        -r | --restore)
          ACTION=restore
          ;;
        *)
          emergency "Invalid parameter was provided: ${param}"
          ;;
      esac
    fi

    unset param
    shift
  done

}
# ==================================================================================================

# --------------------------------------------------------------------------------------------------
#   @description    :   Display script help
#   @arguments      :   None
#   @output         :   None
# --------------------------------------------------------------------------------------------------
function usage() {
  cat << EOF
Usage: $(basename "${__file}") [OPTIONS]

Rook-Ceph Persistent Volume Backup

Options:
  -h, --help            show this help message and exit
  -b, --backup          perform backup
  -r, --restore         perform restore
  --pvc <value>
  --rbd <value>
  --<key> <value>       declare variable <key>=<value>
EOF
}
# ==================================================================================================

# --------------------------------------------------------------------------------------------------
#   @description    :   Perform preflight checks
#   @arguments      :   None
#   @output         :   None
# --------------------------------------------------------------------------------------------------
function preflight_checks() {
  local reqd_vars
  local var_name
  local var_unset

  # check for required variables
  reqd_vars=(
    'rbd'
    'pvc'
    'LOG_LEVEL'
  )
  # check_vars "${reqd_vars[@]}"

  for var_name in "${reqd_vars[@]}"; do
    [[ "${!var_name:-}" ]] || emergency "Required variable '${var_name}' not set!"
  done
  return 0

}
# ==================================================================================================

# --------------------------------------------------------------------------------------------------
#   @description    :   Check for required variables
#   @arguments      :   None
#   @output         :   None
# --------------------------------------------------------------------------------------------------
function check_vars() {
  local var_names
  local var_name
  local var_unset

  var_names=("$@")
  for var_name in "${var_names[@]}"; do
    if [[ -z "${!var_name:-}" ]]; then
      echo "Required variable '${var_name}' not set!"
      var_unset=true
    fi
  done
  [[ -n "${var_unset:-}" ]] && exit 1
  return 0

}
# ==================================================================================================

# --------------------------------------------------------------------------------------------------
#   @description    :   Backup rook-ceph volume image
# --------------------------------------------------------------------------------------------------
function backup_volume() {
  # verify that the NFS volume is mounted
  check_nfs

  # mount the rook device
  mount_volume_image

  # create the volume backup
  create_volume_backup

  # unmount the rook device
  unmount_volume_image
}
# ==================================================================================================

# --------------------------------------------------------------------------------------------------
#   @description    :   Verify NFS mount
#   @arguments      :   None
#   @output         :   None
# --------------------------------------------------------------------------------------------------
function check_nfs() {

  # verify nfs mount
  if ! (findmnt -rn "${NFS_MOUNT_PATH}" > /dev/null); then
      info "NFS mount '${NFS_MOUNT_PATH}' is not mounted"
      exit 1
  fi

}
# ==================================================================================================

# --------------------------------------------------------------------------------------------------
#   @description    :   Mount rook-ceph volume image
# --------------------------------------------------------------------------------------------------
function mount_volume_image() {

  # Map RBD image
  MAPPED_DEVICE="$(rbd device list | grep ${ROOK_POOL} | grep ${rbd} | awk '{print $5}' | tr -d '[:space:]' || echo unmapped)"
  if [[ "${MAPPED_DEVICE}" != "unmapped" && -n "${MAPPED_DEVICE}" ]]; then
    debug "'${rbd}' is already mapped to '${MAPPED_DEVICE}'"
  else
    info "Mapping image '${rbd}'"
    MAPPED_DEVICE="$(rbd map --pool ${ROOK_POOL} ${rbd} | tr -d '[:space:]')"
    sleep 2
  fi

  # Mount the RBD image
  IMAGE_MOUNT="$(findmnt -rn --mountpoint ${RBD_MOUNT_PATH} | awk '{print $2}' || echo unmounted)"
  if [[ "${IMAGE_MOUNT}" != "unmounted" && -n "${IMAGE_MOUNT}" ]]; then
    if [[ "${IMAGE_MOUNT}" == "${MAPPED_DEVICE}" ]]; then
      debug "'${RBD_MOUNT_PATH}' is already mounted"
    else
      alert "'${MAPPED_DEVICE}' is already mounted to '${RBD_MOUNT_PATH}'"
      emergency "This image must be manually unmounted before continuing"
    fi
  else
    info "Mounting '${MAPPED_DEVICE}' to '${RBD_MOUNT_PATH}'"
    mkdir -p "${RBD_MOUNT_PATH}"
    mount "${MAPPED_DEVICE}" "${RBD_MOUNT_PATH}"
    sleep 2
  fi

}
# ==================================================================================================

# --------------------------------------------------------------------------------------------------
#   @description    :   Create rook-ceph volume image backup tarball
# --------------------------------------------------------------------------------------------------
function create_volume_backup() {
  # Create the backup directory
  mkdir -p "${PVC_BACKUP_PATH}"

  # Check for duplicate file
  PVC_BACKUP_FILE="${PVC_BACKUP_PATH}/${pvc}.$(date +"%FT%H%M").tar.gz"

  if [[ -f "${PVC_BACKUP_FILE}" ]]; then
      emergency "Duplicate file '${PVC_BACKUP_FILE}' already exists"
  fi

  # Create the backup tarball
  tar czvf "${PVC_BACKUP_FILE}" -C "${RBD_MOUNT_PATH}/" .
  info "Backup saved to '${PVC_BACKUP_FILE}'"
  debug "Backup size: $(du -sh ${PVC_BACKUP_FILE} | awk '{print $1}')"
  sleep 2

}
# ==================================================================================================

# --------------------------------------------------------------------------------------------------
#   @description    :   Unmount rook-ceph volume image
# --------------------------------------------------------------------------------------------------
function unmount_volume_image() {
  # Unmount the RBD image
  IMAGE_MOUNT="$(findmnt -rn --mountpoint ${RBD_MOUNT_PATH} | awk '{print $2}' || echo unmounted)"
  if [[ "${IMAGE_MOUNT}" != "unmounted" && -n "${IMAGE_MOUNT}" ]]; then
    if [[ "${IMAGE_MOUNT}" == "${MAPPED_DEVICE}" ]]; then
      info "Unmounting '${RBD_MOUNT_PATH}'"
      umount "${RBD_MOUNT_PATH}"
      sleep 2
    else
      alert "Unexpected device '${MAPPED_DEVICE}' is mounted to '${RBD_MOUNT_PATH}'"
      emergency "This image must be manually unmounted before continuing"
    fi
  else
    debug "'${MAPPED_DEVICE}' is not mounted"
  fi

  # Verify the device is unmounted
  IMAGE_MOUNT_VERIFY="$(findmnt -rn --mountpoint ${RBD_MOUNT_PATH} | awk '{print $2}' || echo unmounted)"
  if [[ "${IMAGE_MOUNT_VERIFY}" != "unmounted" && -n "${IMAGE_MOUNT_VERIFY}" ]]; then
    alert "'${RBD_MOUNT_PATH}' did not unmount successfully"
    emergency "This image must be manually unmounted before continuing"
  else
    debug "'${RBD_MOUNT_PATH}' was unmounted"
  fi

  # Unmap the RBD image
  MAPPED_DEVICE="$(rbd device list | grep ${ROOK_POOL} | grep ${rbd} | awk '{print $5}' | tr -d '[:space:]' || echo unmapped)"
  if [[ "${MAPPED_DEVICE}" != "unmapped" && -n "${MAPPED_DEVICE}" ]]; then
    info "Unmapping image '${rbd}'"
    rbd unmap --pool "${ROOK_POOL}" "${rbd}"
    sleep 2
  else
    debug "'${rbd}' is not mapped"
  fi

}
# ==================================================================================================

# --------------------------------------------------------------------------------------------------
#   @description    :   Restore rook-ceph volume image
# --------------------------------------------------------------------------------------------------
function restore_volume() {
  cat << EOF


================================================================================
================================================================================
||                                                                            ||
||                      Restore function not enabled yet                      ||
||                                                                            ||
================================================================================
================================================================================


EOF
  exit 1
}
# ==================================================================================================

# --------------------------------------------------------------------------------------------------
#   @description    :   Main control function
#   @arguments      :   (optional) Arguments provided to the script
#   @output         :   None
# --------------------------------------------------------------------------------------------------
function main() {

  init "$@"
  parse_params "$@"
  preflight_checks

  if [[ -z "${ACTION-}" ]]; then
    ACTION="${DEFAULT_ACTION}"
  fi

  if [[ "${ACTION}" = "backup" ]]; then
    backup_volume
    :
  elif [[ "${ACTION}" = "restore" ]]; then
    restore_volume
    :
  else
    emergency "'${ACTION} is not a valid action"
  fi

}
# ==================================================================================================

# Invoke main with args if not sourced
if ! (return 0 2> /dev/null); then
  main "$@"
fi
