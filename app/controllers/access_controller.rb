class AccessController < ApplicationController
  def verify
    render plain: 'ok'
  end

  def updates
    render plain: 'ok'
    logger.info "#{params}"
  end
end
