#
# Sample script to checkout & build 'openconnect' project
# with mingw64 toolchain
#
# It should be used only as illustration how to build application
# and create an installer package
#
# (c) 2018-2021, Lubomir Carik
#

export OC_TAG=v8.10
export STOKEN_TAG=v0.92

dnf -y install \
    mingw64-gnutls \
    mingw64-libxml2 \
    mingw64-gettext
dnf -y install \
    gcc \
    libtool \
    gettext \
    git \
    p7zip \
    patch


[ -d work ] || mkdir work
cd work

[ -d stoken ] ||  git clone https://github.com/cernekee/stoken
cd stoken
git checkout ${STOKEN_TAG}
./autogen.sh
[ -d build64 ] || mkdir build64
cd build64
git clean -fdx
mingw64-configure --disable-dependency-tracking --without-tomcrypt --without-gtk
mingw64-make -j4
mingw64-make install
cd ../../

git clone https://gitlab.com/openconnect/openconnect.git
cd openconnect
git reset --hard
git checkout ${OC_TAG}
./autogen.sh
[ -d build64 ] || mkdir build64
cd build64
git clean -fdx
mingw64-configure --disable-dependency-tracking --with-gnutls --without-openssl --without-libpskc --with-vpnc-script=vpnc-script-win.js
mingw64-make -j4
cd ../../


#
# Sample script to create a package from build 'openconnect' project
# incl. all dependencies (hardcoded paths!)
#

export MINGW_PREFIX=/usr/x86_64-w64-mingw32/sys-root/mingw

rm -rf pkg
mkdir -p pkg/nsis && cd pkg/nsis
cp ${MINGW_PREFIX}/bin/iconv.dll .
cp ${MINGW_PREFIX}/bin/libffi-7.dll .
cp ${MINGW_PREFIX}/bin/libgcc_*-1.dll .
cp ${MINGW_PREFIX}/bin/libgmp-10.dll .
cp ${MINGW_PREFIX}/bin/libgnutls-30.dll .
cp ${MINGW_PREFIX}/bin/libhogweed-4.dll .
cp ${MINGW_PREFIX}/bin/libintl-8.dll .
cp ${MINGW_PREFIX}/bin/libnettle-6.dll .
cp ${MINGW_PREFIX}/bin/libp11-kit-0.dll .
cp ${MINGW_PREFIX}/bin/libtasn1-6.dll .
cp ${MINGW_PREFIX}/bin/libwinpthread-1.dll .
cp ${MINGW_PREFIX}/bin/libxml2-2.dll .
cp ${MINGW_PREFIX}/bin/zlib1.dll .
cp ${MINGW_PREFIX}/bin/libstoken-1.dll .
cp ../../openconnect/build64/.libs/libopenconnect-5.dll .
cp ../../openconnect/build64/.libs/openconnect.exe .
curl -v -o vpnc-script-win.js https://gitlab.com/openconnect/vpnc-scripts/-/raw/master/vpnc-script-win.js
cd ../../

mkdir -p pkg/lib && cd pkg/lib
cp ${MINGW_PREFIX}/lib/libgmp.dll.a .
cp ${MINGW_PREFIX}/lib/libgnutls.dll.a .
cp ${MINGW_PREFIX}/lib/libhogweed.dll.a .
cp ${MINGW_PREFIX}/lib/libnettle.dll.a .
cp ${MINGW_PREFIX}/lib/libp11-kit.dll.a .
cp ${MINGW_PREFIX}/lib/libxml2.dll.a .
cp ${MINGW_PREFIX}/lib/libz.dll.a .
cp ${MINGW_PREFIX}/lib/libstoken.dll.a .
cp ../../openconnect/build64/.libs/libopenconnect.dll.a .
cd ../../

mkdir -p pkg/lib/pkgconfig && cd pkg/lib/pkgconfig
cp ${MINGW_PREFIX}/lib/pkgconfig/gnutls.pc .
cp ${MINGW_PREFIX}/lib/pkgconfig/hogweed.pc .
cp ${MINGW_PREFIX}/lib/pkgconfig/libxml-2.0.pc .
cp ${MINGW_PREFIX}/lib/pkgconfig/nettle.pc .
cp ${MINGW_PREFIX}/lib/pkgconfig/zlib.pc .
cp ${MINGW_PREFIX}/lib/pkgconfig/stoken.pc .
cp ../../../openconnect/build64/openconnect.pc .
cd ../../../

mkdir -p pkg/include && cd pkg/include
cp -R ${MINGW_PREFIX}/include/gnutls/ .
cp -R ${MINGW_PREFIX}/include/libxml2/ .
cp -R ${MINGW_PREFIX}/include/nettle/ .
cp -R ${MINGW_PREFIX}/include/p11-kit-1/p11-kit/ .
cp ${MINGW_PREFIX}/include/gmp.h .
cp ${MINGW_PREFIX}/include/zconf.h .
cp ${MINGW_PREFIX}/include/zlib.h .
cp ${MINGW_PREFIX}/include/stoken.h .
cp ../../openconnect/openconnect.h .
cd ../../

export MINGW_PREFIX=

cd pkg/nsis
7za a -tzip -mx=9 -sdel ../../openconnect-${OC_TAG}_mingw64.zip *
cd ../
rmdir -v nsis
7za a -tzip -mx=9 -sdel ../openconnect-devel-${OC_TAG}_mingw64.zip *
cd ../


#cd stoken/build64
#sudo mingw64-make uninstall

echo "List of system-wide used packages versions:" \
    > openconnect-${OC_TAG}_mingw64.txt
echo "openconnect-${OC_TAG}" \
    >> openconnect-${OC_TAG}_mingw64.txt
echo "stoken-${STOKEN_TAG}" \
    >> openconnect-${OC_TAG}_mingw64.txt
rpm -qv \
    mingw64-gnutls \
    mingw64-gmp \
    mingw64-nettle \
    mingw64-p11-kit \
    mingw64-zlib \
    mingw64-libxml2 \
    >> openconnect-${OC_TAG}_mingw64.txt

mv -v openconnect-*.zip openconnect-*.txt ..
