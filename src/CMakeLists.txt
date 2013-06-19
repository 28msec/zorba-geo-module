# Copyright 2006-2008 The FLWOR Foundation.
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

#
#Geos
#
IF (ZORBA_SUPPRESS_GEOS)
  MESSAGE (STATUS "ZORBA_SUPPRESS_GEOS is true - not searching for Geos.")
ELSE (ZORBA_SUPPRESS_GEOS)

  MESSAGE (STATUS "Looking for Geos")
  FIND_PACKAGE(Geos)

  IF(GEOS_FOUND)
    MESSAGE (STATUS "Found Geos library -- " ${GEOS_LIBRARIES})
    SET (GEO_LINK_LIBRARIES ${GEOS_LIBRARIES})
    
    INCLUDE_DIRECTORIES(${GEOS_INCLUDE_DIR})
    INCLUDE_DIRECTORIES("geo.xq.src")   
    DECLARE_ZORBA_MODULE (URI "http://zorba.io/modules/geo" VERSION 1.0 FILE "geo.xq" LINK_LIBRARIES "${GEOS_LIBRARIES}")
    
    ADD_TEST_DIRECTORY("${PROJECT_SOURCE_DIR}/test")    
  ELSE(GEOS_FOUND)
    MESSAGE(STATUS "Geos Library Not Found. You need to install Geos library in order to compile the Geo Module.")
  ENDIF(GEOS_FOUND)
ENDIF (ZORBA_SUPPRESS_GEOS)
MESSAGE(STATUS "")