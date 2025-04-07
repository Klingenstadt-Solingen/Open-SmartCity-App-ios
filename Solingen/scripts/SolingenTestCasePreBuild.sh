# Type a script or drag a script file from your workspace to insert its path.
# https://stackoverflow.com/questions/9850936/what-permissions-are-required-for-run-script-during-a-build-phase
# path to oscanetworkservice-ios root dir
SOURCE_PACKAGE_ROOT_PATH=${BUILD_DIR%Build/*}SourcePackages/checkouts/oscanetworkservice-ios
# path to library project root dir
LIBRARY_ROOT_PATH=${PROJECT_DIR%Solingen*}modules/OSCANetworkService/OSCANetworkService/OSCATestCaseExtension/Resources
# base name:
CONFIG_FILE_BASE_NAME="API"
# release name "API_Release.plist"
CONFIG_FILE_NAME_RELEASE=${CONFIG_FILE_BASE_NAME}_Release.plist
# debug name "API_Develop.plist"
CONFIG_FILE_NAME_DEBUG=${CONFIG_FILE_BASE_NAME}_Develop.plist
# sample release name "API_Release-Sample.plist
SAMPLE_CONFIG_FILE_NAME_RELEASE=${CONFIG_FILE_BASE_NAME}_Release-Sample.plist
# sample debug name "API_Develop-Sample.plist"
SAMPLE_CONFIG_FILE_NAME_DEBUG=${CONFIG_FILE_BASE_NAME}_Develop-Sample.plist
# debug file path ".../API_Develop.plist"
# CONFIG_DEBUG_FILE_PATH=$SRCROOT/$PRODUCT_NAME/$CONFIG_FILE_NAME_DEBUG
CONFIG_DEBUG_FILE_PATH=$SOURCE_PACKAGE_ROOT_PATH/OSCANetworkService/OSCATestCaseExtension/Resources/$CONFIG_FILE_NAME_DEBUG
# debug source file path
CONFIG_DEBUG_SOURCE_FILE_PATH=$LIBRARY_ROOT_PATH/$CONFIG_FILE_NAME_DEBUG
# release file path ".../API_Release.plist"
CONFIG_RELEASE_FILE_PATH=$SOURCE_PACKAGE_ROOT_PATH/OSCANetworkService/OSCATestCaseExtension/Resources/$CONFIG_FILE_NAME_RELEASE
# release source file path
CONFIG_RELEASE_SOURCE_FILE_PATH=$LIBRARY_ROOT_PATH/$CONFIG_FILE_NAME_RELEASE
# sample release file path ".../API_Release-Sample.plist"
SAMPLE_CONFIG_RELEASE_FILE_PATH=$SOURCE_PACKAGE_ROOT_PATH/OSCANetworkService/OSCATestCaseExtension/Resources/$SAMPLE_CONFIG_FILE_NAME_RELEASE
# sample debug file path ".../API_Develop-Sample.plist"
SAMPLE_CONFIG_DEBUG_FILE_PATH=$SOURCE_PACKAGE_ROOT_PATH/OSCANetworkService/OSCATestCaseExtension/Resources/$SAMPLE_CONFIG_FILE_NAME_DEBUG

# copy phase release
if [ -f "$CONFIG_RELEASE_SOURCE_FILE_PATH" ]; then
  echo "$CONFIG_RELEASE_SOURCE_FILE_PATH exists."
  if [ -f "$CONFIG_RELEASE_FILE_PATH" ]; then
    rm -v "${CONFIG_RELEASE_FILE_PATH}"
  fi
  cp -v "${CONFIG_RELEASE_SOURCE_FILE_PATH}" "${CONFIG_RELEASE_FILE_PATH}"
  echo "$CONFIG_FILE_NAME_RELEASE copied to $CONFIG_RELEASE_FILE_PATH"
else
  echo "$CONFIG_RELEASE_SOURCE_FILE_PATH does not exist!"
fi
# copy phase debug
if [ -f "$CONFIG_DEBUG_SOURCE_FILE_PATH" ]; then
  echo "$CONFIG_DEBUG_SOURCE_FILE_PATH exists."
  if [ -f "$CONFIG_DEBUG_FILE_PATH" ]; then
    rm -v "${CONFIG_DEBUG_FILE_PATH}"
  fi
  cp -v "${CONFIG_DEBUG_SOURCE_FILE_PATH}" "${CONFIG_DEBUG_FILE_PATH}"
  echo "$CONFIG_FILE_NAME_DEBUG copied to $CONFIG_DEBUG_FILE_PATH"
else
  echo "$CONFIG_DEBUG_SOURCE_FILE_PATH does not exist!"
fi

# if release file path exists
if [ -f "$CONFIG_RELEASE_FILE_PATH" ]; then
  # then echo
  echo "$CONFIG_RELEASE_FILE_PATH exists."
else
  # else copy sample release file
  echo "$CONFIG_RELEASE_FILE_PATH does not exist, copying sample"
  cp -v "${SAMPLE_CONFIG_RELEASE_FILE_PATH}" "${CONFIG_RELEASE_FILE_PATH}"
fi
# if debug file path exists
if [ -f "$CONFIG_DEBUG_FILE_PATH" ]; then
  echo "$CONFIG_DEBUG_FILE_PATH exists."
else
  # else copy sample debug file
  echo "$CONFIG_DEBUG_FILE_PATH does not exist, copying sample"
  cp -v "${SAMPLE_CONFIG_DEBUG_FILE_PATH}" "${CONFIG_DEBUG_FILE_PATH}"
fi
