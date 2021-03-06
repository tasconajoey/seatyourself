class ReservationsController < ApplicationController
  # before_action :load_user
  before_action :ensure_logged_in, only: [:create, :destroy]

    def capacity_validation(reservation_time)

      seats_sum = @reservation.seats
      Reservation.where(time: reservation_time).where(restaurant_id: @restaurant.id).where(date: @reservation.date).each do |res|
        seats_sum += res.seats
      end
      Reservation.where(time: reservation_time - 1.hour).where(restaurant_id: @restaurant.id).where(date: @reservation.date).each do |res|
        seats_sum += res.seats
      end
      seats_sum <= @restaurant.capacity

    end

    def past_validation(reservation_time)

      if @reservation.date.to_s == Time.now.to_date.to_s
        reservation_time > Time.now.hour
      else
        @reservation.date > Time.now.to_date
      end
    end

    # Doesn't use attributes from our restaurants model

    def open_validation(reservation_time)
      if @restaurant.closing_hour < @restaurant.opening_hour
        if reservation_time.hour < @restaurant.opening_hour.hour
          reservation_time.hour < @restaurant.closing_hour.hour
        else
          reservation_time.hour >= @restaurant.opening_hour.hour
        end
      else
        reservation_time.hour >= @restaurant.opening_hour.hour && reservation_time.hour < @restaurant.closing_hour.hour
      end
    end


    def reservation_params
      params.require(:reservation).permit(:time, :date, :seats, :request)
    end

    def show_form
      redirect_to restaurant_path(@restaurant.id)
    end

    def load_restaurant
      @restaurant = Restaurant.find(params[:restaurant_id])
    end

    def reservation_params
      params.require(:reservation).permit(:date, :time, :seats, :request)
    end

  def index
    @reservations = Reservation.all
  end

  def show
    @reservation = Reservation.find(params[:id])
  end

  def new
    @restaurant = Restaurant.find(params[:restaurant_id])
    @reservation = Reservation.new
  end

  def edit
    @reservation = Reservation.find(params[:id])
    @restaurant = Restaurant.find(params[:restaurant_id])
  end

  def create
    @restaurant = Restaurant.find(params[:restaurant_id])
    @reservation = Reservation.new(reservation_params)
    @reservation.user = current_user
    @reservation.restaurant_id = @restaurant.id

    if @reservation.save
      redirect_to root_url
    else
      render :new
    end
  end



  #   This uses methods that aren't supported by our models.
  #
  #   if past_validation(@reservation.time) && open_validation(@reservation.time) && capacity_validation(@reservation.time)
  #    if @reservation.save
  #      redirect_to restaurants_path
  #    else
  #      show_form
  #    end
  #  else
  #    if past_validation(@reservation.time) == false
  #      flash[:alert] = "reservation is in future time."
  #      show_form
  #    elsif open_validation(@reservation.time) == false
  #      flash[:alert] = "choose time #{@restaurant.open}:00 and #{@restaurant.close}:00"
  #      show_form
  #    elsif capacity_validation(@reservation.time) == false
  #      flash[:alert] = "There are no tables available for the time you've selected."
  #      past_res = @reservation.time - 1.hour
  #      future_res = @reservation.time + 2.hour
  #      if past_validation(past_res) && open_validation(past_res) && capacity_validation(past_res)
  #        flash[:alert] += "Available space at #{past_res.hour}h."
  #      end
  #      if past_validation(future_res) && open_validation(future_res) && capacity_validation(future_res)
  #        flash[:alert] += " There is space available at #{future_res.hour}h."
  #      end
  #      show_form
  #    end
  #  end


  def update
    @reservation = Reservation.find(params[:id])
    @restaurant = @reservation.restaurant
    @reservation.restaurant_id = @restaurant.id
    @reservation.user_id = current_user.id

    if @reservation.update_attributes(reservation_params)
      redirect_to user_path(current_user.id)
    else
      render :edit
    end
  end


  def destroy
    @reservation = Reservation.find(params[:id])
    @reservation.destroy
    redirect_back fallback_location: root_path
  end
  # def load_user
  #   @user = User.find(params[:product_id])
  # end
end
