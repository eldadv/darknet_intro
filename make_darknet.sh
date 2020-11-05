wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-ubuntu1604.pin

sudo mv cuda-ubuntu1604.pin /etc/apt/preferences.d/cuda-repository-pin-600

sudo apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub

sudo add-apt-repository "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/"

sudo apt-get update

sudo apt-get upgrade

sudo apt-get -y install cuda

sudo apt-get install build-essential g++ git cmake pkg-config  libgtk-3-dev libavcodec-dev libavformat-dev libswscale-dev 

sudo apt-get install python-dev python-numpy

sudo apt-get install python3-dev python3-numpy libtbb2 libtbb-dev

sudo apt-get install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev

sudo apt-get install zlib1g-dev libzstd-dev libpng16-16 libcairo2-dev libjpeg-dev libpng-dev libtiff5-dev libjasper-dev libdc1394-22-dev libeigen3-dev libtheora-dev libvorbis-dev libxvidcore-dev libx264-dev sphinx-common libtbb-dev yasm libfaac-dev libopencore-amrnb-dev libopencore-amrwb-dev libopenexr-dev libgstreamer-plugins-base1.0-dev libavutil-dev libavfilter-dev libavresample-dev

DIR="~/build"
if [ -d "$DIR" ]; then
  ### Take action if $DIR exists ###
  echo "Installing files in ${DIR}..."
else
  mkdir /build
  echo "making build dir first"
fi

cd ~/build

git clone https://github.com/opencv/opencv.git

git clone https://github.com/opencv/opencv_contrib.git

cd opencv
 
DIR="~/build/opencv/release"
if [ -d "$DIR" ]; then
  ### Take action if $DIR exists ###
  echo "Installing files in ${DIR}..."
else
  mkdir release
  echo "making release dir first"
fi
 
cd release
 
cmake -D BUILD_opencv_python3=yes -D BUILD_TIFF=ON -D WITH_CUDA=OFF -D ENABLE_AVX=ON -D WITH_OPENGL=OFF -D WITH_OPENCL=OFF -D WITH_IPP=ON -D WITH_TBB=ON -D BUILD_TBB=ON -D WITH_EIGEN=OFF -D WITH_V4L=OFF -D WITH_VTK=OFF -D WITH_GSTREAMER=OFF -D BUILD_TESTS=OFF -D BUILD_PERF_TESTS=OFF -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D OPENCV_EXTRA_MODULES_PATH=~/build/opencv_contrib/modules ~/build/opencv/
 
make -j16
 
sudo make install
 
sudo ldconfig

cd ~/build

### NOT REQUIRED
    #runtime cudnn 
    # wget MAKE A USER IN NVIDIA AND GET THIS FILE https://developer.nvidia.com/compute/machine-learning/cudnn/secure/8.0.4/11.1_20200923/Ubuntu16_04-x64/libcudnn8_8.0.4.30-1+cuda11.1_amd64.deb
    #developer cudnn
    # wget MAKE A USER IN NVIDIA AND GET THIS FILE https://developer.nvidia.com/compute/machine-learning/cudnn/secure/8.0.4/11.1_20200923/Ubuntu16_04-x64/libcudnn8-dev_8.0.4.30-1+cuda11.1_amd64.deb
    # sudo dpkg -i libcudnn8_8.0.4.30-1+cuda11.1_amd64.deb
    # sudo dpkg -i libcudnn8-dev_8.0.4.30-1+cuda11.1_amd64.deb
    # ENV CUDNN_VERSION 8.0.4.30
    # LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"
### REPLACED BY THE CUDNN FROM THE NVIDIA DOCKER BUILD
apt-get update && apt-get install -y --no-install-recommends \
    libcudnn8=8.0.4.30-1+cuda11.1 \
    libcudnn8-dev=8.0.4.30-1+cuda11.1 \
    && apt-mark hold libcudnn8 && \
    rm -rf /var/lib/apt/lists/*


git clone https://github.com/AlexeyAB/darknet.git

cd darknet

sed -i 's/GPU=0/GPU=1/g' Makefile
sed -i 's/CUDNN=0/CUDNN=1/g' Makefile
sed -i 's/OPENCV=0/OPENCV=1/g' Makefile
sed -i 's/AVX=0/AVX=1/g' Makefile
sed -i 's/OPENMP=0/OPENMP=1/g' Makefile
sed -i 's/LIBSO=0/LIBSO=1/g' Makefile
sed -i 's/NVCC=nvcc/NVCC=\/usr\/local\/cuda-11.1\/bin\/nvcc/g' Makefile

make

if [ $? -eq 0 ] ; then
  echo "darknet build success"
  wget https://pjreddie.com/media/files/yolov3.weights
  ./darknet detect cfg/yolov3.cfg yolov3.weights data/dog.jpg
else
  echo "darknet build fail"
fi

exit
 
cd ~