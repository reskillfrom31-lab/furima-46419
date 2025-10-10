class ItemsController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def index
    @items= Item.all
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

  private

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
