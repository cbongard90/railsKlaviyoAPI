require 'uri'
require 'net/http'
require 'openssl'

URL = URI('https://a.klaviyo.com/api/v2/list/WjfAbK/members?api_key=pk_ab6748f47f0e3345b4f28680a10f6f64a3')

class Api::V2::ContactsController < ApplicationController

  def create
    @contact = Contact.new(contact_params)

    # if @contact.save
    #   # render json: @contact, status: :ok
    #   klaviyo_response = post_to_klaviyo(@contact)
    #   puts klaviyo_response
    #   render json: klaviyo_response, status: :ok
    # else
    #   render json: @contact.errors, status: :unprocessable_entity
    # end

    if @contact.valid?
      klaviyo_response = post_to_klaviyo(@contact)
      puts klaviyo_response

      if klaviyo_response.include? "detail"
        @contact.is_klavio_successful = false
        @contact.save
        render json: klaviyo_response, status: :unprocessable_entity
      else
        @contact.is_klavio_successful = true
        @contact.save
        render json: klaviyo_response, status: :ok
      end
    else
      puts "Contact is invalid"
      render json: @contact.errors, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact)
          .permit(:first_name,
                  :last_name,
                  :email,
                  :phone_number,
                  :date_of_birth,
                  :country,
                  :sms_consent)
  end

  def post_to_klaviyo(user)
    # Add user to Klaviyo list
    http = Net::HTTP.new(URL.host, URL.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(URL)
    request['Content-Type'] = 'application/json'
    request.body = "{\n\"profiles\": [\n{\n\"email\": \"#{user.email}\",\n\"phone_number\": \"#{user.phone_number}\",\n\"first_name\":\"#{user.first_name}\",\n\"last_name\": \"#{user.last_name}\",\n \"date_of_birth\":\"#{user.date_of_birth}\",\"sms_consent\": #{user.sms_consent}\n}\n]\n}"
    response = http.request(request)

    response.read_body
  end
end
