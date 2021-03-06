class PiecesController < ApplicationController
  before_action :set_piece, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, :only => [:new, :create, :edit, :update , :destroy]
  def all_pieces

  end
  
  def drawings
    @drawings = Piece.where(piece_type:"Dibujo").order(published_date: :asc)
  end

  def murals
    @murals = Piece.where(piece_type:"Mural").order(published_date: :asc)
  end

  def performances
    @performances = Piece.where(piece_type:"Performance").order(published_date: :asc)
  end

  def paintings
    @paintings = Piece.where(piece_type:"Pintura").order(published_date: :asc)
  end

  def show
    @piece = Piece.find(params[:id])
  end

  def new
    if current_user.admin?
      @piece = current_user.pieces.new
      @photo = @piece.photos.new
    else
      flash[:notice] = "Tienes que ser un administrador para agregar obras!"
      redirect_to root_path
    end 
  end

  def create
    @piece = current_user.pieces.new(piece_params)
    if @piece.save
      if params[:images]
        params[:images].each do |image|
          @piece.photos.create(img: image)
        end
      end
      redirect_to admin_panel_path, notice: "Nuevo obra creada exitosamente!" 
    else
      flash[:notice] = "Hubo un error al crear la obra. Asegúrate que todos los campos estén llenos."
      render :new
    end
  end

  def edit
    if current_user.admin?
      @piece = Piece.find(params[:id])
      @photo = @piece.photos.new
    else
      flash[:notice] = "Tienes que ser un adminstrador para editar obras!"
        redirect_to root_path
    end
  end

  def update
    @piece = Piece.find(params[:id])
    if params[:photo_ids]
      params[:photo_ids].each do |photo|
        Photo.find(photo).destroy
      end
    end
  
    if @piece.update_attributes(piece_params)
        if params[:images]
          params[:images].each do |image|
          @piece.photos.create(img: image)
        end
      end
      redirect_to admin_panel_path, notice: "Obra editada exitosamente!"
    else
      flash[:notice] = "Hubo un problema con la edición de obra. Intenta nuevamente!"
      render :edit
    end

  end

  def destroy
    @piece.destroy
    redirect_to admin_panel_path, notice: "Obra eliminada."
  end

  private
  def piece_params
    params.require(:piece).permit(:title, :tech_spec, :measurement, :piece_type, :published_date, :place, photos_attributes: [ img: [] ], photo_ids: [])
  end

  def photo_params
    #photo is inside :piece
    photo_json = params[:piece]
    photo_json.require(:photo).permit(:img, :piece_id)
  end
  def set_piece
    @piece = Piece.find(params[:id])
  end
end
