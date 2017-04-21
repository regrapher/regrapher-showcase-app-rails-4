ActiveSupport.on_load(:active_record) do
  before_create do |r|
    Regrapher.client.increment("record.#{r.model_name.plural}.created")
    true
  end
  before_destroy do |r|
    Regrapher.client.increment("record.#{r.model_name.plural}.destroyed")
    true
  end
  before_update do |r|
    Regrapher.client.increment("record.#{r.model_name.plural}.updated")
    true
  end
end

ActiveSupport::Notifications.subscribe 'process_action.action_controller' do |name, started, finished, unique_id, data|
  Regrapher.client.gauge('controller.process_action.view_runtime', data[:view_runtime])
  Regrapher.client.gauge('controller.process_action.db_runtime', data[:db_runtime])
  Regrapher.client.gauge('controller.process_action.runtime', finished-started)
  Regrapher.client.increment("controller.process_action.status_#{data[:status]}")
end