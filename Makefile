up-db:
	docker compose --profile db up --build -d 

down-db:
	docker compose --profile db down

up-kafka:
	docker compose --profile kafka up --build -d 

down-kafka:
	docker compose --profile kafka down

up-airflow:
	docker compose --profile airflow up --build -d

down-airflow:
	docker compose --profile airflow down
