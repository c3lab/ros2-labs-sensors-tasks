
SIM_IMAGE:=ros:lab_sensors
SIM_NAME:=ros_lab_sensors
SIM_FILE:=./docker_ws/Dockerfile.lab_sensors

RP_LIDAR_IMAGE:=ros:rp_lidar
RP_LIDAR_NAME:=ros_rp_lidar
RP_LIDAR_FILE:=./docker_ws/Dockerfile.rp_lidar


ROS_DOMAIN_ID:=13

.PHONY: build_sim run_turtlebot3 exec_turtlebot3 build_rp_lidar run_rp_lidar build_all

build_all:
	@$(MAKE) build_sim
	@$(MAKE) build_rp_lidar

build_sim:
	@docker build --rm -t $(SIM_IMAGE) -f $(SIM_FILE) ./docker_ws

run_turtlebot3:
	@xhost +
	@docker run -it --rm --net host --ipc host --privileged \
    --gpus all \
    --runtime nvidia \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ~/.Xauthority:/root/.Xauthority \
    -e DISPLAY=$(DISPLAY) \
    -e XAUTHORITY=$(XAUTHORITY) \
    -e ROS_DOMAIN_ID=$(ROS_DOMAIN_ID) \
    -v ./ros_ws/:/root/ros_workspace \
	-w /root/ros_workspace \
    --name $(SIM_NAME) \
	$(SIM_IMAGE) bash

exec_turtlebot3:
	@docker exec -it $(SIM_NAME) bash

build_rp_lidar:
	@docker build --rm -t $(RP_LIDAR_IMAGE) -f $(RP_LIDAR_FILE) ./docker_ws

run_rp_lidar:
	@xhost +
	@docker run -it --rm --net host --ipc host --privileged \
    --gpus all \
    --runtime nvidia \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ~/.Xauthority:/root/.Xauthority \
    -e DISPLAY=$(DISPLAY) \
    -e XAUTHORITY=$(XAUTHORITY) \
    -e ROS_DOMAIN_ID=$(ROS_DOMAIN_ID) \
    -v ./ros_ws/:/root/ros_workspace \
	-w /root/ros_workspace \
    --name $(RP_LIDAR_NAME) \
	$(RP_LIDAR_IMAGE) ros2 launch rplidar_ros view_rplidar.launch.py
	
