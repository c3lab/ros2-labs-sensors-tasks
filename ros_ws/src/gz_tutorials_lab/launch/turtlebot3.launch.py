from launch import LaunchDescription
from launch_ros.actions import Node
from launch.actions import SetEnvironmentVariable, IncludeLaunchDescription, DeclareLaunchArgument
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import PathJoinSubstitution
from launch_ros.substitutions import FindPackageShare
from ament_index_python.packages import get_package_share_directory
import os
from launch.actions import AppendEnvironmentVariable
from launch.substitutions import LaunchConfiguration
from ros_gz_bridge.actions import RosGzBridge
from launch.substitutions import PythonExpression


def generate_launch_description():
    #####################################################
    ###                 Setup Variables               ###
    #####################################################
    pkg_ros_gz_sim = FindPackageShare('ros_gz_sim')
    ros_gz_sim_pkg_path = get_package_share_directory('ros_gz_sim')
    example_pkg_path = FindPackageShare('gz_tutorials_lab')
    gz_launch_path = PathJoinSubstitution([pkg_ros_gz_sim, 'launch', 'gz_sim.launch.py'])
    bridge_path = PathJoinSubstitution([example_pkg_path, 'params/bridge_params.yaml'])
    sdf_path = PathJoinSubstitution([example_pkg_path, 'sdf_ws/turtlebot3_waffle_pi.sdf'])
    urdf_name = "turtlebot3_waffle_pi.urdf"
    urdf_path = os.path.join(
        get_package_share_directory('gz_tutorials_lab'),
        'sdf_ws',
        urdf_name)
    
    with open(urdf_path, 'r') as infp:
        robot_description = infp.read()

    rviz_config_path = os.path.join(get_package_share_directory('gz_tutorials_lab'), 'params', 'turtlebot3.rviz')
    
    #######################################################
    ###          Setup configuration variables          ###
    #######################################################
    use_sim_time = LaunchConfiguration('use_sim_time', default='true')
    declare_use_sim_time_cmd = DeclareLaunchArgument(
        'use_sim_time', default_value='true', description='Use simulation (Gazebo) clock if true'  
    )

    ros_gz_sim = get_package_share_directory('ros_gz_sim')
    world = os.path.join(
        get_package_share_directory('turtlebot3_gazebo'),
        'worlds',
        'turtlebot3_world.world'
    )

    declare_x_pose_cmd = DeclareLaunchArgument(
        'x_pose', default_value='-2.0', description='x position of the robot'
    )
    declare_y_pose_cmd = DeclareLaunchArgument(
        'y_pose', default_value='0.0', description='y position of the robot'
    )

    #######################################################
    ###          Setup configuration variables          ###
    #######################################################
    
    gzserver_cmd = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            os.path.join(ros_gz_sim, 'launch', 'gz_sim.launch.py')
        ),
        launch_arguments={'gz_args': ['-r -s -v2 ', world], 'on_exit_shutdown': 'true'}.items()
    )

    gzclient_cmd = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            os.path.join(ros_gz_sim, 'launch', 'gz_sim.launch.py')
        ),
        launch_arguments={'gz_args': '-g -v2 ', 'on_exit_shutdown': 'true'}.items()
    )

    # Spawn the robot
    start_gazebo_ros_spawner_cmd = Node(
        package='ros_gz_sim',
        executable='create',
        arguments=[
            '-name', "turtlebot3_waffle_pi",
            '-file', sdf_path,
            '-x', LaunchConfiguration('x_pose'),
            '-y', LaunchConfiguration('y_pose'),
            '-z', '0.01'
        ],
        output='screen',
    )

    # Robot State Publisher
    frame_prefix = LaunchConfiguration('frame_prefix', default='')
    robot_state_publisher_cmd = Node(
            package='robot_state_publisher',
            executable='robot_state_publisher',
            name='robot_state_publisher',
            output='screen',
            parameters=[{
                'use_sim_time': use_sim_time,
                'robot_description': robot_description,
                'frame_prefix': PythonExpression(["'", frame_prefix, "/'"])
            }],
        )

    # GZ to ROS Bridge
    declare_bridge_name_cmd = DeclareLaunchArgument(
        'bridge_name', default_value='bridge', description='Name of ros_gz_bridge node'
    )

    declare_config_file_cmd = DeclareLaunchArgument(
        'config_file', default_value=bridge_path, description='YAML config file'
    )

    ros_gz_bridge_action = RosGzBridge(
        bridge_name=LaunchConfiguration('bridge_name'),
        config_file=LaunchConfiguration('config_file'),
    )

    declare_rviz_config_file_cmd = DeclareLaunchArgument(
        'rviz_config_file', default_value=rviz_config_path, description='YAML config file'
    )

    rviz_config_file = LaunchConfiguration('rviz_config_file')

    rviz_cmd = Node(
        package='rviz2',
        executable='rviz2',
        name='rviz2',
        output='screen',
        parameters=[{'use_sim_time': use_sim_time}],
        arguments=['-d', rviz_config_file]
    )

    return LaunchDescription([
        declare_use_sim_time_cmd,
        declare_x_pose_cmd,
        declare_y_pose_cmd,
        
        gzserver_cmd,
        gzclient_cmd,
        
        start_gazebo_ros_spawner_cmd,

        robot_state_publisher_cmd,
        
        declare_bridge_name_cmd,
        declare_config_file_cmd,
        ros_gz_bridge_action,

        declare_rviz_config_file_cmd,
        rviz_cmd
    ])
