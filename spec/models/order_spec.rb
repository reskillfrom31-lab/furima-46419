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
        @order.user = nil
        expect(@order).to be_invalid
        expect(@order.errors[:user]).to be_present
      end

      it 'itemが紐付いていないと保存できない' do
        @order.item = nil
        expect(@order).to be_invalid
        expect(@order.errors[:item]).to be_present
      end

      it '同一itemには重複して購入できない（item_idの一意性）' do
        FactoryBot.create(:order, user: @user, item: @item)
        another_order = FactoryBot.build(:order, user: FactoryBot.create(:user), item: @item)
        expect(another_order).to be_invalid
        expect(another_order.errors[:item_id]).to be_present
      end
    end
  end
end
