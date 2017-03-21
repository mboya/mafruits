require 'messenger'

class MessengerController < ApplicationController
  def verify
    if params['hub.mode'] == 'subscribe' && params['hub.verify_token'] == "mafruits_token"
      render plain: params['hub.challenge']
    else
      render status: :bad_request, text: nil
    end
  end

  def updates
    render plain: 'ok'
    Messenger.parse_payload(params).each do |entry|
      entry[:messages].each do |message|
        begin
          sender = message[:sender_id]
          if message[:type] != 'Delivery'
            if message[:text] === 'start'
              options = ['order', 'stroll']
              Messenger.send_message(sender, 'welcome', options)
            else
              Messenger.send_message(sender, "try sending start to get you sorted")
            end
          end
        rescue Exception => e
          logger.error "Error on handling updates"
        end
      end
    end
  end

end