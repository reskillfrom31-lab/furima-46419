require 'rails_helper'

RSpec.describe PurchaseForm, type: :model do

  before do
    user = FactoryBot.create.(:user)
    item = FactoryBot.create.(:item, user_id: user.id)
    @purchase_form = FactoryBot.build(:purchase_form, user_id: user.id, item_id: item.id)
  end

  describe '購入者情報の保存' do
    context '必要事項が全て正しく記入できていれば購入できる' do
      it 'buildingは空でも購入できる' do
        @purchase_form.building = nil
        expect(@purchase_form).to be_valid
      end
    end

    context '内容に問題があると保存ができない' do
      it 'user_idが紐づいていないと保存できない' do
        @purchase_form.user_id = nil
        @purchase_form.valid?
        expecct(@purchase_form.errors.full_messages).to include('User must exist')
      end
      it 'item_idが正しくない' do
        @purchase_form.item_id = 999999
        expect(@purchase_form).to not be_valid
      end
      it 'tokenが正しくない' do
        @purchase_form.token = 'invalid_token'
        expect(@purchase_form).to not be_valid
      end
      it 'postal_codeが空だと保存できない' do
        @purchase_form.postal_code = ''
        expect(@purchase_form).to not be_valid
      end

      it 'prefecture_idが正しくない' do
        @purchase_form.prefecture_id = 0
        expect(@purchase_form).to not be_valid
      end
      it 'cityが空だと保存できない' do
        @purchase_form.city = ''
        expect(@purchase_form).to not be_valid
      end
      it 'addressesが空だと保存できない' do
        @purchase_form.addresses = ''
        expect(@purchase_form).to not be_valid
      end
      it 'phoneが空だと保存できない' do
        @purchase_form.phone = ''
        expect(@purchase_form).to not be_valid
      end

      it '既に購入されている商品は購入できない' do
                
      end
    end
  end
end