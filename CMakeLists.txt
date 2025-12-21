cmake_minimum_required(VERSION 3.20)
project(StudyMoney LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Gui Quick Qml QuickControls2 Sql)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(StudyMoney
    main.cpp
    Controller/maincontroller.h
    Controller/maincontroller.cpp
    Model/istorage.h
    Model/sqlstorage.h
    Model/sqlstorage.cpp
)

qt_add_qml_module(StudyMoney
    URI StudyMoney
    VERSION 1.0
    RESOURCE_PREFIX "/"
    QML_FILES
        View/Main.qml
)

target_link_libraries(StudyMoney PRIVATE
    Qt6::Core Qt6::Gui Qt6::Quick Qt6::Qml Qt6::QuickControls2 Qt6::Sql
)

if(WIN32)
    set_target_properties(StudyMoney PROPERTIES WIN32_EXECUTABLE ON)
endif()
if(APPLE)
    set_target_properties(StudyMoney PROPERTIES MACOSX_BUNDLE ON)
endif()