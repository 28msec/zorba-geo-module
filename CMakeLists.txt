# Copyright 2006-2010 The FLWOR Foundation.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

MESSAGE(STATUS "")
MESSAGE(STATUS "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
MESSAGE(STATUS "Configuring external module <geo>")
MESSAGE(STATUS "-------------------------------------------------------------")
MESSAGE(STATUS "")

CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

PROJECT (zorba_geo_module)
ENABLE_TESTING ()
INCLUDE (CTest)

IF (WIN32)
  # On Windows we use proxy modules that try to guess first the location
  # of the required third party libraries. This will search in order in:
  # 1. the path pointed by ZORBA_THIRD_PARTY_REQUIREMENTS
  # 2. the Program Files directory available on the users computer
  # 3. the PATH environment variable
  # The logic is implemented by the macros in the ProxyFindModule.cmake module.
  LIST (APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake_modules/Windows")
ENDIF (WIN32)
LIST (APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake_modules")

FIND_PACKAGE (Zorba REQUIRED HINTS "${ZORBA_BUILD_DIR}")
INCLUDE ("${Zorba_USE_FILE}")

#
#Geos
#
IF (ZORBA_SUPPRESS_GEOS)
  MESSAGE (STATUS "ZORBA_SUPPRESS_GEOS is true - not searching for Geos.")
  
  MESSAGE(STATUS "")
  MESSAGE(STATUS "-------------------------------------------------------------")  
  MESSAGE(STATUS "Configuration SUPPRESSED for external module <geo>")
    
ELSE (ZORBA_SUPPRESS_GEOS)
  MESSAGE (STATUS "Looking for Geos")
  FIND_PACKAGE(Geos)

  IF(GEOS_FOUND)
    MESSAGE (STATUS "Found Geos library -- " ${GEOS_LIBRARIES})
    SET (GEO_LINK_LIBRARIES ${GEOS_LIBRARIES})
    
    INCLUDE_DIRECTORIES(${GEOS_INCLUDE_DIR})
    INCLUDE_DIRECTORIES("geo.xq.src")  
    
    ADD_SUBDIRECTORY("src")
    ADD_TEST_DIRECTORY("${PROJECT_SOURCE_DIR}/test")
    
    MESSAGE(STATUS "")
    MESSAGE(STATUS "-------------------------------------------------------------")
    MESSAGE(STATUS "Configuration SUCCEEDED for external module <geo>")
        
  ELSE(GEOS_FOUND)
    MESSAGE(STATUS "Geos Library Not Found. You need to install Geos library in order to compile the Geo Module.")
    
    MESSAGE(STATUS "")
    MESSAGE(STATUS "-------------------------------------------------------------")  
    MESSAGE(STATUS "Configuration FAILED for external module <geo>")
        
  ENDIF(GEOS_FOUND)
ENDIF (ZORBA_SUPPRESS_GEOS)

DONE_DECLARING_ZORBA_URIS()

MESSAGE(STATUS "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
