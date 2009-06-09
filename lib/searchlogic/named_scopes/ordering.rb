module Searchlogic
  module NamedScopes
    module Ordering
      def condition?(name)
        super || order_condition?(name)
      end
      
      def order_condition?(name)
        !order_condition_details(name).nil?
      end
      
      private
        def method_missing(name, *args, &block)
          if name == :order
            named_scope name, lambda { |scope_name|
              return {} if !order_condition?(scope_name)
              send(scope_name).proxy_options
            }
            send(name, *args)
          elsif details = order_condition_details(name)
            create_order_conditions(details[:column])
            send(name, *args)
          else
            super
          end
        end
        
        def order_condition_details(name)
          if name.to_s =~ /^(ascend|descend)_by_(\w+)$/
            {:order_as => $1, :column => $2}
          elsif name.to_s =~ /^order$/
            {}
          end
        end
        
        def create_order_conditions(column)
          named_scope("ascend_by_#{column}".to_sym, {:order => "#{table_name}.#{column} ASC"})
          named_scope("descend_by_#{column}".to_sym, {:order => "#{table_name}.#{column} DESC"})
        end
    end
  end
end