require 'rails_helper'

RSpec.describe User, type: :model do
  # テストインスタンスを各itブロックの前に生成
  before do
    @user = FactoryBot.build(:user)
  end

  describe 'ユーザー新規登録' do
    ## 1. 正常系テスト
    context '新規登録できるとき' do
      it 'すべての必須項目と書式が正しく入力されていれば登録できる' do
        # FactoryBotがすでに正しいデータを持っていることを確認
        expect(@user).to be_valid
      end
    end

    context '新規登録できないとき' do
      #空では登録できない
      it 'nicknameが空では登録できない（Deviseのデフォルト必須項目）' do
        @user.nickname = '' 
        @user.valid?
        expect(@user.errors.full_messages).to include "Nickname can't be blank"
      end

      it 'emailが空では登録できない（Deviseのデフォルト必須項目）' do
        @user.email = ''
        @user.valid?
        expect(@user.errors.full_messages).to include "Email can't be blank"
      end

      it 'passwordが空では登録できない（Deviseのデフォルト必須項目）' do
        @user.password = '' 
        @user.password_confirmation = ''
        @user.valid?
        expect(@user.errors.full_messages).to include "Password can't be blank"
      end

      it 'last_nameが空では登録できない' do
        @user.last_name = '' 
        @user.valid?
        expect(@user.errors.full_messages).to include "Last name can't be blank"
      end

      it 'first_nameが空では登録できない' do
        @user.first_name = ''
        @user.valid?
        expect(@user.errors.full_messages).to include "First name can't be blank"
      end
      
      it 'last_name_kanaが空では登録できない' do
        @user.last_name_kana = ''
        @user.valid?
        expect(@user.errors.full_messages).to include "Last name kana can't be blank"
      end

      it 'first_name_kanaが空では登録できない' do
        @user.first_name_kana = ''
        @user.valid?
        expect(@user.errors.full_messages).to include "First name kana can't be blank"
      end

      it '生年月日が空では登録できない' do
        @user.birth_date = nil
        @user.valid?
        expect(@user.errors[:birth_date]).to be_present
        expect(@user.errors.full_messages).to include "Birth date can't be blank"
      end

      # 2重登録不可
      it 'emailが重複して存在する場合は登録できない' do
        @user.save
        another_user = FactoryBot.build(:user)
        another_user.email = @user.email
        another_user.valid?
        expect(another_user.errors.full_messages).to include('Email has already been taken')
      end
      # メールの不備
      it 'emailは@を含まないと登録できない' do
        @user.email ='testmail'
        @user.valid?
        expect(@user.errors.full_messages).to include('Email is invalid')
      end

      # パスワードの不備
      it 'passwordとpassword_confirmationが不一致では登録できない' do
        @user.password = '123456a'
        @user.password_confirmation = '1234567a'
        @user.valid?
        expect(@user.errors.full_messages).to include("Password confirmation doesn't match Password")
      end
      it 'passwordが6文字以下では登録できない' do
        @user.password = '0000a'
        @user.password_confirmation = '0000a'
        @user.valid?
        expect(@user.errors.full_messages).to include('Password is too short (minimum is 6 characters)')
      end

      it 'passwordが英字のみでは登録できない' do
        @user.password = 'aaaaaa'
        @user.password_confirmation = 'aaaaaa'
        @user.valid?
        expect(@user.errors.full_messages).to include 'Password is invalid. Include both letters and numbers'
      end

      it 'passwordが数字のみでは登録できない' do
        @user.password = '111111'
        @user.password_confirmation = '111111'
        @user.valid?
        expect(@user.errors.full_messages).to include 'Password is invalid. Include both letters and numbers'
      end

      it 'passwordに全角文字が含まれている場合は登録できない' do
        @user.password = 'あいうえお'
        @user.password_confirmation = 'あいうえお'
        @user.valid?
        expect(@user.errors.full_messages).to include 'Password is invalid. Include both letters and numbers'
      end

      # 氏名（last_name, first_name）の書式（全角）
      it 'last_nameが半角では登録できない' do
        @user.last_name = 'yamada'
        @user.valid?
        expect(@user.errors.full_messages).to include 'Last name is invalid. Input full-width characters.'
      end
      it 'first_nameが半角では登録できない' do
        @user.first_name = 'taro'
        @user.valid?
        expect(@user.errors.full_messages).to include 'First name is invalid. Input full-width characters.'
      end

      # 氏名カナ（last_name_kana, first_name_kana）の書式（全角カタカナ）
      it 'last_name_kanaがひらがなでは登録できない' do
        @user.last_name_kana = 'やまだ'
        @user.valid?
        expect(@user.errors.full_messages).to include 'Last name kana is invalid. Input full-width katakana characters.'
      end

      it 'first_name_kanaがひらがなでは登録できない' do
        @user.first_name_kana = 'たろう'
        @user.valid?
        expect(@user.errors.full_messages).to include 'First name kana is invalid. Input full-width katakana characters.'
      end

      it 'last_name_kanaが半角カナでは登録できない' do
        @user.last_name_kana = 'ﾔﾏﾀﾞ'
        @user.valid?
        expect(@user.errors.full_messages).to include 'Last name kana is invalid. Input full-width katakana characters.'
      end

      it 'first_name_kanaが半角カナでは登録できない' do
        @user.first_name_kana = 'ﾀﾛｳ'
        @user.valid?
        expect(@user.errors.full_messages).to include 'First name kana is invalid. Input full-width katakana characters.'
      end

    end
  end
end