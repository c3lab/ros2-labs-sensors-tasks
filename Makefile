
SIM_IMAGE:=ros:lab_sensors
SIM_NAME:=ros_lab_sensors
SIM_FILE:=./docker_ws/Dockerfile.lab_sensors

RP_LIDAR_IMAGE:=ros:rp_lidar
RP_LIDAR_NAME:=ros_rp_lidar
RP_LIDAR_FILE:=./docker_ws/Dockerfile.rp_lidar

OUSTER_IMAGE:=ros:ouster
OUSTER_NAME:=ros_ouster
OUSTER_FILE:=./docker_ws/Dockerfile.ouster

USB_CAM_IMAGE:=ros:usb_cam
USB_CAM_NAME:=ros_usb_cam
USB_CAM_FILE:=./docker_ws/Dockerfile.usb_cam

EB_CAM_IMAGE:=ros:eb_cam
EB_CAM_NAME:=ros_eb_cam
EB_CAM_FILE:=./docker_ws/Dockerfile.eb_cam

ROS_DOMAIN_ID:=13

.PHONY: build_sim run_turtlebot3 exec_turtlebot3 build_rp_lidar run_rp_lidar build_ouster run_ouster build_usb_cam run_usb_cam build_eb_cam run_eb_cam build_all

build_all:
	@$(MAKE) build_sim
	@$(MAKE) build_rp_lidar
	@$(MAKE) build_ouster
	@$(MAKE) build_usb_cam
	@$(MAKE) build_eb_cam

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
    --name $(RP_LIDAR_NAME) \
	$(RP_LIDAR_IMAGE) ros2 launch rplidar_ros view_rplidar.launch.py
	
build_ouster:
	@docker build --rm -t $(OUSTER_IMAGE) -f $(OUSTER_FILE) ./docker_ws

run_ouster:
	@xhost +
	@docker run -it --rm --net host --ipc host --privileged \
    --gpus all \
    --runtime nvidia \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ~/.Xauthority:/root/.Xauthority \
    -e DISPLAY=$(DISPLAY) \
    -e XAUTHORITY=$(XAUTHORITY) \
    -e ROS_DOMAIN_ID=$(ROS_DOMAIN_ID) \
	-w /root/ros2_ws \
    --name $(OUSTER_NAME) \
	$(OUSTER_IMAGE) ros2 launch ouster_ros driver.launch.py

build_usb_cam:
	@docker build --rm -t $(USB_CAM_IMAGE) -f $(USB_CAM_FILE) ./docker_ws

run_usb_cam:
	@xhost +
	@docker run -it --rm --net host --ipc host --privileged \
    --gpus all \
    --runtime nvidia \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ~/.Xauthority:/root/.Xauthority \
    -e DISPLAY=$(DISPLAY) \
    -e XAUTHORITY=$(XAUTHORITY) \
    -e ROS_DOMAIN_ID=$(ROS_DOMAIN_ID) \
    --name $(USB_CAM_NAME) \
	$(USB_CAM_IMAGE) ros2 run usb_cam usb_cam_node_exe

build_eb_cam:
	@docker build --rm -t $(EB_CAM_IMAGE) -f $(EB_CAM_FILE) ./docker_ws
    # Setup host machine for eb camera access
    # /tmp
    # git clone https://github.com/prophesee-ai/openeb.git
    # /tmp/openeb
    # cp hal_psee_plugins/resources/rules/*.rules /etc/udev/rules.d
    # /bin/bash -ci "udevadm control --reload-rules && udevadm trigger"
    # /root
    # rm -r /tmp/openeb

run_eb_cam:
	@xhost +
	@docker run -it --rm --net host --ipc host --privileged \
    --gpus all \
    --runtime nvidia \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ~/.Xauthority:/root/.Xauthority \
    -e DISPLAY=$(DISPLAY) \
    -e XAUTHORITY=$(XAUTHORITY) \
    -e ROS_DOMAIN_ID=$(ROS_DOMAIN_ID) \
    --name $(EB_CAM_NAME) \
    -w /root/event_camera_renderer_ws \
    $(EB_CAM_IMAGE) bash