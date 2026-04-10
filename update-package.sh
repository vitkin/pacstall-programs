#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACSCRIPT="${SCRIPT_DIR}/betterbird-bin.pacscript"
DOWNLOAD_URL="https://www.betterbird.eu/downloads/get.php?os=linux&lang=en-US&version=release"

usage() {
  cat <<'EOF'
Usage:
  ./update-package.sh
  ./update-package.sh --check
  ./update-package.sh --json
  ./update-package.sh --set <pkgver> <bbXX>

Examples:
  ./update-package.sh
  ./update-package.sh --check
  ./update-package.sh --json
  ./update-package.sh --set 140.9.0esr bb20
EOF
}

get_current_field() {
  local key="$1"
  grep -E "^${key}=" "${PACSCRIPT}" | head -n1 | sed -E "s/^${key}=\"?([^\"]+)\"?$/\1/"
}

get_current_archive_sha() {
  awk '
    BEGIN { in_sha=0 }
    /^sha256sums=\(/ { in_sha=1; next }
    in_sha && /^[[:space:]]*"[a-f0-9]{64}"[[:space:]]*$/ {
      gsub(/^[[:space:]]*"|"[[:space:]]*$/, "")
      print
      exit
    }
    in_sha && /^\)/ { in_sha=0 }
  ' "${PACSCRIPT}"
}

resolve_latest_release() {
  echo "[-] Resolving latest Betterbird English (US) Linux archive URL..."
  FINAL_URL="$(curl -fsSL -o /dev/null -w '%{url_effective}' "${DOWNLOAD_URL}")"

  if [[ -z "${FINAL_URL}" || "${FINAL_URL}" != *"LinuxArchive"* ]]; then
    echo "Error: Could not resolve LinuxArchive release URL from Betterbird downloads." >&2
    exit 1
  fi

  FILENAME="$(basename "${FINAL_URL}")"

  # Expected form: betterbird-140.9.0esr-bb20.en-US.linux-x86_64.tar.xz
  if [[ "${FILENAME}" =~ ^betterbird-([0-9]+\.[0-9]+\.[0-9]+esr)-(bb[0-9]+)\.en-US\.linux-x86_64\.tar\.xz$ ]]; then
    VERSION="${BASH_REMATCH[1]}"
    BUILD="${BASH_REMATCH[2]}"
  else
    echo "Error: Unexpected archive filename format: ${FILENAME}" >&2
    exit 1
  fi

  echo "[-] Latest release detected: ${VERSION}-${BUILD}"
}

validate_manual_release() {
  if [[ ! "${VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+esr$ ]]; then
    echo "Error: Invalid pkgver '${VERSION}'. Expected format like 140.9.0esr." >&2
    exit 1
  fi

  if [[ ! "${BUILD}" =~ ^bb[0-9]+$ ]]; then
    echo "Error: Invalid build '${BUILD}'. Expected format like bb20." >&2
    exit 1
  fi

  FINAL_URL="https://www.betterbird.eu/downloads/LinuxArchive/betterbird-${VERSION}-${BUILD}.en-US.linux-x86_64.tar.xz"
  echo "[-] Using manually requested release: ${VERSION}-${BUILD}"
}

resolve_release_sha() {
  MAJOR="${VERSION%%.*}"
  SHA_FILE_URL="https://www.betterbird.eu/downloads/sha256-${MAJOR}.txt"
  ARCHIVE_NAME="betterbird-${VERSION}-${BUILD}.en-US.linux-x86_64.tar.xz"

  echo "[-] Fetching checksum list: ${SHA_FILE_URL}"
  SHA_LIST="$(curl -fsSL "${SHA_FILE_URL}")"

  NEW_SHA="$(printf '%s\n' "${SHA_LIST}" | awk -v f="${ARCHIVE_NAME}" '
    {
      file=$2
      sub(/^\*/, "", file)
      if (file == f) {
        print $1
        exit
      }
    }
  ')"

  if [[ -z "${NEW_SHA}" ]]; then
    echo "[!] Could not find checksum for ${ARCHIVE_NAME} in ${SHA_FILE_URL}" >&2
    echo "[-] Falling back to hashing the archive directly (may take a while)..."
    NEW_SHA="$(curl -fsSL "${FINAL_URL}" | sha256sum | awk '{print $1}')"
  fi

  echo "[+] Found SHA256: ${NEW_SHA}"
}

MODE="update"
VERSION=""
BUILD=""
FINAL_URL=""
NEW_SHA=""

case "${1-}" in
  "")
    MODE="update"
    ;;
  --check)
    MODE="check"
    ;;
  --json)
    MODE="json"
    ;;
  --set)
    MODE="set"
    if [[ $# -ne 3 ]]; then
      usage
      exit 1
    fi
    VERSION="$2"
    BUILD="$3"
    ;;
  -h|--help)
    usage
    exit 0
    ;;
  *)
    usage
    exit 1
    ;;
