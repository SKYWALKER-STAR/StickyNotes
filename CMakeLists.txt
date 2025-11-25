cmake_minimum_required(VERSION 3.16)

project(cpaste_quick VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(cmdbox
    main.cpp
    CommandManager.cpp
    CommandManager.h
)

qt_add_qml_module(cmdbox
    URI cpaste_quick
    QML_FILES
        Main.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(cmdbox PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.cmdbox
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(cmdbox
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS cmdbox
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Packaging Configuration
set(CPACK_PACKAGE_NAME "cmdbox")
set(CPACK_PACKAGE_VENDOR "OpsTools")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "A quick command paste tool for Ops engineers")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_PACKAGE_CONTACT "Maintainer <maintainer@example.com>")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")

# Generate DEB package if on Debian/Ubuntu
if(UNIX AND NOT APPLE)
    set(CPACK_GENERATOR "DEB;TGZ")
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER "OpsTools")
    set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
endif()

include(CPack)
