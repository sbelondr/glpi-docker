
all:
	docker build --rm -t sbelondrade/glpi:10.0.17 .
	docker-compose up -d