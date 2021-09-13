rm master.log
nohup locust -f load_test.py --master > master.log &