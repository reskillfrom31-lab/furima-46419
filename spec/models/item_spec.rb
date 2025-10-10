require 'rails_helper'

RSpec.describe Item, type: :model do
  before do
    @item=FactoryBot.build(:item)
  end

  describe '商品出品機能' do
    context '商品出品できる場合' do
      it '写真とすべての必須項目が正しく入力されていれば出品できる' do
        expect(@item).to be_valid
      end
    end

    context '商品出品できない場合' do
      #ユーザー紐づけ
      it 'userが紐付いていないと保存できない' do
        @item.user = nil
        @item.valid?
        expect(@item.errors.full_messages).to include('User must exist')
      end
      
      #画像
      it '画像が空では登録できない' do
        @item.image = nil
        @item.valid?
        expect(@item.errors.full_messages).to include "Image can't be blank"
      end

      #金額指定

      it '金額が300円未満だと登録できない' do
        @item.price = 299
        @item.valid?
        expect(@item.errors.full_messages).to include "Price can't be blank(only_integer from 300 to 9999999)"
      end
      it '金額が9999999円を超えると登録できない' do
        @item.price = 10000000
        @item.valid?
        expect(@item.errors.full_messages).to include "Price can't be blank(only_integer from 300 to 9999999)"
      end

      #文字数制限
      it '商品名が40文字を超えると登録できない' do
        @item.item_name = Faker::Lorem.characters(number: 41)
        @item.valid?
        expect(@item.errors.full_messages).to include "Item name can't be blank(maximum is 40 characters)"
      end
      it '商品の説明が1000文字を超えると登録できない' do
        @item.item_info = Faker::Lorem.characters(number: 1001)
        @item.valid?
        expect(@item.errors.full_messages).to include "Item info can't be blank(maximum is 1000 characters)"
      end
      
      #空欄不可
      #商品名
      it '商品名が空では登録できない' do
        @item.item_name = ''
        @item.valid?
        expect(@item.errors.full_messages).to include "Item name can't be blank(maximum is 40 characters)"
      end

      #商品説明
      it '商品の説明が空では登録できない' do
        @item.item_info = ''
        @item.valid?
        expect(@item.errors.full_messages).to include "Item info can't be blank(maximum is 1000 characters)"
      end

      #以下active::hash
      #カテゴリー
      it 'カテゴリーが空では登録できない' do
        @item.category_id = 0
        @item.valid?
        expect(@item.errors.full_messages).to include "Category can't be blank"
      end

      #商品状態
      it '商品の状態が空では登録できない' do
        @item.status_id = 0
        @item.valid?
        expect(@item.errors.full_messages).to include "Status can't be blank"
      end

      #配送負担
      it '配送料の負担が空では登録できない' do
        @item.fee_id = 0
        @item.valid?
        expect(@item.errors.full_messages).to include "Fee can't be blank"
      end

      #発送地域
      it '発送元の地域が空では登録できない' do
        @item.prefecture_id = 0
        @item.valid?
        expect(@item.errors.full_messages).to include "Prefecture can't be blank"
      end

      #発送までの日数
      it '発送までの日数が空では登録できない' do
        @item.schedule_id = 0
        @item.valid?
        expect(@item.errors.full_messages).to include "Schedule can't be blank"
      end



    end

  end

end