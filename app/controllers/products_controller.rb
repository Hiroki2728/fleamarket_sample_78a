class ProductsController < ApplicationController
  before_action :move_to_index, except: [:index, :show, :search]
  before_action :set_parents

  def index
    @products = Product.order("created_at DESC").first(5)
  end

  def new
    @product = Product.new
    @product.images.new
    
    @category_parent_array = ["選択してください"]
    Category.where(ancestry: nil).each do |parent|
      @category_parent_array << parent.name
    end
  end

  def get_category_children
    @category_children = Category.find_by(name: "#{params[:parent_name]}", ancestry: nil).children
  end

  def get_category_grandchildren
    @category_grandchildren = Category.find("#{params[:child_id]}").children

  end

  def create
    @product = Product.new(product_params)

    @category_parent_array = ["選択してください"]
    Category.where(ancestry: nil).each do |parent|
      @category_parent_array << parent.name
    end
    if @product.save
      redirect_to root_path
    else
        @product.images.new
        render :new
    end
  end

  def destroy
    product = Product.find(params[:id])
    if product.user_id == current_user.id
      if product.destroy
      else
        redirect_to root_path, alert: "削除が失敗しました"
      end
    end
  end

  def show
    @product = Product.find(params[:id])

    @category_id = @product.category_id
    @category_parent = Category.find(@category_id).parent.parent
    @category_child = Category.find(@category_id).parent
    @category_grandchild = Category.find(@category_id)
  end

  def search
    @products = Product.search(params[:keyword]).order("created_at DESC")
  end

  def edit
    @product = Product.find(params[:id])
  end


  def compilation
    @product = Product.find(params[:id])
    @images = Image.where(product_id: params[:id])
    @product.images.new
    #@category_id = @product.category_id
    #@category_parent_array = []
    #Category.where(ancestry: nil).each do |parent|
      #@category_parent_array << parent.name
    #end
    
  end

  def update
    @product = Product.find(params[:id])
    @images = Image.where(product_id: params[:id])
    if @product.update_attributes(product_params)
      redirect_to "/"
    else
      render action: :compilation
    end
  end

  private
  
  def move_to_index
    unless user_signed_in?
      redirect_to action: :index
    end
  end

  def product_params
    params.require(:product).permit(:prefecture_id, :days_id, :condition_id, :category_id, :name, :details, :price, :condition, :fee_side, :origin, :days, images_attributes: [:url, :_destroy, :id]).merge(user_id: current_user.id)
  end
  
  def set_product
    @product = Product.find(params[:id])
  end

  def set_parents
    @parents = Category.where(ancestry: nil)
  end
end
