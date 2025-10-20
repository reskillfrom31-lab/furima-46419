require 'rails_helper'

RSpec.describe PurchaseForm, type: :model do

  let(:user) { FactoryBot.create(:user) }
  let(:item) { FactoryBot.create(:item) }
  let(:purchase_form) { FactoryBot.build(:purchase_form, user_id: user.id, item_id: item.id) }

  before do
    # テスト実行の都度、フォームオブジェクトを初期化するためにsleepを入れることがあります
    # （PAY.JPのAPI制限などを回避するため）
    sleep 0.1
  end

  describe '購入者情報の保存' do
    context '必要事項が全て正しく記入できていれば購入できる' do
      it 'すべての値が正しく入力されていれば保存できること' do
        expect(purchase_form).to be_valid
      end
      it 'buildingは空でも購入できる' do
        purchase_form.building = ''
        expect(purchase_form).to be_valid
      end
    end

    context '内容に問題があると保存ができない' do
      #紐づけ
      it 'user_idが紐づいていないと保存できない' do
        purchase_form.user_id = nil
        purchase_form.valid?
        expect(purchase_form.errors.full_messages).to include("User can't be blank")
      end
      it 'item_idが紐づいていないと保存できない' do
        purchase_form.item_id = nil
        purchase_form.valid?
        expect(purchase_form.errors.full_messages).to include("Item can't be blank")
      end
      #カード情報
      it 'token（クレジットカード情報）が空だと保存できない' do
        purchase_form.token = nil
        purchase_form.valid?
        expect(purchase_form.errors.full_messages).to include("Token can't be blank")
      end
      #配送先情報
      it 'postal_codeが空だと保存できない' do
        purchase_form.postal_code = ''
        purchase_form.valid?
        expect(purchase_form.errors.full_messages).to include("Postal code can't be blank")
      end
      it 'postal_codeが「3桁ハイフン4桁」の半角文字列でないと保存できない' do
        purchase_form.postal_code = '1234567'
        purchase_form.valid?
        expect(purchase_form.errors.full_messages).to include('Postal code is invalid. Include hyphen(-)')
      end
      it 'prefecture_idが未選択（---）だと保存できない' do
        purchase_form.prefecture_id = 0
        purchase_form.valid?
        expect(purchase_form.errors.full_messages).to include("Prefecture can't be blank")
      end
      it 'cityが空だと保存できない' do
        purchase_form.city = ''
        purchase_form.valid?
        expect(purchase_form.errors.full_messages).to include("City can't be blank")
      end
      it 'addressesが空だと保存できない' do
        purchase_form.addresses = ''
        purchase_form.valid?
        expect(purchase_form.errors.full_messages).to include("Addresses can't be blank")
      end
      #連絡先情報
      it 'phoneが空だと保存できない' do
        purchase_form.phone = ''
        purchase_form.valid?
        expect(purchase_form.errors.full_messages).to include("Phone can't be blank")
      end
      it 'phoneが10桁未満だと保存できない' do
        purchase_form.phone = '090123456' # 9桁
        purchase_form.valid?
        expect(purchase_form.errors.full_messages).to include('Phone is invalid')
      end
      it 'phoneが12桁以上だと保存できない' do
        purchase_form.phone = '090123456789' # 12桁
        purchase_form.valid?
        expect(purchase_form.errors.full_messages).to include('Phone is invalid')
      end
      it 'phoneに半角数字以外が含まれている場合は保存できない' do
        purchase_form.phone = '090-1234-5678'
        purchase_form.valid?
        expect(purchase_form.errors.full_messages).to include('Phone is invalid')
      end
    end
  end
end