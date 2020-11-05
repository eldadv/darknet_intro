# from  https://www.learnopencv.com/training-yolov3-deep-learning-based-custom-object-detector/

# prequisite for pulling data from AWS
sudo apt install awscli
sudo pip install awscli 

# assuming you have a build directory, and that darknet is in it, parallel to where learnopencv will be
MAIN_PATH=~/build
cd $MAIN_PATH

# get the whole learnopencv repo 
git clone https://github.com/spmallick/learnopencv.git

# set a path variable to where the yolo cfg files will be
MY_PATH=$MAIN_PATH/learnopencv/YOLOv3-Training-Snowman-Detector

# check if you need to download class description file
FILE=$MY_PATH/class-descriptions-boxable.csv
if [ -f "$FILE" ]; then
    echo "$FILE exists."
else 
    echo "$FILE does not exist."
    wget https://storage.googleapis.com/openimages/2018_04/class-descriptions-boxable.csv -P $MY_PATH
fi

# check if you need to download annotation file
FILE=$MY_PATH/train-annotations-bbox.csv 
if [ -f "$FILE" ]; then
    echo "$FILE exists."
else 
    echo "$FILE does not exist."
    wget https://storage.googleapis.com/openimages/2018_04/train-annotations-bbox.csv -P $MY_PATH
fi
 
# FILE=~/build/learnopencv/YOLOv3-Training-Snowman-Detector/test-annotations-bbox.csv 
# if [ -f "$FILE" ]; then
#     echo "$FILE exists."
# else 
#     echo "$FILE does not exist."
#     wget https://storage.googleapis.com/openimages/2018_04/test-annotations-bbox.csv -P ~/build/learnopencv/YOLOv3-Training-Snowman-Detector
# fi
   
# FILE=~/build/learnopencv/YOLOv3-Training-Snowman-Detector/validation-annotations-bbox.csv 
# if [ -f "$FILE" ]; then
#     echo "$FILE exists."
# else 
#     echo "$FILE does not exist."
#     wget https://storage.googleapis.com/openimages/2018_04/validation-annotations-bbox.csv -P ~/build/learnopencv/YOLOv3-Training-Snowman-Detector
# fi

cd $MY_PATH

# check if you previously downloaded ALL snowman images from their various pointers.
# this part uses the AWS cli, and may take 2-3 hours 
TTT=$(ls ./JPEGImages/*.jpg | wc -l)
th=535
echo "number of files in JPEGImages is $TTT"
if [ "$TTT" -gt "$th" ]
then
    echo "files exists."
else 
    echo "files does not exist."
    python3 getDataFromOpenImages_snowman.py
fi

# check if you need to create a weights directory
DIR="/weights"
if [ -d "$DIR" ]; then
    # Take action if $DIR exists. #
    echo "intermediate weights exists"
else
    echo "intermediate weights missing, makeing dir"
    mkdir ./weights
fi

# split train-test
python3 splitTrainAndTest.py $MY_PATH/JPEGImages

# one-time, you need to replace the paths in darknet.data file to your local path
MY_STRING=/data-ssd/sunita/snowman
sed -i "s#$MY_STRING#$MY_PATH#g" darknet.data # using a # seprator instead of / seperator, since the paths contain /

# move to the darknet dir
cd $MAIN_PATH/darknet

# check if you need to bring the darknet pre-trained weights file from PJREDDIE
FILE=darknet53.conv.74
if [ -f "$FILE" ]; then
    echo "$FILE exists."
else 
    echo "$FILE does not exist."
    wget https://pjreddie.com/media/files/darknet53.conv.74
fi

# check the number of GPUS in you system. this line switches only between 1 (default) and 2 gpus
GPU_NUM=$(nvidia-smi --query-gpu=name --format=csv,noheader | wc -l)
th=1
if [ "$GPU_NUM" -gt "$th" ]
then
    echo "multiple gpus exists."
    GPU_STRING="-gpus 0,1"
else 
    echo "single gpu exists."
    GPU_STRING="-gpus 0"
fi
# run the trainer.
# the SUDO prefix is required since the program tries to save intermediate weights file in you HOME directory
sudo ./darknet detector train $MY_PATH/darknet.data $MY_PATH/darknet-yolov3.cfg ./darknet53.conv.74 > $MY_PATH/train.log $GPU_STRING

# Download an additional image and test the new network
wget https://www.rd.com/wp-content/uploads/2016/12/06_how_build_perfect_snowman_best_practices_decorations_tatyana_tomsickova-1024x683.jpg -O data/snowman_child.jpg
./darknet detector test $MY_PATH/darknet.data $MY_PATH/darknet-yolov3.cfg $MY_PATH/weights/darknet-yolov3_final.weights data/snowman_child.jpg

cd ~