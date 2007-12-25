value1 :abc, :cde
$__was_in_config = 42

junit "unit" => ['org.jtestr.test.JUnit3Test', 'org.jtestr.test.JUnit4Test']
junit ['org.jtestr.test.JUnit3Test']
junit 'org.jtestr.test.JUnit4Test'

class FooLogger
  def initialize(*args)
  end
  def method_missing(name, *args)
    $__foo_logger_called = true
  end
end

class IgnoringResultHandler
  def initialize(name, type_name, output = STDOUT, level = DEFAULT)
    @name = name
    @level = level
    @output = output
    @type_name = type_name
  end

  def starting_single(name = nil)
    @tname = name
    $__ignoring_result_handler_have_started = true
  end

  def fail_single(name = nil)
    @output.puts "#{@name} failed"
  end

  def error_single(name = nil)
    @output.puts "#{@name} had an error"
  end

  def method_missing(name, *args)
  end
end

JtestR::logger = FooLogger
JtestR::result_handler = IgnoringResultHandler