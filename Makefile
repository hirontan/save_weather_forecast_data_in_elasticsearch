$(eval NAME := $(shell basename `pwd`))
STACKNAME := SaveWeatherForecastDataInElasticsearch

start-platform:
	docker-compose up -d

stop-platform:
	docker-compose down
