#!/usr/bin/env bash

# Configuration
PACSCRIPT="wine-tkg-staging-wow64-bin.pacscript"
REPO="Kron4ek/Wine-Builds"

# Get version from argument or fetch latest
if [ -z "${1}" ] || [ "${1}" == "latest" ]; then
    echo "[-] Checking for latest non-Proton release..."

    VERSION=$(curl -s "https://api.github.com/repos/${REPO}/releases" |
    grep '"tag_name":' | awk -F '"' '{print $4}' | grep -v "proton" | head -n 1)
    
    if [ -z "${VERSION}" ]; then
        echo "Error: Could not determine latest version automatically."
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
CHECKSUMS=$(curl -sL "${CHECKSUM_URL}")

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

# Generate .SRCINFO if running within a pacstall-programs repo structure
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
REPO_ROOT="$(dirname "$(dirname "${SCRIPT_DIR}")")"
SRCINFO_SCRIPT="${REPO_ROOT}/scripts/srcinfo.sh"

if [ -f "${SRCINFO_SCRIPT}" ] && [ -f "${REPO_ROOT}/distrolist" ]; then
    echo "[-] Generating .SRCINFO (Monorepo detected)..."
    PACKAGE_DIR_NAME=$(basename "${SCRIPT_DIR}")
    
    # Run from repo root so srcinfo.sh finds distrolist
    pushd "${REPO_ROOT}" > /dev/null || exit
    ./scripts/srcinfo.sh write "packages/${PACKAGE_DIR_NAME}/${PACSCRIPT}"
    popd > /dev/null || exit
    echo "[+] .SRCINFO updated."
else
    echo "[-] Generating .SRCINFO (Standalone/CI detected)..."
    
    # Create temp dir for tools
    TMP_TOOLS=$(mktemp -d)
    
    # Download upstream tools
    echo "    Fetching srcinfo.sh and distrolist..."
    if curl -sL "https://raw.githubusercontent.com/pacstall/pacstall-programs/master/scripts/srcinfo.sh" \
        -o "${TMP_TOOLS}/srcinfo.sh" && \
        curl -sL "https://raw.githubusercontent.com/pacstall/pacstall-programs/master/distrolist" \
        -o "${TMP_TOOLS}/distrolist"; then
        
        chmod +x "${TMP_TOOLS}/srcinfo.sh"
        
        # Get absolute path to pacscript
        ABS_PACSCRIPT="${SCRIPT_DIR}/${PACSCRIPT}"
        
        # Run srcinfo.sh from within the temp dir so it finds distrolist
        pushd "${TMP_TOOLS}" > /dev/null || exit
        ./srcinfo.sh write "${ABS_PACSCRIPT}"
        popd > /dev/null || exit
        
        rm -rf "${TMP_TOOLS}"
        echo "[+] .SRCINFO updated."
    else
        echo "Error: Failed to fetch srcinfo tools."
        rm -rf "${TMP_TOOLS}"
        exit 1
    fi
fi


# vim: set filetype=bash tabstop=4 foldmethod=marker expandtab:
