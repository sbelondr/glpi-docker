
BIN_DOCKER_COMPOSE=docker-compose

all: build launch

build:
	cd docker && docker build --rm -t sbelondrade/glpi:10.0.17 .

launch:
	${BIN_DOCKER_COMPOSE} up -d
	${BIN_DOCKER_COMPOSE} ps

clean:
	${BIN_DOCKER_COMPOSE} down
	docker volume rm -f glpi-docker_glpi_data glpi-docker_mariadb_data

.PHONY: build launch clean