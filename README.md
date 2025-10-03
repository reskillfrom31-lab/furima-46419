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


## items テーブル

| Column | Type   | Options     |
| ------ | ------ | ----------- |
| id     | integer| null: false, primary_key: true |
| user | references | null: false, foreign_key: true |
| name   | string | null: false |
| item_info | text | null: false |
| category_id | references | null: false |
| status_id | references | null: false |
| fee_type_id | references | null: false |
| prefecture_id | references | null: false |
| schedule | references | null: false |
| price | integer | null: false |
| created_at | datetime | null: false |
| updated_at | datetime | null: false |

### Association

- belongs_to :user
- has_one :order
- has_many :comments

## comments テーブル

| Column  | Type       | Options                        |
| ------- | ---------- | ------------------------------ |
| id      | integer    | null: false, primary_key: true |
| user | references | null: false, foreign_key: true |
| item_id | references | null: false, foreign_key: true |
| content | text | null: false |

### Association

- belongs_to :user
- belongs_to :item


## orders テーブル

| Column | Type   | Options     |
| ------ | ------ | ----------- |
| id     | integer | null: false, primary_key: true |
| user | references | null: false, foreign_key: true |
| item | references | null: false, foreign_key: true |
| created_at | datetime | null: false |
| updated_at | datetime | null: false |

### Association

- belongs_to :user
- belongs_to :item


## addresses テーブル

| Column | Type       | Options                        |
| ------ | ---------- | ------------------------------ |
| id     | integer | null: false, primary_key: true |
| order | references | null: false, foreign_key: true |
| postal_code | string | null: false |
| prefecture | references | null: false |
| city | string | null:false |
| address | text | null:false |
| building | string | null: true |
| phone_number | string | null:false |

### Association
- belongs_to :user
- belongs_to :item
- belongs_to :order
- belongs_to :prefecture