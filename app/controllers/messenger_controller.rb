class MessengerController < ApplicationController
  def verify
    if params['hub.mode'] == 'subscribe' && params['hub.verify_token'] == "mafruits_token"
      render text: params['hub.challenge']
    else
      render status: :bad_request, text: nil
    end
  end

  def updates
    render text: 'ok'
  end
end