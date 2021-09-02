from locust.env import Environment
from load_test import MongoSampleUser


if __name__ == '__main__':
    # setup Environment and Runner
    env = Environment(user_classes=[MongoSampleUser])
    env.create_local_runner()
    # start a WebUI instance
    env.create_web_ui("127.0.0.1", 8089)
    # start the test
    env.runner.start(1, spawn_rate=1)
    # wait for the greenlets
    env.runner.greenlet.join()
    # stop the web server for good measures
    env.web_ui.stop()
