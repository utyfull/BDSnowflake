# BigDataSnowflake

Лабораторную работу № 1 выполнил Пинчук Михаил Сергеевич, группа М8О-308Б-23.

Лабораторная работа по трансформации исходных CSV-данных в аналитическую модель данных типа "снежинка" на PostgreSQL.

Исходные данные лежат в папке `исходные данные`. В ней находятся 10 CSV-файлов `MOCK_DATA*.csv`, каждый по 1000 строк. При запуске контейнера все файлы автоматически загружаются в staging-таблицу `mock_data`, после чего из нее строится схема.

## Структура проекта

```text
BDSnowflake/
|-- docker-compose.yaml
|-- README.md
|-- исходные данные/
|   |-- MOCK_DATA.csv
|   |-- MOCK_DATA (1).csv
|   |-- ...
|   |-- MOCK_DATA (9).csv
|-- db/
|   |-- 01_create_stage.sql
|   |-- 02_load_stage.sql
|   |-- 03_create_snowflake_schema.sql
|   |-- 04_populate_dimensions.sql
|   |-- 05_populate_facts.sql
|   |-- 06_validation_checks.sql
|-- docs/
|   |-- snowflake_schema.plantuml
|   |-- shema.pdf
```

## Запуск

```bash
docker compose up --build
```

Подключение к PostgreSQL:

```text
Host: localhost
Port: 5432
Database: snowflake_lab
User: postgres
Password: postgres
```

## SQL-скрипты

Скрипты лежат в папке `db`. Эта папка монтируется как `/docker-entrypoint-initdb.d`.

1. `01_create_stage.sql` - создает staging-таблицу `mock_data`.
2. `02_load_stage.sql` - загружает 10 CSV-файлов в `mock_data`.
3. `03_create_snowflake_schema.sql` - создает таблицы модели "снежинка".
4. `04_populate_dimensions.sql` - заполняет измерения и справочники.
5. `05_populate_facts.sql` - заполняет таблицу фактов `fact_sale`.
6. `06_validation_checks.sql` - проверяет итоговую загрузку и выводит примеры аналитических запросов.

## Модель данных

Центральная таблица модели - `fact_sale`. В ней хранится факт продажи:

- дата продажи;
- покупатель;
- продавец;
- магазин;
- товар;
- питомец покупателя;
- количество;
- сумма продажи.

Вокруг факта находятся измерения:

- `dim_customer` - покупатели;
- `dim_seller` - продавцы;
- `dim_store` - магазины;
- `dim_product` - товары;
- `dim_pet` - питомцы покупателей;
- `dim_date` - календарь.

Чтобы модель была именно снежинкой, часть атрибутов вынесена в отдельные справочники:

- `dim_country`, `dim_city` - география;
- `dim_product_category`, `dim_pet_category` - категории;
- `dim_brand`, `dim_material`, `dim_color`, `dim_size` - свойства товара;
- `dim_supplier` - поставщики;
- `dim_pet_type`, `dim_pet_breed` - характеристики питомцев.

Диаграмма модели описана в `docs/snowflake_schema.plantuml`, готовая версия для просмотра лежит в `docs/shema.pdf`.
