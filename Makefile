$(eval NAME := $(shell basename `pwd`))
STACKNAME := SaveWeatherForecastDataInElasticsearch
BUCKETNAME := weather_forcast_data
LOCALSTACK_NAME := $(NAME)_localstack
ES_NAME := $(NAME)_es

start-platform:
	docker-compose up -d
	PATH=$(PATH) aws --endpoint-url=http://localhost:4572 s3api create-bucket --bucket $(BUCKETNAME)

stop-platform:
	docker-compose down

network:
	$(eval NETWORK := $(shell docker network ls | grep $(NAME) | cut -f 1 -d ' '))

generate-env:
	$(eval LOCALSTACK_ID := $(shell docker ps | grep $(LOCALSTACK_NAME) | cut -f 1 -d ' '))
	$(eval LOCALSTACK_IP := $(shell docker exec -it $(LOCALSTACK_ID) hostname -i))
	$(eval ES_ID := $(shell docker ps | grep $(ES_NAME) | cut -f 1 -d ' '))
	$(eval ES_IP := $(shell docker exec -it $(ES_ID) hostname -i))
	echo '{ "$(STACKNAME)Function": { "S3_URL": "http://$(LOCALSTACK_IP):4572", "S3_REGION": "us-east-1", "ES_URL": "http://$(ES_IP):9200", "BucketName": "$(BUCKETNAME)" } }' > ./env.json

install-pkgs:
	bundle install --gemfile $(NAME)/Gemfile --path build

# 実行時は、`make invoke APIKEY=xxxxxxxxxxxxx`
invoke: network
	sam local invoke --parameter-overrides 'ParameterKey=Env,ParameterValue=dev ParameterKey=APIKEY,ParameterValue=$(APIKEY)' -t template.yaml --env-vars env.json --docker-network $(NETWORK) --event event.json

confirm-local-index:
	curl http://localhost:9200/_cat/indices?v
