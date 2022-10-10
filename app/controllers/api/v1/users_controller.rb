require 'uri'
require 'net/http'
require 'openssl'

URL = URI("https://a.klaviyo.com/api/v2/list/WjfAbK/members?api_key=#{ENV['KLAVIYO_API_KEY']}")

class Api::V1::UsersController < ApplicationController
  before_action :set_user, only: %i[ show update destroy ]

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    render json: @user
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created

      # Add user to Klaviyo list
      http = Net::HTTP.new(URL.host, URL.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(URL)
      request["Content-Type"] = "application/json"
      request.body = "{\n\"profiles\": [\n{\n\"email\": \"#{@user.email}\",\n            \"phone_number\": \"#{@user.phone_number}\",\n            \"first_name\": \"#{@user.first_name}\",\n            \"last_name\": \"#{@user.last_name}\",\n            \"date_of_birth\": \"#{@user.date_of_birth}\", \"sms_consent\": true\n        }\n    ]\n}"

      response = http.request(request)
      puts response.read_body
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :phone_number, :date_of_birth)
    end
end
