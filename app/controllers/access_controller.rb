class AccessController < ApplicationController
  def verify
    render plain: 'ok'
  end

  def updates
    render plain: 'ok'
  end
end
