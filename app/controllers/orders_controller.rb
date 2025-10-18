class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: [:index, :create]
  #before_action :redirect_if_inappropriate, only: [:index, :create] #出品者自身が購入ページにアクセスしたり、すでに売却済みの商品ページにアクセスしたりするのを防ぐ

  def index
    @purchase_form = PurchaseForm.new
    gon.public_key = ENV["PAYJP_PUBLIC_KEY"] 
  end

  def create
    @purchase_form = PurchaseForm.new(purchase_params)
    if @purchase_form.valid? && @item.order.nil?
      @purchase_form.save
      redirect_to root_path
    else
      @purchase_form = PurchaseForm.new
      gon.public_key = ENV["PAYJP_PUBLIC_KEY"]
      render :index, status: :unprocessable_entity
    end
  end

  private

  def set_item
    @item = Item.find(params[:item_id])
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