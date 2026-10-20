import setuptools

setuptools.setup(
    name="onap_robot_tracing",
    version="1",
    packages=["onap_robot_tracing"],
    entry_points={
        "xtesting.testcase": [
            "robotframework_otel = onap_robot_tracing.driver:TracedRobotFramework"
        ]
    }
)
