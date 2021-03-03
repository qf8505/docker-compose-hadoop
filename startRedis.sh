#!/bin/bash

ssh hadoop1 "nohup /home/hadoop/elasticsearch/bin/elasticsearch > /data/es/es.log 2>& 1 &"
ssh hadoop2 "nohup /home/hadoop/elasticsearch/bin/elasticsearch > /data/es/es.log 2>& 1 &"
ssh hadoop3 "nohup /home/hadoop/elasticsearch/bin/elasticsearch > /data/es/es.log 2>& 1 &"
ssh hadoop4 "nohup /home/hadoop/elasticsearch/bin/elasticsearch > /data/es/es.log 2>& 1 &"
ssh hadoop5 "nohup /home/hadoop/elasticsearch/bin/elasticsearch > /data/es/es.log 2>& 1 &"
