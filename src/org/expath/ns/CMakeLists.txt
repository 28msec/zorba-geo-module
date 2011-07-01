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

FIND_PACKAGE(Geos)

IF(GEOS_FOUND)
  INCLUDE_DIRECTORIES(${GEOS_INCLUDE_DIR})
  DECLARE_ZORBA_MODULE (URI "http://expath.org/ns/geo" VERSION 1.0 FILE "geo.xq" LINK_LIBRARIES "${GEOS_LIBRARIES}")
ELSE(GEOS_FOUND)
  MESSAGE(STATUS "Geos Library Not Found. You need to install Geos library in order to compile the Geo Module.")
ENDIF(GEOS_FOUND)
