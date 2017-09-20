#=============================================================================
# Copyright 2016 Sam Hanes
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file COPYING.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake-Microchip,
#  substitute the full License text for the above reference.)


function(add_bin2hex_target target)
    find_program(MICROCHIP_BIN2HEX
        NAMES ${_CMAKE_TOOLCHAIN_PREFIX}bin2hex bin2hex
        HINTS ${_CMAKE_TOOLCHAIN_LOCATION}
    )

    if(NOT MICROCHIP_BIN2HEX)
        message(SEND_ERROR "No bin2hex program was found. _CMAKE_TOOLCHAIN_PREFIX=${_CMAKE_TOOLCHAIN_PREFIX}")
    endif()

    function(get_target_property_fallback var target)
        set(result NOTFOUND)
        foreach(property ${ARGN})
            get_target_property(result ${target} ${property})
            if(result)
                break()
            endif()
        endforeach()
        set(${var} ${result} PARENT_SCOPE)
    endfunction()

    get_target_property_fallback(in_f ${target}
        RUNTIME_OUTPUT_NAME
        OUTPUT_NAME
        NAME
    )

    get_target_property_fallback(dir ${target}
        RUNTIME_OUTPUT_DIRECTORY
        BINARY_DIR
    )

    get_filename_component(out_f ${in_f} NAME_WE)
    set(out_f "${out_f}.hex")

    add_custom_command(
        #TARGET ${target} POST_BUILD
        OUTPUT ${dir}/${out_f}
        DEPENDS ${target}
        WORKING_DIRECTORY ${dir}
        COMMAND "${MICROCHIP_BIN2HEX}" "${in_f}"
        VERBATIM
    )
    add_custom_target(bin2hex_${target}
        DEPENDS ${dir}/${out_f}
    )
    
    if(NOT TARGET bin2hex)
        add_custom_target(bin2hex ALL)
        #message(STATUS "bin2hex not exits")
    endif()
    
    add_dependencies(bin2hex 
        bin2hex_${target}
    )

    set_property(DIRECTORY APPEND
        PROPERTY ADDITIONAL_MAKE_CLEAN_FILES
            ${dir}/${out_f}
    )
endfunction()
