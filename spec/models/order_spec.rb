require 'rails_helper'

RSpec.describe Order, type: :model do
  before do
    @user = FactoryBot.create(:user)
    @item = FactoryBot.create(:item)
    @order = FactoryBot.build(:order, user: @user, item: @item)
  end

  describe 'オーダー保存機能' do
    context 'オーダー保存できる場合' do
      it 'すべての必須項目が正しく入力されていれば保存できる' do
        expect(@order).to be_valid
      end
    end

    context 'オーダー保存できない場合' do
      it 'userが紐付いていないと保存できない' do
        @order.user_id = nil
        @order.valid?
        expect(@order.errors.full_messages).to include('User must exist')
      end

      it 'itemが紐付いていないと保存できない' do
        @order.item_id = nil
        @order.valid?
        expect(@order.errors.full_messages).to include('Item must exist')
      end

    end
  end
end
