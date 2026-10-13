#!/usr/bin/env bash
# Zehra OS - Local Docker Build Script
# Builds the Zehra OS ISO locally on any Linux host using a privileged Docker container.
#
# Usage: ./build_local.sh [options]
# Options:
#   -o, --output DIR    Output directory (default: ./out)
#   -w, --work DIR      Work directory (default: /tmp/archiso-work)
#   -c, --clean         Clean work directory before build
#   -v, --verbose       Verbose output
#   -h, --help          Show this help

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Defaults
OUTPUT_DIR="./out"
WORK_DIR="/tmp/archiso-work"
CLEAN_WORK=false
VERBOSE=false
DOCKER_IMAGE="archlinux:latest"
REPO_MOUNT="/repo"

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_DIR="${SCRIPT_DIR}/EndeavourOS-ISO-main"

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

show_help() {
    cat << EOF
Zehra OS - Local Docker Build Script
Builds the Zehra OS ISO locally using a privileged Docker container.

Usage: $0 [options]

Options:
  -o, --output DIR    Output directory for ISO (default: ./out)
  -w, --work DIR      Work directory inside container (default: /tmp/archiso-work)
  -c, --clean         Clean work directory before build
  -v, --verbose       Enable verbose output from mkarchiso
  -h, --help          Show this help message

Requirements:
  - Docker installed and running
  - User in docker group or running with sudo
  - At least 20GB free disk space

Example:
  $0 --clean --verbose
  $0 -o /path/to/output -w /path/to/work

EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -w|--work)
                WORK_DIR="$2"
                shift 2
                ;;
            -c|--clean)
                CLEAN_WORK=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

check_requirements() {
    log_info "Checking requirements..."

    # Check Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed or not in PATH"
        exit 1
    fi

    # Check Docker daemon
    if ! docker info &> /dev/null; then
        log_error "Docker daemon is not running or current user lacks permissions"
        log_info "Try: sudo usermod -aG docker \$USER && newgrp docker"
        exit 1
    fi

    # Check profile directory
    if [[ ! -d "${PROFILE_DIR}" ]]; then
        log_error "Profile directory not found: ${PROFILE_DIR}"
        log_info "Expected EndeavourOS-ISO-main directory in script location"
        exit 1
    fi

    # Check for packages.x86_64
    if [[ ! -f "${PROFILE_DIR}/packages.x86_64" ]]; then
        log_error "packages.x86_64 not found in profile directory"
        exit 1
    fi

    log_success "All requirements satisfied"
}

prepare_directories() {
    log_info "Preparing directories..."

    # Create output directory
    mkdir -p "${OUTPUT_DIR}"
    OUTPUT_DIR="$(cd "${OUTPUT_DIR}" && pwd)"

    # Clean work directory if requested
    if [[ "${CLEAN_WORK}" == true ]]; then
        log_info "Cleaning work directory: ${WORK_DIR}"
        sudo rm -rf "${WORK_DIR}" 2>/dev/null || true
    fi

    log_success "Directories prepared"
}

build_iso() {
    log_info "Starting ISO build in Docker container..."
    log_info "Profile: ${PROFILE_DIR}"
    log_info "Output: ${OUTPUT_DIR}"
    log_info "Work dir: ${WORK_DIR}"

    # Build docker command
    local docker_cmd=(
        docker run
        --rm
        --privileged
        --volume "${PROFILE_DIR}:${REPO_MOUNT}:ro"
        --volume "${OUTPUT_DIR}:${REPO_MOUNT}/out"
        --workdir "${REPO_MOUNT}"
        "${DOCKER_IMAGE}"
    )

    # Build mkarchiso command
    local mkarchiso_cmd=(
        bash -c "
            set -euo pipefail
            pacman -Sy --noconfirm archlinux-keyring &&
            pacman-key --init &&
            pacman-key --populate archlinux &&
            pacman -Sy --noconfirm archiso &&
            mkarchiso ${VERBOSE:+-v} -w ${WORK_DIR} -o ${REPO_MOUNT}/out .
        "
    )

    log_info "Running: ${docker_cmd[*]} ${mkarchiso_cmd[*]}"

    # Execute build
    if "${docker_cmd[@]}" "${mkarchiso_cmd[@]}"; then
        log_success "ISO build completed successfully!"
        log_info "Output files in: ${OUTPUT_DIR}"
        ls -lh "${OUTPUT_DIR}"/*.iso 2>/dev/null || true
    else
        log_error "ISO build failed"
        exit 1
    fi
}

main() {
    echo "========================================"
    echo "  Zehra OS - Local Docker Build Script"
    echo "========================================"
    echo

    parse_args "$@"
    check_requirements
    prepare_directories
    build_iso

    echo
    log_success "Build process completed!"
}

main "$@"