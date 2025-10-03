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
| nickname           | string  | null: false |
| email              | string  | null: false, unique: true |
| encrypted_password | string  | null: false |
| last_name          | string  | null: false |
| first_name         | string  | null: false |
| last_name_kana     | string  | null: false |
| first_name_kana    | string  | null: false |
| birth_date         | date    | null: false |

### Association

- has_many :items
- has_many :orders


## items テーブル

| Column | Type   | Options     |
| ------ | ------ | ----------- |
| user | references | null: false, foreign_key: true |
| name   | string | null: false |
| item_info | text | null: false |
| category_id | integer | null: false |
| status_id | integer | null: false |
| fee_id | integer | null: false |
| prefecture_id | integer | null: false |
| schedule_id | integer | null: false |
| price | integer | null: false |

### Association

- belongs_to :user
- has_one :order


## orders テーブル

| Column | Type   | Options     |
| ------ | ------ | ----------- |
| user | references | null: false, foreign_key: true |
| item | references | null: false, foreign_key: true |

### Association

- belongs_to :user
- belongs_to :item
- has_one :address


## addresses テーブル

 Column | Type   | Options     |
| ------ | ------ | ----------- |
| oreder | references | null: false, foreign_key: true |
| prefecture_id | integer | null: false |
| city | string | null: false |
| address | string | null: false |
| building_name | string |

### Association

- belongs_to :order