esac

if [[ ! -f "${PACSCRIPT}" ]]; then
  echo "Error: ${PACSCRIPT} not found in current directory." >&2
  exit 1
fi

if [[ "${MODE}" == "set" ]]; then
  validate_manual_release
elif [[ "${MODE}" == "json" ]]; then
  resolve_latest_release >/dev/null
else
  resolve_latest_release
fi

if [[ "${MODE}" == "json" ]]; then
  resolve_release_sha >/dev/null
else
  resolve_release_sha
fi

CURRENT_VERSION="$(get_current_field 'pkgver')"
CURRENT_BUILD="$(get_current_field '_build')"
CURRENT_SHA="$(get_current_archive_sha)"

if [[ "${MODE}" == "check" ]]; then
  echo "[i] Current pacscript: ${CURRENT_VERSION}-${CURRENT_BUILD}"
  echo "[i] Current sha256: ${CURRENT_SHA}"
  echo "[i] Available release: ${VERSION}-${BUILD}"
  echo "[i] Available sha256: ${NEW_SHA}"

  if [[ "${CURRENT_VERSION}" == "${VERSION}" && "${CURRENT_BUILD}" == "${BUILD}" && "${CURRENT_SHA}" == "${NEW_SHA}" ]]; then
    echo "[+] Up to date"
  else
    echo "[+] Update available"
  fi
  exit 0
fi

if [[ "${MODE}" == "json" ]]; then
  if [[ "${CURRENT_VERSION}" == "${VERSION}" && "${CURRENT_BUILD}" == "${BUILD}" && "${CURRENT_SHA}" == "${NEW_SHA}" ]]; then
    UPDATE_AVAILABLE="false"
    STATUS="up-to-date"
  else
    UPDATE_AVAILABLE="true"
    STATUS="update-available"
  fi

  printf '{\n'
  printf '  "status": "%s",\n' "${STATUS}"
  printf '  "updateAvailable": %s,\n' "${UPDATE_AVAILABLE}"
  printf '  "current": {"pkgver": "%s", "build": "%s", "sha256": "%s"},\n' "${CURRENT_VERSION}" "${CURRENT_BUILD}" "${CURRENT_SHA}"
  printf '  "available": {"pkgver": "%s", "build": "%s", "sha256": "%s"}\n' "${VERSION}" "${BUILD}" "${NEW_SHA}"
  printf '}\n'
  exit 0
fi

if [[ "${CURRENT_VERSION}" == "${VERSION}" && "${CURRENT_BUILD}" == "${BUILD}" && "${CURRENT_SHA}" == "${NEW_SHA}" ]]; then
  echo "[+] ${PACSCRIPT} already up to date"
  exit 0
fi

echo "[-] Updating ${PACSCRIPT}..."
sed -i "s/^pkgver=\".*\"/pkgver=\"${VERSION}\"/" "${PACSCRIPT}"
sed -i "s/^_build=.*/_build=${BUILD}/" "${PACSCRIPT}"

# Update only the first sha256 entry (archive), keep desktop checksum untouched.
awk -v sha="${NEW_SHA}" '
  BEGIN { in_sha=0; replaced=0 }
  /^sha256sums=\(/ { in_sha=1; print; next }
  in_sha && !replaced && /^[[:space:]]*"[a-f0-9]{64}"[[:space:]]*$/ {
    print "  \"" sha "\""
    replaced=1
    next
  }
  in_sha && /^\)/ { in_sha=0; print; next }
  { print }
' "${PACSCRIPT}" > "${PACSCRIPT}.tmp"
mv "${PACSCRIPT}.tmp" "${PACSCRIPT}"

echo "[+] Updated ${PACSCRIPT}:"
echo "    pkgver=${VERSION}"
echo "    _build=${BUILD}"
echo "    sha256=${NEW_SHA}"

echo "[i] Skipping .SRCINFO generation (script updates pacscript only)."

# vim: set filetype=bash tabstop=2 foldmethod=marker expandtab:
