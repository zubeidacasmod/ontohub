require 'sidekiq/cli'

module StateUpdater
  extend ActiveSupport::Concern
  
  included do
    scope :state, ->(*states){
      where state: states.map(&:to_s)
    }
  end

  protected
  
  def after_failed
    # override if necessary
  end
  
  def do_or_set_failed(&block)
    raise ArgumentError.new('No block given.') unless block_given?

    begin
      yield
    rescue Exception => e
      update_state! :failed, e.message
      after_failed
      raise e
    rescue Sidekiq::Shutdown
      # Sidekiq requeues the current job automatically
      update_state! :pending
      raise
    end
  end

  def update_state!(state, error_message = nil)
    self.state      = state.to_s
    self.last_error = error_message

    save!
  rescue PG::Error
    # Can happen on save!
    self.class.where(id: id).update_all \
      state:      state.to_s, 
      last_error: error_message

    raise
  end
end
