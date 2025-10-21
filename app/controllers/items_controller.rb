class ItemsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_item, only: [:show, :edit, :update, :destroy]
  # 🚨 追加: 売却済みの場合にリダイレクトさせるロジック
  before_action :redirect_to_root_if_sold_out, only: [:edit, :update, :destroy]
  
  # 既存の出品者チェック
  before_action only: [:edit, :update, :destroy] do
    redirect_to root_path unless @item.user_id == current_user.id
  end

  def index    
    @items= Item.order(created_at: :desc)
  end

  def new
    @item = Item.new
  end

  def create
    @item = Item.new(item_params)
    if @item.save
      redirect_to '/'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @item.update(item_params)
      redirect_to @item
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy
    redirect_to root_path
  end

  private

  def redirect_to_root_if_sold_out
    if @item.order.present?
      redirect_to root_path
    end
  end


  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(
      :image,
      :item_name,
      :item_info,
      :category_id,
      :status_id,
      :fee_id,
      :prefecture_id,
      :schedule_id,
      :price      
    ).merge(user_id: current_user.id)
  end

end
