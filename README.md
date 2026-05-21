# ros2-labs-sensors-tasks
Sensors and tasks

---

# Ouster

## Ouster discovery
setup the ethernet connection to link local 

sudo nmap -sn 169.254.0.0/16 --min-parallelism 200

---

# Event-Based Cam

## Terminal 1
Launch the driver node with:<br>
```ros2 launch metavision_driver driver_node.launch.py```

## Terminal 2
Required to bring the events into image format.
Launch the accumulator node with:<br>
```source /root/.bashrc``` <br>
```ros2 launch event_camera_renderer renderer.launch.py```

## Terminal 3
Launch RViz and the image topic.

### Tested with:

metavision_driver --> 6b7297c9b3f9e95cb5da1e828731f59f9f37c6ce <br>
event_camera_renderer --> bb11776fb49493a25d83983694ea73b440e2c78e