# Script to install NDK 25c into AndroidIDE
# Author MrIkso (modified for official NDK 25c)

install_dir=$HOME
sdk_dir=$install_dir/android-sdk
cmake_dir=$sdk_dir/cmake
ndk_base_dir=$sdk_dir/ndk

ndk_dir="$ndk_base_dir/25.2.9519653"
ndk_ver="25.2.9519653"
ndk_ver_name="r25c"
ndk_file_name="android-ndk-r25c-linux.zip"
ndk_installed=false
cmake_installed=false
is_lzhiyong_ndk=false
is_bionic_ndk=false

run_install_cmake() {
	download_cmake 3.10.2
	download_cmake 3.18.1
	download_cmake 3.22.1
	download_cmake 3.25.1
}

download_cmake() {
	cmake_version=$1
	echo "Downloading cmake-$cmake_version..."
	wget https://github.com/MrIkso/AndroidIDE-NDK/releases/download/cmake/cmake-"$cmake_version"-android-aarch64.zip --no-verbose --show-progress -N
	installing_cmake "$cmake_version"
}

download_ndk() {
	echo "Downloading NDK $1..."
	wget $2 --no-verbose --show-progress -N
}

fix_ndk() {
	if [ -d "$ndk_dir" ]; then
		echo "Creating missing links..."
		cd "$ndk_dir"/toolchains/llvm/prebuilt || exit
		ln -s linux-aarch64 linux-x86_64
		cd "$ndk_dir"/prebuilt || exit
		ln -s linux-aarch64 linux-x86_64
		cd "$install_dir" || exit

		echo "Patching cmake configs..."
		sed -i 's/if(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)/if(CMAKE_HOST_SYSTEM_NAME STREQUAL Android)\nset(ANDROID_HOST_TAG linux-aarch64)\nelseif(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)/g' "$ndk_dir"/build/cmake/android-legacy.toolchain.cmake
		sed -i 's/if(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)/if(CMAKE_HOST_SYSTEM_NAME STREQUAL Android)\nset(ANDROID_HOST_TAG linux-aarch64)\nelseif(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)/g' "$ndk_dir"/build/cmake/android.toolchain.cmake
		ndk_installed=true
	else
		echo "NDK does not exists."
	fi
}

installing_cmake() {
	cmake_version=$1
	cmake_file=cmake-"$cmake_version"-android-aarch64.zip
	if [ -f "$cmake_file" ]; then
		echo "Unziping cmake..."
		unzip -qq "$cmake_file" -d "$cmake_dir"
		rm "$cmake_file"
		chmod -R +x "$cmake_dir"/"$cmake_version"/bin
		cmake_installed=true
	else
		echo "$cmake_file does not exists."
	fi
}

echo "Installing Android NDK $ndk_ver_name ($ndk_ver) only..."
cd "$install_dir" || exit

# Remove old NDK if exists
if [ -d "$ndk_dir" ]; then
	echo "$ndk_dir exists. Deleting..."
	rm -rf "$ndk_dir"
fi

# Remove old cmake
rm -rf "$cmake_dir"/3.10.2 "$cmake_dir"/3.18.1 "$cmake_dir"/3.22.1 "$cmake_dir"/3.25.1

# Download NDK from official Google link
download_ndk "$ndk_file_name" "https://dl.google.com/android/repository/android-ndk-r25c-linux.zip"

# Extract NDK
if [ -f "$ndk_file_name" ]; then
	echo "Unziping NDK $ndk_ver_name..."
	unzip -qq "$ndk_file_name"
	rm "$ndk_file_name"

	if [ -d "$ndk_base_dir" ]; then
		mv android-ndk-r25c "$ndk_dir"
	else
		mkdir -p "$ndk_base_dir"
		mv android-ndk-r25c "$ndk_dir"
	fi

	fix_ndk
else
	echo "$ndk_file_name does not exists."
fi

# Install CMake
mkdir -p "$cmake_dir"
cd "$cmake_dir"
run_install_cmake

if [[ $ndk_installed == true && $cmake_installed == true ]]; then
	echo 'Installation Finished. NDK has been installed successfully, please restart AndroidIDE!'
else
	echo 'NDK and cmake installation failed!'
fi
