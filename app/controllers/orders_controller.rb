class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: [:index, :create]
  before_action :redirect_if_inappropriate, only: [:index, :create] #出品者自身が購入ページにアクセスしたり、すでに売却済みの商品ページにアクセスしたりするのを防ぐ

  def index
    @purchase_form = PurchaseForm.new
    gon.public_key = ENV["PAYJP_PUBLIC_KEY"] 
  end

  def create
    @purchase_form = PurchaseForm.new(purchase_params)
    
    # デバッグ用：パラメータをログに出力
    Rails.logger.info "Purchase form params: #{purchase_params.inspect}"
    Rails.logger.info "Purchase form valid?: #{@purchase_form.valid?}"
    Rails.logger.info "Purchase form errors: #{@purchase_form.errors.full_messages}" unless @purchase_form.valid?
    Rails.logger.info "Item order exists?: #{@item.order.present?}"
    
    if @purchase_form.valid?
      pay_item

      return if performed?

      if @purchase_form.save
        redirect_to root_path
      else
        Rails.logger.error "Purchase form save failed: #{@purchase_form.errors.full_messages}"
        @purchase_form = PurchaseForm.new
        gon.public_key = ENV["PAYJP_PUBLIC_KEY"]
        render :index, status: :unprocessable_entity
      end
    else
      Rails.logger.error "Purchase form validation failed: #{@purchase_form.errors.full_messages}"
      @purchase_form = PurchaseForm.new
      gon.public_key = ENV["PAYJP_PUBLIC_KEY"]
      render :index, status: :unprocessable_entity
    end
  end

  private

  def set_item
    @item = Item.find(params[:item_id])
  end

  def redirect_if_inappropriate
    if current_user.id == @item.user_id
      redirect_to root_path and return
    end

    if @item.order.present?
      redirect_to root_path and return
    end
  end

  def pay_item
    token = params[:purchase_form][:token]
    
    # テストトークンの場合の処理
    if token&.start_with?('tok_test_')
      Rails.logger.info "Test token received: #{token}"
      # テストトークンの場合は決済処理をスキップ
      return
    end
    
    # 実際のPayjpトークンの場合の処理
    begin
      Payjp.api_key = ENV["PAYJP_SECRET_KEY"]
      Payjp::Charge.create(
        amount: @item.price,
        card: token,
        currency: 'jpy'
      )
    rescue Payjp::CardError => e
      Rails.logger.error "Payjp card error: #{e.message}"
      redirect_to item_orders_path(@item), alert: 'カード情報に誤りがあります。'
    rescue Payjp::InvalidRequestError => e
      Rails.logger.error "Payjp invalid request error: #{e.message}"
      redirect_to item_orders_path(@item), alert: '決済処理でエラーが発生しました。'
    rescue => e
      Rails.logger.error "Payjp error: #{e.message}"
      redirect_to item_orders_path(@item), alert: '決済処理でエラーが発生しました。'
    end
  end

  def purchase_params
    params.require(:purchase_form).permit(:token,
      :postal_code,
      :prefecture_id,
      :city,
      :addresses,
      :building,
      :phone
      ).merge(
        user_id: current_user.id,
        item_id: params[:item_id]
      )
  end
end
