class Messenger
  BASE_URL = 'https://graph.facebook.com/v2.6'
  TOKEN = "EAAal3liBQT0BAE4ZBO7wp6PLhlPFG4bW4GC3lYkl6iVIk5RSrgkowP4ZBRXMR1vNSw0R36TC4TdDQ0ucpoYImHPCI6hlQXkZBO0MpZADZA5mVnyWdatAarZBSpgEF5yGV6mDPQPMfmxgLxX68oZCZBU9WXomCsKoaGeTwoiTGG0mWAZDZD"

  def self.parse_payload payload
    payload[:entry].collect do |entry|
      {
        page_id: entry[:id],
        receipts: _get_receipts(entry),
        messages: entry[:messaging].try(:collect) do |message|
          {
            sender_id: message[:sender][:id],
            timestamp: message[:timestamp],
            type: self._entry_type?(message),
            message_id: message[:message] ? message[:message][:mid] : nil,
            text: message[:message] ? message[:message][:text] : nil,
            url: self._image_url(message),
            message_ids: message.try(:[], :delivery).try(:[], :mids),
            postback: message.try(:[], :postback),
            payload: message.try(:[], :message).try(:[], :attachments).try(:first).try(:[], :payload)
          }
        end
      }
    end
  end

  def self.send_message to, message, options=[]
    base_url = "#{BASE_URL}/me/messages?access_token=#{TOKEN}"
    headers = {'Content-Type' => 'application/json'}

    if !options.blank?
      body = { recipient: { id: to }, message: quick_response(message, options)}.to_json
    else
      body = {recipient: {id: to},message: {text: message}}.to_json
    end

    HTTParty.post(base_url, headers: headers, body: body)
  end

  def self.quick_response text, options=[]
    {
      text: text,
      quick_replies: options.collect { |o| { content_type: "text", title: o, payload: o } }
    }
  end

  def self.send_products to
    
  end

  def self.send_receipt to
    base_url = "#{BASE_URL}/me/messages?access_token=#{TOKEN}"
    headers = {'Content-Type' => 'application/json'}

    body = {
      recipient: {id: to},
      message: {
        attachment: {
          type: "template",
          payload: {
            template_type: "receipt",
            recipient_name: "Messenger User",
            order_number: "1234567890",
            currency: 'KES',
            payment_method: 'M-Pesa',
            order_url: '',
            timestamp: '1428444852',
            elements: [
              {
                title: 'fruit',
                price: '75.00'
              }
            ],
            summary: {total_cost: '75.00'},
            address: {
              street_1: "1 Hacker Way",
              city: "Menlo Park",
              postal_code: "94025",
              state: "CA",
              country: "US"
            }
          }
        }
      }
    }.to_json

    HTTParty.post(base_url, headers: headers, body: body)
  end

  private
    def self._get_receipts entry
      entry[:delivery].try(:[], :mids)
    end

    def self._entry_type? entry
      if entry[:message] && entry[:message][:text]
        return "Text"
      elsif entry[:message] && entry[:message][:attachments]          
        attachment = entry[:message][:attachments].first
        if attachment[:type] == 'image'
          return 'Image'
        elsif attachment[:type] == 'video'
          return 'Video'
        elsif attachment[:type] == 'audio'
          return 'Audio'
        elsif attachment[:type] == 'file'
          return 'File'
        elsif attachment[:type] == 'location'
          return 'Location'            
        end      
      elsif entry[:delivery]
        return 'Delivery'
      elsif entry[:postback]
        return 'Postback'
      elsif entry[:changes]
        return 'Feed'
      end
    end

    def self._image_url entry
      entry.try(:[], :message).try(:[], :attachments).try(:first).try(:[], :payload).try(:[], :url)
    end

end