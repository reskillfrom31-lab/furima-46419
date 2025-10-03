# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

# テーブル設計

## users テーブル

| Column             | Type    | Options     |
| ------------------ | ------- | ----------- |
| id                 | integer | null: false, primary_key: true |
| nickname           | string  | null: false |
| email              | string  | null: false, unique: true |
| encrypted_password | string  | null: false |
| last_name          | string  | null: false |
| first_name         | string  | null: false |
| last_name_kana     | string  | null: false |
| first_name_kana    | string  | null: false |
| birth_date         | date    | null: false |


## items テーブル

| Column | Type   | Options     |
| ------ | ------ | ----------- |
| id     | integer| null: false, primary_key: true |
| user_id | integer | null:false, foreign_key: true |
| image | string | null: false |
| name   | string | null: false |
| item_info | string | null: false |
| category_id | integer | null: false, foreign_key: true|
| status_id | integer | null: false, foreign_key: true|
| fee_type_id | string | null: false, foreign_key: true|
| prefecture_id | integer | null: false, foreign_key: true|
| schedule_id | integer | null: false, foreign_key: true|
| price | integer | null: false |

## orders テーブル

| Column | Type   | Options     |
| ------ | ------ | ----------- |
| id     | integer| null: false, primary_key: true |
| user_id | integer | null:false, foreign_key: true |
| item_id | integer | null: false, foreign_key: true |
| card_token | string | null: false |

## comments テーブル

| Column  | Type       | Options                        |
| ------- | ---------- | ------------------------------ |
| id      | integer    | null: false, primary_key: true |
| user_id | integer | null: false, foreign_key: true |
| item_id | integer | null: false, foreign_key: true |
| content | text | null: false |


## addresses テーブル

| Column | Type       | Options                        |
| ------ | ---------- | ------------------------------ |
| id     | integer| null: false, primary_key: true |
| order_id | integer | null: false, foreign_key: true|
| postal_code | integer | null: false |
| prefecture_id | integer | null: false, foreign_key: true|
| city | string | null:false |
| address | text | null:false |
| building | string | null:false |
| phone_number | integer | null:false |


## prefectures テーブル

| Column  | Type       | Options                        |
| ------- | ---------- | ------------------------------ |
| id      | integer    | null: false, primary_key: true |
| prefecture_name | string | null: false |

## categories テーブル

| Column  | Type       | Options                        |
| ------- | ---------- | ------------------------------ |
| id      | integer    | null: false, primary_key: true |
| categories_name | string | null: false |

##  statusesテーブル

| Column  | Type       | Options                        |
| ------- | ---------- | ------------------------------ |
| id      | integer    | null: false, primary_key: true |
| status_name | string | null: false |

##  fee_typesテーブル

| Column  | Type       | Options                        |
| ------- | ---------- | ------------------------------ |
| id      | integer    | null: false, primary_key: true |
| fee_type | string | null: false |

##  schedulesテーブル

| Column  | Type       | Options                        |
| ------- | ---------- | ------------------------------ |
| id      | integer    | null: false, primary_key: true |
| schedule_name | string | null: false |