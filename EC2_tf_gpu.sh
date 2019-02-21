# BEFORE STARTING PUT libcudnn5_5.1.10-1+cuda8.0_amd64.deb AND libcudnn5-dev_5.1.10-1+cuda8.0_amd64.deb IN /tmp
# OTHERWISE THIS WON'T WORK
# This has been tested only on EC2 P2 xlarge instance with 16 GB storage and stock Ubuntu 16.04
# It's a setup for a playground EC2 machine to perform workshops with Jupyter Notebook on GPU.
# It might contain some unnecessary crap
# The process takes like 15 minutes

pushd /tmp &&
wget https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64/libcudnn7_7.2.1.38-1+cuda9.0_amd64.deb&&
wget https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64/libcudnn7-dev_7.2.1.38-1+cuda9.0_amd64.deb&&
stat libcudnn7_7.2.1.38-1+cuda9.0_amd64.deb &&
stat libcudnn7-dev_7.2.1.38-1+cuda9.0_amd64.deb &&
echo "export LC_ALL=\"en_US.UTF-8\"" > ~/.profile &&
echo "export LC_CTYPE=\"en_US.UTF-8\"" > ~/.profile &&
echo "export PATH=/home/ubuntu/anaconda3/bin:\$PATH" >> ~/.profile &&
source ~/.profile &&
sudo dpkg-reconfigure --frontend=noninteractive locales &&
sudo apt-get update &&
sudo apt-get upgrade -y &&
sudo apt-get install -y build-essential git libfreetype6-dev \
  libxft-dev libncurses-dev libopenblas-dev gfortran libblas-dev \
  liblapack-dev libatlas-base-dev python-dev linux-headers-generic \
  linux-image-extra-virtual unzip swig unzip \
  wget pkg-config zip g++ zlib1g-dev libcurl3-dev &&
wget https://repo.continuum.io/archive/Anaconda3-4.3.0-Linux-x86_64.sh &&
bash Anaconda3-4.3.0-Linux-x86_64.sh -b &&
rm Anaconda3-4.3.0-Linux-x86_64.sh &&
pip install -U pip &&

# Add NVIDIA package repository
sudo apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub&&
wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_9.1.85-1_amd64.deb&&
sudo apt install ./cuda-repo-ubuntu1604_9.1.85-1_amd64.deb&&
wget http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64/nvidia-machine-learning-repo-ubuntu1604_1.0.0-1_amd64.deb&&
sudo apt install ./nvidia-machine-learning-repo-ubuntu1604_1.0.0-1_amd64.deb&&
sudo apt update&&

# Install CUDA and tools. Include optional NCCL 2.x
sudo apt install cuda9.0 cuda-cublas-9-0 cuda-cufft-9-0 cuda-curand-9-0 \
    cuda-cusolver-9-0 cuda-cusparse-9-0 libcudnn7=7.2.1.38-1+cuda9.0 \
    libnccl2=2.2.13-1+cuda9.0 cuda-command-line-tools-9-0&&

# Optional: Install the TensorRT runtime (must be after CUDA install)
#sudo apt update
#sudo apt install libnvinfer4=4.1.2-1+cuda9.0

sudo dpkg -i libcudnn7_7.2.1.38-1+cuda9.0_amd64.deb &&
sudo dpkg -i libcudnn7-dev_7.2.1.38-1+cuda9.0_amd64.deb &&
echo "export CUDA_HOME=/usr/local/cuda" >> ~/.profile &&
echo "export CUDA_ROOT=/usr/local/cuda" >> ~/.profile &&
echo "export PATH=\$PATH:\$CUDA_ROOT/bin" >> ~/.profile &&
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$CUDA_ROOT/lib64" >> ~/.profile &&
source ~/.profile &&
pip install tensorflow-gpu &&
popd &&
echo "TF Installation finished."

# Part 2: Installing and setting up Jupyter Notebook as a daemon
sudo apt-get install -y supervisor &&
echo "[program:jupyter]" >> /etc/supervisor/jupyter.conf &&
echo "user=ubuntu" >> /etc/supervisor/jupyter.conf &&
echo "/home/ubuntu/anaconda3/bin/jupyter notebook --ip=0.0.0.0" >> /etc/supervisor/jupyter.conf &&
echo "directory=/home/ubuntu/notebooks" >> /etc/supervisor/jupyter.conf &&
mkdir -p ~/notebooks &&
sudo systemctl enable supervisor &&
sudo systemctl start supervisor &&
echo "Jupyter is supervised and running in background on port 8888"