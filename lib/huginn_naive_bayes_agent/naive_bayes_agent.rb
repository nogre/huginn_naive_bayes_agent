require 'nbayes'
require'yaml'

module Agents
  class NaiveBayesAgent < Agent
    cannot_be_scheduled!
    can_dry_run!

    description <<-MD
      The Naive Bayes Agent uses incoming Events from certain sources as a training set for Naive Bayes Machine Learning. Then it classifies Events from other sources and adds category tags to them accordingly.
      
      All incoming events should have these two fields in their payloads, likely via the Event Formatting or Javascript Agent:
      
        * `nb_content` for the content used for classification, space separated. 
        * `nb_cats` for the classification categories, space separated.
        
      If `nb_cats` is empty, then the content from `nb_content` will be classified according to the training data. The categories will be added to `nb_cats` and then a new event is created with that payload.
      
      However, if `nb_cats` is already populated, then the content from `nb_content` will be used as training data for the categories listed in `nb_cats`. For instance, say `nb_cats` consists of `trees`. Then `nb_content` will be used as training data for the category `trees`. The data is saved to the agent memory. 
      
      When an event is received for classification, the Naive Bayes Agent will assign a value between 0 and 1 representing the likelihood that it falls under a category. The `min_value` option lets you choose the minimum threshold that must be reached before the event is labeled with that category. If `min_value` is set to 1, then the event is labeled with whichever category has the highest value.
      
      The option `propagate_training_events` lets you choose whether the training events are emitted along with the classified events. If it is set to false, then no new event will be created from events that already had categories when they were received.
      
      #### Advanced Features
      
      *Be carefull with these functions: see the documentation linked below.*
      
      If a category has a `-` in front of it, eg. `-trees`, then the category `trees` will be UNtrained according to that content. 
      
      To load trained data into an agent's memory, create a Manual Agent with `nb_cats : =loadYML` and `nb_content : your-well-formed-training-data-here`. Use the text input box, not the form view, by clicking "Toggle View" when inputting your training data else whitespace errors occur in the YML. Then submit this to your Naive Bayes Agent.
      
      Low frequency words that increase processing time and may overfit - tokens with a count less than x (measured by summing across all classes) - can be removed: Set `nb_cats : =purgeTokens` and `nb_content : integer-value`.

      Categories can be similarly deleted by `nb_cats : =delCat` and `nb_content : categories to delete`.
      
      **See [the NBayes ruby gem](https://github.com/oasic/nbayes) and [this blog post](http://blog.oasic.net/2012/06/naive-bayes-for-ruby.html) for more information about the Naive Bayes implementation used here.**
    MD

    def default_options
      {
        'min_value' => "0.5",
        'propagate_training_events' => 'true',
        'expected_update_period_in_days' => "7"
      }
    end

    def validate_options
      errors.add(:base, "expected_update_period_in_days must be present") unless options['expected_update_period_in_days'].present?
      errors.add(:base, "minimum value must be greater than 0 and less than or equal to 1, e.g. 0.5") unless (0 < options['min_value'].to_f && options['min_value'].to_f <= 1)
    end
    
    def working?
      received_event_without_error?
    end

    def receive(incoming_events)
      incoming_events.each do |event|
        nbayes = load(memory['data'])
        if event.payload['nb_cats'].length != 0
          cats = event.payload['nb_cats'].split(/\s+/)
          if cats[0] == "=loadYML"
            memory['data'] = event.payload['nb_content']
          elsif cats[0] == "=delCat"
            ca = event.payload['nb_content'].split(/\s+/)
            ca.each do |c|
              nbayes.delete_category(c)
            end
          elsif cats[0] == "=purgeTokens"
            nbayes.purge_less_than(event.payload['nb_content'].to_i)
          else
            cats.each do |c|
              c.starts_with?('-') ? nbayes.untrain(event.payload['nb_content'].split(/\s+/), c[1..-1]) : nbayes.train(event.payload['nb_content'].split(/\s+/), c)
            end
            memory['data'] = YAML.dump(nbayes)
            if interpolated['propagate_training_events'] = "true"
              create_event payload: event.payload
            end
          end
        else
          result = nbayes.classify(event.payload['nb_content'].split(/\s+/))
          if interpolated['min_value'].to_f == 1
            result.max_class
          else
            result.each do |cat, val|
              if val > interpolated['min_value'].to_f
                event.payload['nb_cats'] << (event.payload['nb_cats'].length == 0 ? cat : " "+cat)
              end
            end
          end
          create_event payload: event.payload
        end
      end
    end

    def load(dat)
      if dat.nil?
        nbayes = NBayes::Base.new
      elsif dat[0..2] == "---"
        nbayes = NBayes::Base.new
        nbayes.from_yml(dat)
      else
        nbayes = NBayes::Base.new
        nbayes.from(dat)
      end
      nbayes
    end
    
    
    def self.from_yml(yml_data)
      nbayes = YAML.load(yml_data)
      nbayes.reset_after_import()  # yaml does not properly set the defaults on the Hashes
      nbayes
    end

    def purge_less_than(x)
      remove_list = {}
      nbayes = load(memory['data'])
      nbayes.vocab.each do |token|
        if nbayes.data.purge_less_than(token, x)
          # print "removing #{token}\n"
          remove_list[token] = 1
        end
      end  # each vocab word
      remove_list.keys.each {|token| nbayes.vocab.delete(token) }
      memory['data'] = YAML.dump(nbayes)
    end

    # Delete an entire category from the classification data
    def delete_category(category)
      nbayes = load(memory['data'])
      nbayes.data.delete_category(category)
      memory['data'] = YAML.dump(nbayes)
    end
  end
end
