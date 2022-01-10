# planner

## development quickstart

```bash
podman run --name planner-db -e POSTGRES_PASSWORD=password -p 5432:5432
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```
