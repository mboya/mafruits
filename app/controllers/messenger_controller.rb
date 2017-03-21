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
            case message[:text]
              when 'Get Started'
                options = ['order', 'stroll', 'receipt']
                Messenger.send_message(sender, 'welcome', options)
              when 'order'
                Messenger.send_message(sender, 'thank you, order template being setup')
              when 'stroll'
                Messenger.send_message(sender, 'thank you, stroll template being setup')
              when 'receipt'
                Messenger.send_receipt(sender)
              else
                options = ['Get Started']
                Messenger.send_message(sender, "try", options)
            end
          end
        rescue Exception => e
          logger.error "Error on handling updates"
        end
      end
    end
  end

end