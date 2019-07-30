$(eval NAME := $(shell basename `pwd`))
STACKNAME := SaveWeatherForecastDataInElasticsearch
BUCKETNAME := weather_forcast_data
LOCALSTACK_NAME := $(NAME)_localstack

start-platform:
	docker-compose up -d

stop-platform:
	docker-compose down

network:
	$(eval NETWORK := $(shell docker network ls | grep $(PROJECT) | cut -f 1 -d ' '))

generate-env:
	$(eval LOCALSTACK_ID := $(shell docker ps | grep $(LOCALSTACK_NAME) | cut -f 1 -d ' '))
	$(eval LOCALSTACK_IP := $(shell docker exec -it $(LOCALSTACK_ID) hostname -i))
i	echo '{ "$(STACKNAME)Function": { "Env": "dev", "S3_URL": "http://$(LOCALSTACK_IP):4572", "S3_REGION": "us-east-1", "BucketName": "$(BUCKETNAME)" } }' > ./env.json

install-pkgs:
	bundle install --gemfile $(NAME)/Gemfile --path build

invoke: network
	sam local invoke --parameter-overrides ParameterKey=Env,ParameterValue=dev -t template.yaml --env-vars env.json --docker-network $(NETWORK) --event event.json
