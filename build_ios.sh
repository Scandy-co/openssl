set -e
###################################
# 		 OpenSSL Version
###################################
OPENSSL_VERSION="openssl-1.0.2d"
###################################

###################################
# 		 SDK Version
###################################
IOS_SDK_VERSION=$(xcodebuild -version -sdk iphoneos | grep SDKVersion | cut -f2 -d ':' | tr -d '[[:space:]]')
###################################

################################################
# 		 Minimum iOS deployment target version
################################################
MIN_IOS_VERSION="10.0"

DEVELOPER=`xcode-select -print-path`
PLATFORM='iPhoneOS'
ARCH="arm64"

export $PLATFORM
export CROSS_TOP="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
export CROSS_SDK="${PLATFORM}${IOS_SDK_VERSION}.sdk"
export BUILD_TOOLS="${DEVELOPER}"
# export CC="${BUILD_TOOLS}/usr/bin/gcc -fembed-bitcode -mios-version-min=${MIN_IOS_VERSION} -arch ${ARCH}"
export CC="${BUILD_TOOLS}/usr/bin/gcc -mios-version-min=${MIN_IOS_VERSION} -arch ${ARCH}"

echo "Start Building ${OPENSSL_VERSION} for ${PLATFORM} ${IOS_SDK_VERSION} ${ARCH}"

sed -ie "s!static volatile sig_atomic_t intr_signal;!static volatile intr_signal;!" "crypto/ui/ui_openssl.c"

./Configure iphoneos-cross --openssldir="${PWD}/build"

# add -isysroot to CC=
sed -ie "s!^CFLAG=!CFLAG=-isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} -mios-version-min=${MIN_IOS_VERSION} !" "Makefile"

echo "make"
make
