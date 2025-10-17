require 'rails_helper'

RSpec.describe Address, type: :model do
  before do
    # テストで使用するインスタンスを生成
    user = FactoryBot.create(:user)
    item = FactoryBot.create(:item)
    @order = FactoryBot.build(:order, user: user, item: item)
  end

  before do
    @address = FactoryBot.build(:address, order: @order)
  end

  describe '住所登録機能' do
    context '住所登録ができる場合' do
      it '住所が正しく入力されていれば登録できる' do
        expect(@address).to be_valid
      end
    end

    context '住所登録できない場合' do
      # 紐づけ
      it 'オーダーが紐付いていないと登録できない' do
        @address.order = nil
        @address.valid?
        expect(@address.errors.full_messages).to include('Order must exist')
      end

      # 住所
      it '郵便番号が空では登録できない' do
        @address.postal_code = ''
        @address.valid?
        expect(@address.errors.full_messages).to include "Postal code can't be blank"
      end

      it '郵便番号が全角文字が含まれると登録できない' do
        @address.postal_code = '111-111１'
        @address.valid?
        expect(@address.errors.full_messages).to include "Postal code is invalid. include half-width number"
      end

      it '郵便番号に半角の「-」が無いと登録できない' do
        @address.postal_code = '1111111'
        @address.valid?
        expect(@address.errors.full_messages).to include "Postal code is invalid. Include hyphen (-)"
      end

      it '都道府県が空では登録できない' do
        @address.prefecture_id = 0
        @address.valid?
        expect(@address.errors.full_messages).to include "Prefecture can't be blank"
      end

      it '市区町村が空では登録できない' do
        @address.city = ''
        @address.valid?
        expect(@address.errors.full_messages).to include "City can't be blank"
      end

      it '番地が空では登録できない' do
        @address.addresses = ''
        @address.valid?
        expect(@address.errors.full_messages).to include "Addresses can't be blank"
      end

      it '電話番号が空では登録できない' do
        @address.phone = ''
        @address.valid?
        expect(@address.errors.full_messages).to include "Phone can't be blank"
      end

      it '電話番号が半角数字以外では登録できない' do
        @address.phone = 'a'
        @address.valid?
        expect(@address.errors.full_messages).to include "Phone is only integer"
      end

      it '電話番号が11桁を超えると登録できない' do
        @address.phone = Faker::Phone.number(digits: 12)
        @address.valid?
        expect(@address.errors.full_messages).to include "Phone is only integer(maxlength is 11)"
      end
    end
  end
end
