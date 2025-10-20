require 'rails_helper'

RSpec.describe Address, type: :model do
  before do
    # テストで使用するインスタンスを生成
    user = FactoryBot.create(:user)
    item = FactoryBot.create(:item)
    # AddressはOrderに依存するため、Orderもcreateで永続化しておく方が安全
    order = FactoryBot.create(:order, user: user, item: item)
    @address = FactoryBot.build(:address, order: order)
  end

  describe '住所登録機能' do
    context '住所登録ができる場合' do
      it 'orderが紐づいていれば登録できる' do
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
    end
  end
end