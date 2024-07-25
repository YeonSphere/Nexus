# Find the TensorFlow library
find_path(TENSORFLOW_INCLUDE_DIR tensorflow/c/c_api.h
  HINTS ${TENSORFLOW_ROOT_DIR}/include
  HINTS C:/Python312/Lib/site-packages/tensorflow/include
)

find_library(TENSORFLOW_LIBRARY
  NAMES tensorflow
  HINTS ${TENSORFLOW_ROOT_DIR}/lib
  HINTS C:/Python312/Lib/site-packages/tensorflow
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(TensorFlow DEFAULT_MSG TENSORFLOW_LIBRARY TENSORFLOW_INCLUDE_DIR)

if (TENSORFLOW_FOUND)
  set(TENSORFLOW_LIBRARIES ${TENSORFLOW_LIBRARY})
  set(TENSORFLOW_INCLUDE_DIRS ${TENSORFLOW_INCLUDE_DIR})
else ()
  message(FATAL_ERROR "Could not find TensorFlow library")
endif ()
