FROM python:3.9
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
COPY . /
EXPOSE 8089
CMD locust -f load_test.py $LOCUST_OPTIONS