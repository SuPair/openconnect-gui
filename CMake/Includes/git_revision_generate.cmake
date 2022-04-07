#create a pretty commit id using git
#uses 'git describe --tags', so tags are required in the repo
#create a tag with 'git tag <name>' and 'git push --tags'

if(IS_DIRECTORY ${GIT_ROOT_DIR}/.git)
    execute_process(
        COMMAND ${GIT_EXECUTABLE} describe --tags --dirty
        WORKING_DIRECTORY ${GIT_ROOT_DIR}
        RESULT_VARIABLE res_var
        OUTPUT_VARIABLE GIT_COM_ID
    )
    
    set(GIT_COMMIT_ID "1.0.0")
    set(PROJECT_VERSION "${GIT_COMMIT_ID}")
    #string(APPEND PROJECT_VERSION " (git)")
    message(STATUS "Version: ${PROJECT_VERSION} [git]")
else()
    message(STATUS "Version: ${PROJECT_VERSION} [cmake]")
endif()

if(NOT APPLE)
    if(PROJ_ADMIN_PRIV_ELEVATION)
        set(UAC_FLAG "")
    else()
        set(UAC_FLAG "//")
    endif()

    message(STATUS "Processing resource file...")
    file(READ ${INPUT_DIR}/${PROJECT_NAME}.rc.in rc_temporary)
    string(CONFIGURE ${rc_temporary} rc_updated)
    file(WRITE ${OUTPUT_DIR}/${PROJECT_NAME}.rc.tmp ${rc_updated})
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${OUTPUT_DIR}/${PROJECT_NAME}.rc.tmp ${OUTPUT_DIR}/${PROJECT_NAME}.rc
    )
endif()

message(STATUS "Processing app info file...")
file(READ ${INPUT_DIR}/${PROJECT_NAME}.cpp.in cpp_temporary)
string(CONFIGURE "${cpp_temporary}" cpp_updated @ONLY)
file(WRITE ${OUTPUT_DIR}/${PROJECT_NAME}.cpp.tmp "${cpp_updated}")
execute_process(
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    ${OUTPUT_DIR}/${PROJECT_NAME}.cpp.tmp ${OUTPUT_DIR}/${PROJECT_NAME}.cpp
)
