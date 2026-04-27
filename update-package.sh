#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Configuration
PACSCRIPT="${SCRIPT_DIR}/wine-tkg-staging-wow64-bin.pacscript"
REPO="Kron4ek/Wine-Builds"
GITHUB_TOKEN="${GITHUB_TOKEN:-${GH_TOKEN:-}}"

curl_common_args=(
    -fsSL
    -H "Accept: application/vnd.github+json"
    -H "X-GitHub-Api-Version: 2022-11-28"
    -H "User-Agent: pacstall-programs-update-script"
)

if [ -n "${GITHUB_TOKEN}" ]; then
    curl_common_args+=( -H "Authorization: Bearer ${GITHUB_TOKEN}" )
fi

github_api_get() {
    curl "${curl_common_args[@]}" "$1"
}

github_public_api_get() {
    curl -fsSL \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        -H "User-Agent: pacstall-programs-update-script" \
        "$1"
}

github_release_download() {
    local url="$1"
    local curl_args=( -fsSL -H "User-Agent: pacstall-programs-update-script" )

    if [ -n "${GITHUB_TOKEN}" ]; then
        curl_args+=( -H "Authorization: Bearer ${GITHUB_TOKEN}" )
    fi

    curl "${curl_args[@]}" "${url}"
}

extract_latest_non_proton_version() {
    local releases_json="$1"

    printf '%s\n' "${releases_json}" |
    grep -oE '"tag_name"[[:space:]]*:[[:space:]]*"[^"]+"' |
    sed -E 's/^"tag_name"[[:space:]]*:[[:space:]]*"([^"]+)"$/\1/' |
        awk 'BEGIN { IGNORECASE=1 } !/proton/ { print; exit }'
}

generate_srcinfo() {
    local repo_root srcinfo_script package_dir_name tmp_tools abs_pacscript

    repo_root="$(dirname "$(dirname "${SCRIPT_DIR}")")"
    srcinfo_script="${repo_root}/scripts/srcinfo.sh"

    if [[ -f "${srcinfo_script}" && -f "${repo_root}/distrolist" ]]; then
        echo "[-] Generating .SRCINFO (Monorepo detected)..."
        package_dir_name="$(basename "${SCRIPT_DIR}")"

        pushd "${repo_root}" > /dev/null || exit
        ./scripts/srcinfo.sh write "packages/${package_dir_name}/$(basename "${PACSCRIPT}")"
        popd > /dev/null || exit
        echo "[+] .SRCINFO updated."
    else
        echo "[-] Generating .SRCINFO (Standalone/CI detected)..."
        tmp_tools="$(mktemp -d)"

        echo "    Fetching srcinfo.sh and distrolist..."
        if curl -fsSL "https://raw.githubusercontent.com/pacstall/pacstall-programs/master/scripts/srcinfo.sh" \
            -o "${tmp_tools}/srcinfo.sh" && \
            curl -fsSL "https://raw.githubusercontent.com/pacstall/pacstall-programs/master/distrolist" \
            -o "${tmp_tools}/distrolist"; then

            chmod +x "${tmp_tools}/srcinfo.sh"
            abs_pacscript="${PACSCRIPT}"

            pushd "${tmp_tools}" > /dev/null || exit
            ./srcinfo.sh write "${abs_pacscript}"
            popd > /dev/null || exit

            rm -rf "${tmp_tools}"
            echo "[+] .SRCINFO updated."
        else
            echo "Error: Failed to fetch srcinfo tools." >&2
            rm -rf "${tmp_tools}"
            exit 1
        fi
    fi
}

# Get version from argument or fetch latest
if [ -z "${1-}" ] || [ "${1-}" == "latest" ]; then
    echo "[-] Checking for latest non-Proton release..."

    RELEASES_JSON=$(github_api_get "https://api.github.com/repos/${REPO}/releases")

    if [ -n "${GITHUB_TOKEN}" ] && [ "${RELEASES_JSON}" = "[]" ]; then
        echo "[!] Authenticated GitHub releases response was empty; the provided token may not see this repository's releases."
        echo "[-] Retrying public releases request without token..."
        RELEASES_JSON=$(github_public_api_get "https://api.github.com/repos/${REPO}/releases")
    fi

    VERSION=$(extract_latest_non_proton_version "${RELEASES_JSON}")
    
    if [ -z "${VERSION}" ]; then
        echo "Error: Could not determine latest version automatically."
        echo "Response from GitHub did not contain a usable non-Proton release tag."
        echo "If you are hitting GitHub API limits in CI, set GITHUB_TOKEN or GH_TOKEN."
        exit 1
    fi
    echo "[-] Auto-detected latest version: ${VERSION}"
else
    VERSION="${1}"
fi

TARGET_FILENAME="wine-${VERSION}-staging-tkg-amd64-wow64.tar.xz"
BASE_URL="https://github.com/${REPO}/releases/download/${VERSION}"
CHECKSUM_URL="${BASE_URL}/sha256sums.txt"

echo "[-] Updating ${PACSCRIPT} to version ${VERSION}..."

# 1. Fetch checksum file
echo "[-] Fetching checksums from GitHub..."
CHECKSUMS=$(github_release_download "${CHECKSUM_URL}")

if [ -z "${CHECKSUMS}" ] || echo "${CHECKSUMS}" | grep -q "Not Found"; then
    echo "Error: Could not retrieve checksums. Check if version '${VERSION}' exists in ${REPO}."
    exit 1
fi

# 2. Extract specific hash
NEW_SHA=$(echo "${CHECKSUMS}" | grep "${TARGET_FILENAME}" | awk '{print $1}')

if [ -z "${NEW_SHA}" ]; then
    echo "Error: Could not find hash for ${TARGET_FILENAME}."
    echo "Available files in this release:"
    echo "${CHECKSUMS}" | awk '{print $2}'
    exit 1
fi

echo "[+] Found SHA256: ${NEW_SHA}"

# 3. Update the .pacscript file
# Update pkgver
sed -i "s/^pkgver=\".*\"/pkgver=\"${VERSION}\"/" "${PACSCRIPT}"

# Update sha256sums
sed -i "s/^sha256sums=('[a-f0-9]*')/sha256sums=('${NEW_SHA}')/" "${PACSCRIPT}"

# Reset pkgrel to 1 on version bump
sed -i "s/^pkgrel=\".*\"/pkgrel=\"1\"/" "${PACSCRIPT}"

echo "[+] Successfully updated ${PACSCRIPT}!"
echo "    Version: ${VERSION}"
echo "    SHA256:  ${NEW_SHA}"

generate_srcinfo

# vim: set filetype=bash tabstop=4 foldmethod=marker expandtab:
