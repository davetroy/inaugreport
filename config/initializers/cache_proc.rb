# Allows you to pass in a proc to caches_page to determine if the page should be cached
# 
# Example:
# caches_page [:index, :show], :if => proc{|controller| controller.request.env["QUERY_STRING"].blank? }    

module ActionController
  module Caching
    module Pages
      module ClassMethods
        # def caches_page(*actions)
        #   return unless perform_caching
        #   actions = actions.map(&:to_s)
        #   after_filter { |c| c.cache_page if actions.include?(c.action_name) }
        # end
        def caches_page(actions, options={})
          # logger.info "CACHING PAGE" #: #{request.env["QUERY_STRING"]}
          return unless perform_caching
          actions = actions.map(&:to_s)
          conditions = options[:if] || nil 
          after_filter { |c| c.cache_page if actions.include?(c.action_name) and (! conditions || evaluate_condition(conditions, c)) }
        end

        private
        def condition_block?(condition)
          condition.respond_to?("call") && (condition.arity == 1 || condition.arity == -1)
        end      
        def evaluate_condition(condition, field)
          case condition
          when Symbol: field.send(condition)
          when String: eval(condition, binding)
          else
            if condition_block?(condition)
              condition.call(field)
            else
              raise(
              ArgumentError,
              "The :if option has to be either a symbol, string (to be eval'ed), proc/method, or " +
              "class implementing a static validation method"
              )
            end
          end
        end  
      end
    end  
  end
end