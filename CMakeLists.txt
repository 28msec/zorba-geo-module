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

CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

PROJECT (zorba_geo_module)
ENABLE_TESTING ()
INCLUDE (CTest)

LIST (APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake_modules")

FIND_PACKAGE (Zorba REQUIRED HINTS "${ZORBA_BUILD_DIR}")
INCLUDE ("${Zorba_USE_FILE}")

ADD_TEST_DIRECTORY("${PROJECT_SOURCE_DIR}/test")
ADD_SUBDIRECTORY("src")

EXPECTED_FAILURE("zorba_geo_module/geo/dms1.xq" 3303740)
EXPECTED_FAILURE("zorba_geo_module/geo/dms2.xq" 3303740)
EXPECTED_FAILURE("zorba_geo_module/geo/geoproj1.xq" 3303740)
EXPECTED_FAILURE("zorba_geo_module/geo/geoproj2.xq" 3303740)
EXPECTED_FAILURE("zorba_geo_module/geo/geoproj3.xq" 3303740)
EXPECTED_FAILURE("zorba_geo_module/geo/geoproj4.xq" 3303740)
EXPECTED_FAILURE("zorba_geo_module/geo/geoproj5.xq" 3303740)
EXPECTED_FAILURE("zorba_geo_module/geo/geoproj6.xq" 3303740)
EXPECTED_FAILURE("zorba_geo_module/geo/geoproj7.xq" 3303740)
EXPECTED_FAILURE("zorba_geo_module/geo/geoproj8.xq" 3303740)
EXPECTED_FAILURE("zorba_geo_module/geo/geoproj9.xq" 3303740)
EXPECTED_FAILURE("zorba_geo_module/geo/geoproj10.xq" 3303740)
EXPECTED_FAILURE("zorba_geo_module/geo/geoproj11.xq" 3303740)
EXPECTED_FAILURE("zorba_geo_module/geo/geoproj12.xq" 3303740)
