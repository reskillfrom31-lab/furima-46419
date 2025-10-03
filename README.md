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
| created_at         | datetime| null: false |
| updated_at         | datetime| null: false |

### Association

- has_many :items
- has_many :orders
- has_many :comments
- has_many :addresses


## items テーブル

| Column | Type   | Options     |
| ------ | ------ | ----------- |
| id     | integer| null: false, primary_key: true |
| user_id | integer | null:false, foreign_key: true |
| image | string | null: false |
| name   | string | null: false |
| item_info | text | null: false |
| category_id | integer | null: false, foreign_key: true|
| status_id | integer | null: false, foreign_key: true|
| fee_type_id | integer | null: false, foreign_key: true|
| prefecture_id | integer | null: false, foreign_key: true|
| schedule_id | integer | null: false, foreign_key: true|
| price | integer | null: false |
| created_at | datetime | null: false |
| updated_at | datetime | null: false |


### Association

- belongs_to :user
- has_one :order
- has_many :comments
- belongs_to :prefecture
- belongs_to :category
- belongs_to :status
- belongs_to :fee_type
- belongs_to :schedule

## comments テーブル

| Column  | Type       | Options                        |
| ------- | ---------- | ------------------------------ |
| id      | integer    | null: false, primary_key: true |
| user_id | integer | null: false, foreign_key: true |
| item_id | integer | null: false, foreign_key: true |
| content | text | null: false |

### Association

- belongs_to :user
- belongs_to :item


## orders テーブル

| Column | Type   | Options     |
| ------ | ------ | ----------- |
| id     | integer | null: false, primary_key: true |
| user_id | integer | null:false, foreign_key: true |
| item_id | integer | null: false, foreign_key: true |
| card_token | string | null: false |
| created_at | datetime | null: false |
| updated_at | datetime | null: false |

### Association

- belongs_to :user
- belongs_to :item


## addresses テーブル

| Column | Type       | Options                        |
| ------ | ---------- | ------------------------------ |
| id     | integer| null: false, primary_key: true |
| order_id | integer | null: false, foreign_key: true|
| postal_code | string | null: false |
| prefecture_id| integer | null: false, foreign_key: true|
| city | string | null:false |
| address | text | null:false |
| building | string | null: true |
| phone_number | string | null:false |


### Association

- belongs_to :order
- belongs_to :prefecture


## prefectures テーブル

| Column  | Type       | Options                        |
| ------- | ---------- | ------------------------------ |
| id      | integer    | null: false, primary_key: true |
| prefecture_name | string | null: false, unique: true |

### Association

- has_many :items
- has_many :addresses


## categories テーブル

| Column  | Type       | Options                        |
| ------- | ---------- | ------------------------------ |
| id      | integer    | null: false, primary_key: true |
| categories_name | string | null: false, unique: true |

### Association

- has_many :items


##  statusesテーブル

| Column  | Type       | Options                        |
| ------- | ---------- | ------------------------------ |
| id      | integer    | null: false, primary_key: true |
| status_name | string | null: false, unique: true |

### Association

- has_many :items


##  fee_typesテーブル

| Column  | Type       | Options                        |
| ------- | ---------- | ------------------------------ |
| id      | integer    | null: false, primary_key: true |
| fee_type | string | null: false, unique: true|

### Association

- has_many :items

##  schedulesテーブル

| Column  | Type       | Options                        |
| ------- | ---------- | ------------------------------ |
| id      | integer    | null: false, primary_key: true |
| schedule_name | string | null: false, unique: true|

### Association

- has_many :items