MASTER_HOST=127.0.0.1
rm worker*.log
nohup locust -f load_test.py --worker --master-host=$MASTER_HOST > worker1.log &
nohup locust -f load_test.py --worker --master-host=$MASTER_HOST > worker2.log &
#nohup locust -f load_test.py --worker --master-host=$MASTER_HOST > worker3.log &
#nohup locust -f load_test.py --worker --master-host=$MASTER_HOST > worker4.log &
#nohup locust -f load_test.py --worker --master-host=$MASTER_HOST > worker5.log &
#nohup locust -f load_test.py --worker --master-host=$MASTER_HOST > worker6.log &
#nohup locust -f load_test.py --worker --master-host=$MASTER_HOST > worker7.log &
