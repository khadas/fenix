prefix=/usr
exec_prefix=${prefix}
libdir=${prefix}/@CMAKE_INSTALL_LIBDIR@
includedir=${prefix}/@CMAKE_INSTALL_INCLUDEDIR@

Name: mali
Description: Mali EGL library
Requires.private: 
Libs: -L${libdir} -lMali
Cflags: -I${includedir} 
