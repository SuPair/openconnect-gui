# --------------------------------------------------------------------------------------------------
# tap-windows drivers
# --------------------------------------------------------------------------------------------------
ExternalProject_Add(tap-windows
    PREFIX ${CMAKE_BINARY_DIR}/external
    INSTALL_DIR ${CMAKE_BINARY_DIR}/external
    
    UPDATE_DISCONNECTED 0
    UPDATE_COMMAND ""

    DOWNLOAD_NO_PROGRESS 1
    DOWNLOAD_NO_EXTRACT 1

    URL https://build.openvpn.net/downloads/releases/openvpn-install-2.4.12-I601-Win10.exe

    BUILD_IN_SOURCE 1

    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_if_different <DOWNLOADED_FILE> <INSTALL_DIR>/tap-windows.exe
)

install(FILES ${CMAKE_BINARY_DIR}/external/tap-windows.exe
    DESTINATION Drivers
    COMPONENT TAP_drivers
)
