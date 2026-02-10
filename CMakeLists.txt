cmake_minimum_required(VERSION 3.16)

project(snote VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(snote
    src/main.cpp
    src/CommandManager.cpp
    src/include/CommandManager.h
    stickynotes.rc
)

# 生成相对当前源目录的相对路径，如 qml/Foo.qml
file(GLOB QML_FILES_ALL
     RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
     "qml/*.qml")

qt_add_qml_module(snote
    URI snote 
    QML_FILES
    ${QML_FILES_ALL}
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(snote PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.snote
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

target_link_libraries(snote
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS snote
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Packaging Configuration
set(CPACK_PACKAGE_NAME "snote")
set(CPACK_PACKAGE_VENDOR "OpsTools")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "A quick command paste tool for Ops engineers")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_PACKAGE_CONTACT "Maintainer <mingme47@gmail.com>")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")

# Generate DEB package if on Debian/Ubuntu
if(UNIX AND NOT APPLE)
    set(CPACK_GENERATOR "DEB;TGZ")
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER "OpsTools")
    set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
endif()

include(CPack)
