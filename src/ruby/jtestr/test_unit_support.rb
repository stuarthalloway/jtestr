JtestR::LoadStrategy.load(File.join(File.dirname(__FILE__), '..', 'dust', 'lib'), 'dust')

require 'test/unit'
require 'jtestr/test_unit_preset_collector'
require 'jtestr/test_unit_result_handler'
require 'jtestr/test_unit_exception_patching'

module JtestR
  module TestUnitTestRunning
    def add_test_unit_groups(group, match_info)
      files = choose_files(@test_units, match_info)
      files.sort!
      group << files
    end
    
    class TestUnitFilter
      def initialize(filters)
        @filters = filters
      end
      def [](tc)
        @filters.all? do |f|
          f.accept?(tc.class, tc.method_name)
        end
      end
    end

    def run_test_unit(group, aggr)
      files = group.files
      unless files.empty?
        log.debug { "running test unit[#{group.name}] on #{files.inspect}" }

        before = test_unit_classes
        before_all = classes

        files.each do |file|
          guard("while loading #{file}") { load file }
        end

        after = test_unit_classes
        after_all = classes
        
        log.debug "Testing classes: #{(after-before).inspect}"

        result_handler = JtestR.result_handler.new( 
                                                   @test_filters.empty? ? group.name : Filters.name(@test_filters), 
                                                   "test", 
                                                   @output, 
                                                   @output_level,
                                                   aggr)
        
        JtestR::Helpers.apply(after_all - before_all)
        
        @result = @result & Test::Unit::AutoRunner.new(false) do |runner|
          runner.collector = proc do |r|
            c = TestUnitPresetCollector.new
            c.filter = r.filters + [TestUnitFilter.new(@test_filters)]
            c.collect(group.name, after-before)
          end
          
          runner.runner = proc do |r|
            TestUnitResultHandler.instance_variable_set :@result_handler, result_handler
            TestUnitResultHandler
          end
        end.run
      end
    rescue Exception => e
      log.err e.inspect
      log.err e.backtrace
    end

    def classes
      all = []
      ObjectSpace.each_object(Class) do |klass|
        all << klass
      end
      all
    end

    def test_unit_classes
      all = []
      ObjectSpace.each_object(Class) do |klass|
        if Test::Unit::TestCase > klass
          all << klass
        end
      end
      all
    end
  end
end
