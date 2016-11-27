class CooksController < ApplicationController

    skip_before_action :authenticate_user!, only: [:index, :show]

    before_action :set_cook, only: [:show, :edit, :update, :destroy]

    def index
      if params[:location].present?
        @places = Place.where.not(latitude: nil, longitude: nil).near(params[:location], 1)
        @cooks = Cook.order(created_at: :asc)
      else
        @places = Place.where.not(latitude: nil, longitude: nil)
        @cooks = Cook.order(created_at: :asc)
      end

      @hash = Gmaps4rails.build_markers(@places) do |place, marker|
        marker.lat place.latitude
        marker.lng place.longitude
        marker.infowindow render_to_string(partial: "/cooks/map_box", locals: { place: place })
      end
    end

    def new
      @cook = Cook.new
      @cook_places = @cook.cook_places.build
      @place = @cook_places.build_place
      @cook_specialities = @cook.cook_specialities.build
      @speciality = @cook_specialities.build_speciality
    end

    def show
      @dishes = @cook.dishes.order(updated_at: :desc)
      @order_item = current_order.order_items.new(dish: @dish)
      @specialities = @cook.specialities.all
      @places = @cook.places.all
    end

    def create
      @cook = Cook.new(cook_params)
      @cook.user = current_user
      if @cook.save
        redirect_to cook_path(@cook), notice: "Votre profil a bien été créé"
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @cook.user == current_user
        @cook.update(cook_params)
        redirect_to cook_path(@cook), notice: "Votre profil a bien été modifié"
      else
        flash[:alert] = "Action impossible, ce n'est pas votre profil !"
        render :edit
      end
    end

    def destroy
      if @cook.user == current_user
        @cook.destroy
        redirect_to cooks_path, notice: "Votre profil a bien été supprimé"
      else
        flash[:alert] = "Action impossible, ce n'est pas votre profil !"
        redirect_to cooks_path
      end
    end

    private
    def set_cook
      @cook = Cook.find(params[:id])
    end

    def cook_params
      params.require(:cook).permit(:last_name, :first_name, :age, :bio, :avatar, cook_specialities_attributes: [:id, speciality_attributes: [:name, :level]], cook_places_attributes: [:id, place_attributes: [:name, :full_address, :zip_code, :city, :kind_of_place, :reception_desk]])
    end

end
